import 'package:drift/drift.dart';
import 'package:logging/logging.dart';

import '../crypto/crypto.dart';
import '../db/database.dart';
import '../identity/identity.dart';
import '../identity/lookalike.dart';
import '../media/media_store.dart';
import '../moderation/moderation_engine.dart';
import '../protocol/event.dart';
import '../util/bytes.dart';
import '../util/canonical_json.dart';

/// Last-writer-wins ordering: Lamport clock, then event id as tie-break.
bool lwwNewer(int lamport, String id, int otherLamport, String otherId) =>
    lamport > otherLamport ||
    (lamport == otherLamport && id.compareTo(otherId) > 0);

/// Signature domain for device revocations.
const revokeDomain = 'jaal-revoke-v1:';

/// Folds validated events into the projection tables. Must be called inside
/// the same transaction that stored the event.
class Projector {
  Projector(this.db, this.me, {this.moderation, Logger? log})
      : _log = log ?? Logger('jaal.projector');

  final JaalDatabase db;
  final LocalIdentity me;
  final ModerationEngine? moderation;
  final Logger _log;

  Future<void> apply({
    required SignedEvent e,
    required Map<String, Object?>? body,
    required RootId author,
    required int hops,
    required int firstSeenAt,
  }) async {
    if (body == null) return; // redacted on arrival: nothing to project
    switch (e.type) {
      case EventType.profile:
        await _profile(e, body, author);
      case EventType.post:
        await _post(e, body, author, hops, firstSeenAt);
      case EventType.postEdit:
        await _postEdit(e, body, author);
      case EventType.delete:
        await _delete(e, body, author);
      case EventType.reaction:
        await _reaction(e, body, author);
      case EventType.comment:
        await _comment(e, body, author);
      case EventType.follow:
        await _follow(e, body, author);
      case EventType.selfPrivate:
        await _selfPrivate(e, body, author);
      case EventType.deviceRevoke:
        await _revoke(e, body, author);
      case EventType.modVouch || EventType.modRevoke || EventType.modBan:
        await moderation?.record(e, body, author);
      default:
        break; // device.cert handled at ingest; unknown types not projected
    }
  }

  Future<void> _profile(
      SignedEvent e, Map<String, Object?> b, RootId author) async {
    final cur = await db.profile(author);
    if (cur != null && !lwwNewer(e.lamport, e.id, cur.lamport, cur.eventId)) {
      return;
    }
    await db.into(db.profiles).insertOnConflictUpdate(ProfilesCompanion.insert(
          rootId: author,
          name: b['name']! as String,
          handle: b['handle']! as String,
          bio: Value(b['bio'] as String? ?? ''),
          dmKey: b['dm']! as String,
          avatar: Value(
              b['avatar'] == null ? null : CanonicalJson.encode(b['avatar'])),
          lamport: e.lamport,
          eventId: e.id,
          handleSkel: Value(Lookalikes.skeleton(b['handle']! as String)),
          nameSkel: Value(Lookalikes.skeleton(b['name']! as String)),
        ));
    await MediaStore.expect(db, b['avatar'], owner: author, now: e.ts);
  }

  Future<TombstoneRow?> _tombstoneFor(String target, RootId author) async {
    final t = await (db.select(db.tombstones)
          ..where((t) => t.target.equals(target)))
        .getSingleOrNull();
    return t != null && t.byRoot == author ? t : null;
  }

  Future<void> _post(SignedEvent e, Map<String, Object?> b, RootId author,
      int hops, int firstSeenAt) async {
    final tomb = await _tombstoneFor(e.id, author);
    await db.into(db.posts).insert(
          PostsCompanion.insert(
            id: e.id,
            rootId: author,
            feedId: e.feed,
            body: tomb == null ? b['text']! as String : '',
            media: Value(tomb == null ? CanonicalJson.encode(b['media']) : '[]'),
            ts: e.ts,
            lamport: e.lamport,
            hops: Value(hops),
            firstSeenAt: firstSeenAt,
            deleted: Value(tomb != null),
          ),
          mode: InsertMode.insertOrIgnore,
        );
    if (tomb != null) {
      await _eraseEventBody(e.id);
    } else {
      for (final m in (b['media'] as List? ?? const [])) {
        await MediaStore.expect(db, m, owner: author, now: firstSeenAt);
      }
    }
  }

  Future<void> _postEdit(
      SignedEvent e, Map<String, Object?> b, RootId author) async {
    final p = await db.post(b['target']! as String);
    if (p == null || p.rootId != author || p.deleted) return;
    if (!lwwNewer(e.lamport, e.id, p.editLamport, p.editId ?? '')) return;
    await (db.update(db.posts)..where((x) => x.id.equals(p.id))).write(
        PostsCompanion(
            body: Value(b['text']! as String),
            editLamport: Value(e.lamport),
            editId: Value(e.id)));
  }

  Future<void> _delete(
      SignedEvent e, Map<String, Object?> b, RootId author) async {
    final target = b['target']! as String;
    await db.into(db.tombstones).insert(
        TombstonesCompanion.insert(
            target: target, byRoot: author, lamport: e.lamport, eventId: e.id),
        mode: InsertMode.insertOrIgnore);

    final p = await db.post(target);
    if (p != null && p.rootId == author && !p.deleted) {
      for (final m in (CanonicalJson.decode(p.media) as List? ?? const [])) {
        final h = m is Map ? m['hash'] : null;
        if (h is String) await MediaStore.drop(db, h);
      }
      await (db.update(db.posts)..where((x) => x.id.equals(target))).write(
          const PostsCompanion(
              body: Value(''), media: Value('[]'), deleted: Value(true)));
      await _eraseEventBody(target);
      // Erase edits too: their bodies carry the old text.
      final edits = await (db.select(db.events)
            ..where((x) =>
                x.type.equals(EventType.postEdit) & x.rootId.equals(author)))
          .get();
      for (final ed in edits) {
        final eb = ed.body == null ? null : CanonicalJson.decode(ed.body!);
        if (eb is Map && eb['target'] == target) await _eraseEventBody(ed.id);
      }
    }
    final c = await (db.select(db.comments)
          ..where((x) => x.id.equals(target)))
        .getSingleOrNull();
    if (c != null && c.rootId == author && !c.deleted) {
      await (db.update(db.comments)..where((x) => x.id.equals(target)))
          .write(const CommentsCompanion(body: Value(''), deleted: Value(true)));
      await _eraseEventBody(target);
    }
  }

  Future<void> _eraseEventBody(String eventId) async {
    await (db.update(db.events)..where((x) => x.id.equals(eventId)))
        .write(const EventsCompanion(body: Value(null)));
  }

  Future<void> _reaction(
      SignedEvent e, Map<String, Object?> b, RootId author) async {
    final target = b['target']! as String;
    final cur = await (db.select(db.reactions)
          ..where((r) => r.rootId.equals(author) & r.target.equals(target)))
        .getSingleOrNull();
    if (cur != null && !lwwNewer(e.lamport, e.id, cur.lamport, cur.eventId)) {
      return;
    }
    await db.into(db.reactions).insertOnConflictUpdate(ReactionsCompanion.insert(
          rootId: author,
          target: target,
          sticker: Value(b['sticker'] as String?),
          x: b['x']! as int,
          y: b['y']! as int,
          rot: b['rot']! as int,
          lamport: e.lamport,
          eventId: e.id,
        ));
  }

  Future<void> _comment(
      SignedEvent e, Map<String, Object?> b, RootId author) async {
    final tomb = await _tombstoneFor(e.id, author);
    await db.into(db.comments).insert(
          CommentsCompanion.insert(
            id: e.id,
            target: b['target']! as String,
            rootId: author,
            body: tomb == null ? b['text']! as String : '',
            parent: Value(b['parent'] as String?),
            ts: e.ts,
            lamport: e.lamport,
            deleted: Value(tomb != null),
          ),
          mode: InsertMode.insertOrIgnore,
        );
    if (tomb != null) await _eraseEventBody(e.id);
  }

  Future<void> _follow(
      SignedEvent e, Map<String, Object?> b, RootId author) async {
    final target = b['target']! as String;
    final cur = await (db.select(db.follows)
          ..where((f) => f.rootId.equals(author) & f.target.equals(target)))
        .getSingleOrNull();
    if (cur != null && !lwwNewer(e.lamport, e.id, cur.lamport, cur.eventId)) {
      return;
    }
    await db.into(db.follows).insertOnConflictUpdate(FollowsCompanion.insert(
          rootId: author,
          target: target,
          isOn: b['on']! as bool,
          lamport: e.lamport,
          eventId: e.id,
        ));
  }

  /// `self.private` events are encrypted to the author's own devices. v1
  /// carries one kind: the private block list (last-writer-wins).
  Future<void> _selfPrivate(
      SignedEvent e, Map<String, Object?> b, RootId author) async {
    if (author != me.rootId) return; // opaque to everyone else
    final clear = await JaalCrypto.open(
      key: me.root.selfKey,
      nonce: unb64(b['nonce']! as String),
      sealed: unb64(b['ct']! as String),
      aad: e.feed.codeUnits,
    );
    if (clear == null) {
      _log.warning('self.private ${e.id} failed to decrypt');
      return;
    }
    final inner = CanonicalJson.decodeBytes(clear);
    if (inner is! Map || inner['kind'] != 'blocks') return;
    if (e.lamport <= await db.stat('self.blocks.lamport')) return;
    final roots = (inner['roots'] as List).cast<String>();
    await db.delete(db.blocks).go();
    for (final r in roots) {
      await db.into(db.blocks).insert(BlocksCompanion.insert(rootId: r, since: e.ts));
    }
    await db.customStatement(
        'INSERT INTO stats (key, value) VALUES (?, ?) '
        'ON CONFLICT(key) DO UPDATE SET value = excluded.value',
        ['self.blocks.lamport', e.lamport]);
  }

  Future<void> _revoke(
      SignedEvent e, Map<String, Object?> b, RootId author) async {
    final device = b['device']! as String;
    final afterSeq = b['afterSeq']! as int;
    final ok = await JaalCrypto.verify(
      message: concatBytes([
        revokeDomain.codeUnits,
        CanonicalJson.encodeBytes({'device': device, 'afterSeq': afterSeq}),
      ]),
      signature: unb64(b['rootSig']! as String),
      publicKey: unb64(author),
    );
    if (!ok) {
      _log.warning('device.revoke ${e.id} has a bad root signature');
      return;
    }
    final f = await db.feed(device);
    if (f != null && f.rootId != author) return;
    await db.into(db.feeds).insertOnConflictUpdate(FeedsCompanion(
          feedId: Value(device),
          rootId: Value(author),
          latestSeq: Value(f?.latestSeq ?? 0),
          latestId: Value(f?.latestId),
          latestLamport: Value(f?.latestLamport ?? 0),
          revokedAfterSeq: Value(afterSeq),
        ));
  }
}
