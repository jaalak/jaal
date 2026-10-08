import 'package:drift/drift.dart';
import 'package:logging/logging.dart';

import '../db/database.dart';
import '../events/projector.dart' show lwwNewer;
import '../identity/identity.dart';
import '../identity/meet_code.dart';
import '../media/media_store.dart';
import '../protocol/event.dart';
import '../util/canonical_json.dart';
import 'moderation_config.dart';

/// What changed after a recompute.
class ModerationDelta {
  const ModerationDelta(this.newlyBanned, this.unbanned, this.moderatorsChanged);
  final Set<RootId> newlyBanned;
  final Set<RootId> unbanned;
  final bool moderatorsChanged;
  bool get isEmpty => newlyBanned.isEmpty && unbanned.isEmpty && !moderatorsChanged;
}

/// Derives the moderator set and ban states from signed `mod.*` events.
///
/// Nothing here is trusted from a server: every client computes the same
/// answer from the same events (protocol/SPEC.md §10.3):
///
/// * moderators = genesis ∪ { c : ≥ [vouchesRequired] distinct moderators
///   vouched for c with c's signed consent QR, and c isn't revoked }
/// * a moderator is revoked by any one genesis key, or ≥ [revokeQuorum]
///   distinct other moderators; their actions after the revocation cutoff
///   no longer count
/// * per target, each moderator's latest ban vote counts once:
///   1 vote → flagged (hidden), ≥ [banQuorum] → banned (purged, refused).
///   Moderators and genesis keys can't be banned (revoke them first).
class ModerationEngine {
  ModerationEngine(this.db, this.config, {required this.me, Logger? log})
      : _log = log ?? Logger('jaal.moderation');

  final JaalDatabase db;
  final ModerationConfig config;
  final RootId me;
  final Logger _log;

  Set<RootId> _moderators = {};
  Set<RootId> _banned = {};
  Set<RootId> _flagged = {};
  Map<RootId, Set<RootId>> _vouchedBy = {};
  Map<RootId, Set<RootId>> _votesAgainst = {};

  Set<RootId> get moderators => Set.unmodifiable(_moderators);
  Set<RootId> get banned => Set.unmodifiable(_banned);
  bool isModerator(RootId r) => _moderators.contains(r);
  bool isBanned(RootId r) => _banned.contains(r);
  bool isFlagged(RootId r) => _flagged.contains(r);

  /// Moderators whose vouches for [r] currently count.
  Set<RootId> vouchesFor(RootId r) => Set.unmodifiable(_vouchedBy[r] ?? const {});

  /// Moderators currently voting to remove [r].
  Set<RootId> votesAgainst(RootId r) => Set.unmodifiable(_votesAgainst[r] ?? const {});

  /// Validates a `mod.*` event and records it. Called by the Projector
  /// inside the ingest transaction.
  Future<void> record(SignedEvent e, Map<String, Object?> body, RootId author) async {
    var valid = true;
    String target;
    var on = true;
    switch (e.type) {
      case EventType.modVouch:
        target = body['candidate']! as String;
        valid = await _validConsent(e, body, author);
      case EventType.modRevoke:
        target = body['target']! as String;
      case EventType.modBan:
        target = body['target']! as String;
        on = body['on']! as bool;
      default:
        return;
    }
    if (target == author) valid = false; // no self-vouch / self-ban
    await db.into(db.modActions).insert(
          ModActionsCompanion.insert(
            eventId: e.id,
            author: author,
            feedId: e.feed,
            seq: e.seq,
            type: e.type,
            target: target,
            isOn: Value(on),
            lamport: e.lamport,
            ts: e.ts,
            body: CanonicalJson.encode(body),
            valid: valid,
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<bool> _validConsent(
      SignedEvent e, Map<String, Object?> body, RootId author) async {
    try {
      final code = MeetCode.fromJson((body['consent']! as Map).cast());
      if (code.purpose != MeetPurpose.moderator) return false;
      if (code.root != body['candidate']) return false;
      if ((e.ts - code.ts).abs() > config.consentMaxSkew.inMilliseconds) {
        return false;
      }
      return await code.verify();
    } on Object {
      return false;
    }
  }

  /// Loads cached sets (call once at startup).
  Future<void> init() async {
    await recompute();
  }

  /// Recomputes moderators and ban states from all recorded actions.
  Future<ModerationDelta> recompute() async {
    final actions = await (db.select(db.modActions)
          ..where((a) => a.valid.equals(true)))
        .get();
    final genesis = config.genesis;

    // Revocation cutoffs: author -> {feed: lastValidSeq}.
    var revoked = <RootId, Map<String, int>>{};
    // Everyone who ever reached the vouch threshold (revoked or not).
    var qualified = <RootId>{};
    final vouchedBy = <RootId, Set<RootId>>{};

    bool voided(ModActionRow a, Map<RootId, Map<String, int>> rev) {
      final cut = rev[a.author];
      if (cut == null) return false;
      final last = cut[a.feedId];
      return last == null || a.seq > last;
    }

    // An action counts if its author is (or was) a moderator and it isn't
    // past their revocation cutoff.
    bool authorized(
            ModActionRow a, Set<RootId> q, Map<RootId, Map<String, int>> rev) =>
        (genesis.contains(a.author) || q.contains(a.author)) && !voided(a, rev);

    for (var iter = 0; iter < 32; iter++) {
      // 1. revocations
      final nextRevoked = <RootId, Map<String, int>>{};
      final byTarget = <RootId, List<ModActionRow>>{};
      for (final a in actions) {
        if (a.type != EventType.modRevoke) continue;
        if (genesis.contains(a.target)) continue;
        if (!authorized(a, qualified, revoked)) continue;
        byTarget.putIfAbsent(a.target, () => []).add(a);
      }
      for (final MapEntry(key: target, value: votes) in byTarget.entries) {
        final fromGenesis =
            votes.where((v) => genesis.contains(v.author)).toList();
        final distinct = <RootId, ModActionRow>{
          for (final v in votes) v.author: v,
        };
        final List<ModActionRow> effective;
        if (fromGenesis.isNotEmpty) {
          effective = fromGenesis;
        } else if (distinct.length >= config.revokeQuorum) {
          effective = distinct.values.toList();
        } else {
          continue;
        }
        nextRevoked[target] = _mergeCutoffs(effective);
      }

      // 2. vouches
      final nextQualified = <RootId>{};
      vouchedBy.clear();
      for (final a in actions) {
        if (a.type != EventType.modVouch) continue;
        if (!authorized(a, qualified, nextRevoked)) continue;
        vouchedBy.putIfAbsent(a.target, () => {}).add(a.author);
      }
      for (final MapEntry(key: c, value: by) in vouchedBy.entries) {
        if (!genesis.contains(c) && by.length >= config.vouchesRequired) {
          nextQualified.add(c);
        }
      }

      final stable = _sameSet(nextQualified, qualified) &&
          _sameSet(nextRevoked.keys.toSet(), revoked.keys.toSet());
      qualified = nextQualified;
      revoked = nextRevoked;
      if (stable) break;
    }
    final mods = {...genesis, ...qualified.difference(revoked.keys.toSet())};

    // 3. ban votes: latest authorized vote per (moderator, target)
    final latest = <(RootId, RootId), ModActionRow>{};
    for (final a in actions) {
      if (a.type != EventType.modBan) continue;
      if (!authorized(a, qualified, revoked)) continue;
      final k = (a.author, a.target);
      final cur = latest[k];
      if (cur == null ||
          lwwNewer(a.lamport, a.eventId, cur.lamport, cur.eventId)) {
        latest[k] = a;
      }
    }
    final votes = <RootId, List<ModActionRow>>{};
    for (final a in latest.values) {
      if (a.isOn) votes.putIfAbsent(a.target, () => []).add(a);
    }

    final banned = <RootId>{}, flagged = <RootId>{};
    final statusRows = <ModStatusCompanion>[];
    for (final MapEntry(key: target, value: vs) in votes.entries) {
      if (mods.contains(target)) continue; // revoke first
      final state = vs.length >= config.banQuorum ? ModState.banned : ModState.flagged;
      (state == ModState.banned ? banned : flagged).add(target);
      vs.sort((a, b) => lwwNewer(a.lamport, a.eventId, b.lamport, b.eventId) ? -1 : 1);
      final reason = (CanonicalJson.decode(vs.first.body)! as Map)['reason'] as String? ?? '';
      statusRows.add(ModStatusCompanion.insert(
          rootId: target, state: state, votes: vs.length, reason: Value(reason)));
    }

    final delta = ModerationDelta(
      banned.difference(_banned),
      _banned.difference(banned),
      !(mods.length == _moderators.length && mods.containsAll(_moderators)),
    );

    await db.transaction(() async {
      await db.delete(db.moderators).go();
      for (final m in mods) {
        await db.into(db.moderators).insert(ModeratorsCompanion.insert(
              rootId: m,
              role: genesis.contains(m) ? ModRole.genesis : ModRole.vouched,
              vouchedBy: Value((vouchedBy[m] ?? const {}).join(',')),
            ));
      }
      await db.delete(db.modRevocations).go();
      for (final MapEntry(:key, :value) in revoked.entries) {
        await db.into(db.modRevocations).insert(ModRevocationsCompanion.insert(
            rootId: key, cutoff: CanonicalJson.encode(value)));
      }
      await db.delete(db.modStatus).go();
      for (final r in statusRows) {
        await db.into(db.modStatus).insert(r);
      }
      for (final r in delta.newlyBanned) {
        if (r != me) await _purge(r);
      }
    });

    _moderators = mods;
    _banned = banned;
    _flagged = flagged;
    _vouchedBy = {for (final e in vouchedBy.entries) e.key: {...e.value}};
    _votesAgainst = {
      for (final e in votes.entries) e.key: {for (final v in e.value) v.author},
    };
    if (!delta.isEmpty) {
      _log.info('moderation: ${mods.length} mods, ${banned.length} banned, '
          '${flagged.length} flagged (new bans: ${delta.newlyBanned.length})');
    }
    return delta;
  }

  static bool _sameSet<T>(Set<T> a, Set<T> b) =>
      a.length == b.length && a.containsAll(b);

  /// Per-feed minimum cutoff across the revocations that took effect. A feed
  /// missing from any of them is fully voided (cutoff 0).
  static Map<String, int> _mergeCutoffs(List<ModActionRow> revokes) {
    final maps = [
      for (final r in revokes)
        ((CanonicalJson.decode(r.body)! as Map)['cutoff'] as Map).cast<String, int>(),
    ];
    final feeds = {for (final m in maps) ...m.keys};
    return {
      for (final f in feeds)
        f: maps.map((m) => m[f] ?? 0).reduce((a, b) => a < b ? a : b),
    };
  }

  /// Drops everything a banned root published. If they're ever unbanned,
  /// their feeds are simply pulled again from seq 1.
  Future<void> _purge(RootId root) async {
    await (db.delete(db.posts)..where((x) => x.rootId.equals(root))).go();
    await (db.delete(db.comments)..where((x) => x.rootId.equals(root))).go();
    await (db.delete(db.reactions)..where((x) => x.rootId.equals(root))).go();
    await (db.delete(db.follows)..where((x) => x.rootId.equals(root))).go();
    await (db.delete(db.events)..where((x) => x.rootId.equals(root))).go();
    await (db.delete(db.feeds)..where((x) => x.rootId.equals(root))).go();
    await MediaStore.dropOwnedBy(db, root);
    _log.info('purged banned root ${root.substring(0, 6)}');
  }
}
