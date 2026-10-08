import 'dart:async';

import 'package:drift/drift.dart';
import 'package:logging/logging.dart';

import '../db/database.dart';
import '../identity/identity.dart';
import '../moderation/moderation_engine.dart';
import '../protocol/bodies.dart';
import '../protocol/event.dart';
import '../crypto/crypto.dart';
import '../util/bytes.dart';
import '../util/canonical_json.dart';
import '../util/clock.dart';
import 'projector.dart';

/// Why an incoming event was refused. Surfaced in debug tools.
enum RejectReason {
  malformed,
  badSignature,
  badBodyHash,
  invalidBody,
  gap,
  forkedChain,
  lamportNotIncreasing,
  badDeviceCert,
  rootMismatch,
  revoked,
  blocked,
  banned,
}

sealed class IngestResult {
  const IngestResult();
}

class Accepted extends IngestResult {
  const Accepted(this.event);
  final SignedEvent event;
}

class Duplicate extends IngestResult {
  const Duplicate();
}

class Rejected extends IngestResult {
  const Rejected(this.reason, [this.detail]);
  final RejectReason reason;
  final String? detail;
  @override
  String toString() => 'Rejected($reason${detail == null ? '' : ': $detail'})';
}

/// Thrown when a banned user's own (honest) client tries to publish.
class BannedException implements Exception {
  const BannedException();
  @override
  String toString() => 'removed by moderators: this identity can no longer post';
}

/// Notification emitted after an event is committed.
class StoredEvent {
  const StoredEvent(this.event, this.root, {required this.local, this.modFeed = false});
  final SignedEvent event;
  final RootId root;

  /// True when the event lives in a moderation feed.
  final bool modFeed;

  /// True when authored by this node.
  final bool local;
}

/// Owns the replicated log: appends local events, validates and ingests
/// remote ones, and keeps projections in step (protocol/SPEC.md §5).
class EventStore {
  EventStore({
    required this.db,
    required this.me,
    required this.clock,
    this.moderation,
    Logger? log,
  })  : _log = log ?? Logger('jaal.events'),
        projector = Projector(db, me, moderation: moderation, log: log);

  final JaalDatabase db;
  final LocalIdentity me;
  final Clock clock;
  final Projector projector;

  /// Null in low-level tests; always present in a [JaalNode].
  final ModerationEngine? moderation;
  final Logger _log;
  final Mutex _lock = Mutex();
  final _changes = StreamController<StoredEvent>.broadcast(sync: true);

  /// Fires once per committed event (local or remote).
  Stream<StoredEvent> get changes => _changes.stream;

  /// Ensures our own feed exists and starts with our device certificate.
  Future<void> init() async {
    final f = await db.feed(me.feedId);
    if (f == null || f.latestSeq == 0) {
      await append(EventType.deviceCert, me.cert.toJson());
    }
  }

  /// Appends an event to our own feed. `mod.*` events go to this device's
  /// separate moderation feed (protocol/SPEC.md §10.4).
  Future<SignedEvent> append(String type, Map<String, Object?> body) {
    final err = Bodies.validate(type, body);
    if (err != null) throw ArgumentError('invalid $type body: $err');
    if (moderation?.isBanned(me.rootId) ?? false) {
      throw const BannedException();
    }
    return _lock.run(() async {
      final isMod = EventType.isModeration(type);
      var key = me.device;
      if (isMod) {
        final (modKey, modCert) = await me.moderationFeed();
        key = modKey;
        final mf = await db.feed(b64(modKey.publicKey));
        if (mf == null || mf.latestSeq == 0) {
          final c = await _write(modKey, EventType.deviceCert, modCert.toJson());
          _changes.add(StoredEvent(c, me.rootId, local: true, modFeed: true));
        }
      }
      final e = await _write(key, type, body);
      _log.fine('append $e');
      if (isMod) await moderation?.recompute();
      _changes.add(StoredEvent(e, me.rootId, local: true, modFeed: isMod));
      return e;
    });
  }

  Future<SignedEvent> _write(SigningKey key, String type, Map<String, Object?> body) async {
    late SignedEvent e;
    await db.transaction(() async {
      final f = await db.feed(b64(key.publicKey));
      final lamport = (await db.maxLamport()) + 1;
      e = await SignedEvent.create(
        device: key,
        seq: (f?.latestSeq ?? 0) + 1,
        prev: f?.latestId,
        lamport: lamport,
        ts: clock.nowMs(),
        type: type,
        body: body,
      );
      await _store(e, body, me.rootId, hops: 0);
    });
    return e;
  }

  /// Validates and stores an event received from a peer. Events for a feed
  /// must arrive in sequence order; the sync engine guarantees this.
  Future<IngestResult> ingest(FeedItem item) => _lock.run(() async {
        final r = await _ingest(item);
        if (r is Rejected) _log.info('reject ${item.event}: $r');
        return r;
      });

  Future<IngestResult> _ingest(FeedItem item) async {
    final e = item.event;

    if (await db.eventById(e.id) != null) return const Duplicate();

    final body = item.body;
    if (body != null) {
      if (SignedEvent.hashBody(body) != e.bodyHash) {
        return const Rejected(RejectReason.badBodyHash);
      }
      final err = Bodies.validate(e.type, body);
      if (err != null) return Rejected(RejectReason.invalidBody, err);
    }

    final f = await db.feed(e.feed);
    final latestSeq = f?.latestSeq ?? 0;
    if (e.seq <= latestSeq) {
      // Same position, different id: the author signed two histories.
      return const Rejected(RejectReason.forkedChain);
    }
    if (e.seq != latestSeq + 1) {
      return Rejected(RejectReason.gap, 'have $latestSeq, got ${e.seq}');
    }
    if (e.prev != f?.latestId) return const Rejected(RejectReason.forkedChain);
    if (f != null && f.latestSeq > 0 && e.lamport <= f.latestLamport) {
      return const Rejected(RejectReason.lamportNotIncreasing);
    }
    if (f?.revokedAfterSeq != null && e.seq > f!.revokedAfterSeq!) {
      return const Rejected(RejectReason.revoked);
    }
    if (!await e.verifySignature()) {
      return const Rejected(RejectReason.badSignature);
    }

    // Establish which root owns this feed.
    RootId root;
    var modFeed = f?.purpose == FeedPurpose.moderation;
    if (e.seq == 1) {
      if (e.type != EventType.deviceCert || body == null) {
        return const Rejected(RejectReason.badDeviceCert, 'seq 1 must be device.cert');
      }
      final cert = DeviceCert.fromJson(body);
      if (cert.device != e.feed || !await cert.verify()) {
        return const Rejected(RejectReason.badDeviceCert);
      }
      if (f != null && f.rootId != cert.root) {
        return const Rejected(RejectReason.rootMismatch);
      }
      root = cert.root;
      modFeed = cert.isModeration;
    } else {
      root = f!.rootId;
      // Moderation feeds carry moderation and nothing else.
      if (modFeed && !EventType.isModeration(e.type)) {
        return const Rejected(RejectReason.invalidBody, 'moderation feed may only hold mod.* events');
      }
    }

    if (await _isBlocked(root)) return const Rejected(RejectReason.blocked);
    if (moderation?.isBanned(root) ?? false) {
      return const Rejected(RejectReason.banned);
    }

    await db.transaction(() => _store(e, body, root, hops: item.hops + 1));
    if (EventType.isModeration(e.type)) await moderation?.recompute();
    _changes.add(StoredEvent(e, root, local: false, modFeed: modFeed));
    return Accepted(e);
  }

  Future<bool> _isBlocked(RootId root) async =>
      await (db.select(db.blocks)..where((b) => b.rootId.equals(root)))
          .getSingleOrNull() !=
      null;

  Future<void> _store(SignedEvent e, Map<String, Object?>? body, RootId root,
      {required int hops}) async {
    final now = clock.nowMs();
    await db.into(db.events).insert(EventsCompanion.insert(
          id: e.id,
          feedId: e.feed,
          seq: e.seq,
          rootId: root,
          lamport: e.lamport,
          ts: e.ts,
          type: e.type,
          raw: e.toCanonical(),
          body: Value(body == null ? null : CanonicalJson.encode(body)),
          hops: Value(hops),
          firstSeenAt: now,
        ));
    final existing = await db.feed(e.feed);
    final purpose = e.seq == 1 && body != null && body['purpose'] == DeviceCert.modPurpose
        ? FeedPurpose.moderation
        : existing?.purpose ?? FeedPurpose.normal;
    await db.into(db.feeds).insertOnConflictUpdate(FeedsCompanion(
          purpose: Value(purpose),
          feedId: Value(e.feed),
          rootId: Value(root),
          latestSeq: Value(e.seq),
          latestId: Value(e.id),
          latestLamport: Value(e.lamport),
          revokedAfterSeq: Value(existing?.revokedAfterSeq),
        ));
    await projector.apply(
        e: e, body: body, author: root, hops: hops, firstSeenAt: now);
  }

  /// Reads events of [feedId] starting at [fromSeq] in wire form.
  Future<List<FeedItem>> readFeed(String feedId, int fromSeq,
      {int limit = 64}) async {
    final rows = await db.eventsFrom(feedId, fromSeq, limit: limit);
    return [
      for (final r in rows)
        FeedItem(
          SignedEvent.parse(r.raw),
          r.body == null
              ? null
              : (CanonicalJson.decode(r.body!)! as Map).cast<String, Object?>(),
          r.hops,
        ),
    ];
  }

  Future<void> dispose() => _changes.close();
}
