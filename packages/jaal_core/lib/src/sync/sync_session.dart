import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:logging/logging.dart';

import '../crypto/crypto.dart';
import '../db/database.dart';
import '../events/event_store.dart';
import '../identity/identity.dart';
import '../messaging/carrier.dart';
import '../messaging/envelope.dart';
import '../media/media_store.dart';
import '../protocol/event.dart';
import '../transport/peer_transport.dart';
import '../util/bytes.dart';
import '../util/canonical_json.dart';
import '../util/clock.dart';
import 'replication_policy.dart';

/// Message type tags on the sync wire (protocol/SPEC.md §7).
abstract final class Msg {
  static const hello = 'hello';
  static const auth = 'auth';
  static const have = 'have';
  static const req = 'req';
  static const events = 'events';
  static const envInv = 'env.inv';
  static const envReq = 'env.req';
  static const envPush = 'env.push';
  static const acks = 'acks';
  static const mediaReq = 'media.req';
  static const mediaChunk = 'media.chunk';
  static const mediaMiss = 'media.miss';
}

enum SessionState { handshaking, live, closed }

/// Counters shown in the Network Lab.
class SessionStats {
  int framesIn = 0, framesOut = 0;
  int bytesIn = 0, bytesOut = 0;
  int eventsIn = 0, eventsOut = 0, eventsRejected = 0;
  int envelopesIn = 0, envelopesOut = 0;
  int acksIn = 0;
  int chunksIn = 0, chunksOut = 0;
}

/// Everything a session needs from its node.
class SyncContext {
  SyncContext({
    required this.me,
    required this.db,
    required this.store,
    required this.carrier,
    required this.policy,
    required this.clock,
    required this.directPeers,
    required this.media,
  });

  final LocalIdentity me;
  final JaalDatabase db;
  final EventStore store;
  final Carrier carrier;
  final ReplicationPolicy policy;
  final Clock clock;
  final MediaStore media;

  /// Roots currently connected (for the "nearby" replication rule).
  final Iterable<RootId> Function() directPeers;
}

/// One sync conversation with one peer over one [PeerConnection].
///
/// Symmetric: both ends run the same state machine.
///   hello → auth → (have / env.inv / acks) ⇄ (req / env.req) ⇄ (events / env.push)
/// and then stay connected, pushing incremental `have`/`env.inv`/`acks`
/// whenever local state changes — that's real-time messaging when peers are
/// in range, and store-and-forward when they aren't.
class SyncSession {
  SyncSession(this.conn, this.ctx,
      {this.handshakeTimeout = const Duration(seconds: 10), Logger? log})
      : _log = log ?? Logger('jaal.sync'),
        _nonce = b64(randomBytes(16));

  final PeerConnection conn;
  final SyncContext ctx;
  final Duration handshakeTimeout;
  final Logger _log;
  final String _nonce;
  final Mutex _sendLock = Mutex();
  final stats = SessionStats();
  final _authed = Completer<void>();

  /// Background work (serving requests, flushing updates) that must finish
  /// before the node may close its database.
  final Set<Future<void>> _inflight = {};

  void _track(Future<void> f) {
    _inflight.add(f);
    f.whenComplete(() => _inflight.remove(f));
  }

  SessionState state = SessionState.handshaking;

  /// True when the peer is banned (see [_onAuth]).
  bool quarantined = false;
  FeedId? peerFeed;
  RootId? peerRoot;
  String? _peerNonce;
  bool _sentAuth = false;

  /// Peer's latest advertised feeds: feed -> (root, seq, moderation feed?).
  final Map<FeedId, (RootId, int, bool)> _peerHave = {};

  /// Feeds requested and the seq we expect to reach.
  final Map<FeedId, int> _pending = {};

  final Map<FeedId, (RootId, int, bool)> _outHave = {};

  /// Max list entries per frame. Keeps every inventory/request message far
  /// below [maxFrameBytes] no matter how much a phone holds.
  static const pageSize = 1000;

  /// Sends `{...base, key: page}` once per [pageSize] slice of [items].
  Future<void> _sendPaged(Map<String, Object?> base, String key, List<Object?> items) async {
    for (var i = 0; i < items.length; i += pageSize) {
      await _send({...base, key: items.sublist(i, i + pageSize > items.length ? items.length : i + pageSize)});
    }
  }

  static List<Object> _haveEntry(FeedId f, RootId r, int seq, bool mod) =>
      mod ? [f, r, seq, 1] : [f, r, seq];
  final Map<String, int> _outEnv = {};
  final Map<String, int> _outAcks = {};

  /// Media chunks asked of this peer and not yet answered ("hash:idx").
  final Set<String> _mediaInflight = {};

  /// Chunks this peer told us it doesn't have.
  final Set<String> _peerLacks = {};
  bool _flushScheduled = false;

  /// Completes once the peer has proven its identity.
  Future<void> get authenticated => _authed.future;

  String get _tag =>
      '${ctx.me.feedId.substring(0, 6)}↔${peerFeed?.substring(0, 6) ?? conn.remoteAddress}';

  /// Runs until the connection closes.
  Future<void> run() async {
    final timer = Timer(handshakeTimeout, () {
      if (state == SessionState.handshaking) {
        _log.warning('$_tag handshake timeout');
        conn.close();
      }
    });
    try {
      await _send({
        't': Msg.hello,
        'v': protocolVersion,
        'feed': ctx.me.feedId,
        'root': ctx.me.rootId,
        'nonce': _nonce,
        'cert': ctx.me.cert.toJson(),
      });
      await for (final frame in conn.frames) {
        stats.framesIn++;
        stats.bytesIn += frame.length;
        try {
          await _handle(frame);
        } on _ProtocolViolation catch (e) {
          _log.warning('$_tag protocol violation: ${e.message}');
          await conn.close();
          break;
        } on FormatException catch (e) {
          _log.warning('$_tag bad frame: ${e.message}');
        } on TransportException {
          rethrow;
        } on Object catch (e, st) {
          // A malformed-but-parseable message (wrong field types, ...) must
          // not take the session down; log and keep going.
          _log.warning('$_tag error handling frame: $e', e, st);
        }
      }
    } on TransportException catch (e) {
      _log.info('$_tag transport: ${e.message}');
    } finally {
      timer.cancel();
      state = SessionState.closed;
      await Future.wait(_inflight.toList());
      if (!_authed.isCompleted) _authed.completeError(StateError('closed'));
      _authed.future.ignore();
    }
  }

  Future<void> close() => conn.close();

  // ---------------------------------------------------------- outgoing

  Future<void> _send(Map<String, Object?> msg) => _sendLock.run(() async {
        if (!conn.isOpen) return;
        final bytes = Uint8List.fromList(utf8.encode(CanonicalJson.encode(msg)));
        stats.framesOut++;
        stats.bytesOut += bytes.length;
        await conn.send(bytes);
      });

  /// Queue a feed update for the peer (coalesced per microtask).
  void notifyFeed(FeedId feed, RootId root, int seq,
      {bool reevaluate = false, bool modFeed = false}) {
    if (state != SessionState.live) return;
    if (quarantined && !modFeed) return;
    _outHave[feed] = (root, seq, modFeed);
    if (reevaluate) _reevaluate = true;
    _scheduleFlush();
  }

  void notifyEnvelope(String id, int exp) {
    if (state != SessionState.live || quarantined) return;
    _outEnv[id] = exp;
    _scheduleFlush();
  }

  void notifyAck(String secret, int exp) {
    if (state != SessionState.live || quarantined) return;
    _outAcks[secret] = exp;
    _scheduleFlush();
  }

  bool _reevaluate = false;

  void _scheduleFlush() {
    if (_flushScheduled) return;
    _flushScheduled = true;
    final done = Completer<void>();
    _track(done.future);
    scheduleMicrotask(() async {
      _flushScheduled = false;
      if (state != SessionState.live) return done.complete();
      try {
        if (_outHave.isNotEmpty) {
          final feeds = [
            for (final e in _outHave.entries) _haveEntry(e.key, e.value.$1, e.value.$2, e.value.$3)
          ];
          _outHave.clear();
          await _sendPaged({'t': Msg.have}, 'feeds', feeds);
        }
        if (_outEnv.isNotEmpty) {
          final ids = [for (final e in _outEnv.entries) [e.key, e.value]];
          _outEnv.clear();
          await _sendPaged({'t': Msg.envInv}, 'ids', ids);
        }
        if (_outAcks.isNotEmpty) {
          final items = [for (final e in _outAcks.entries) [e.key, e.value]];
          _outAcks.clear();
          await _sendPaged({'t': Msg.acks}, 'items', items);
        }
        if (_reevaluate) {
          _reevaluate = false;
          await _requestWanted();
        }
      } on Object catch (e) {
        // Connection dropped or node closing; run() winds down.
        _log.fine('$_tag flush stopped: $e');
      } finally {
        done.complete();
      }
    });
  }

  // ---------------------------------------------------------- incoming

  Future<void> _handle(Uint8List frame) async {
    final msg = CanonicalJson.decodeBytes(frame);
    if (msg is! Map) throw const FormatException('frame is not an object');
    final m = msg.cast<String, Object?>();
    final t = m['t'];

    if (state == SessionState.handshaking) {
      switch (t) {
        case Msg.hello:
          return _onHello(m);
        case Msg.auth:
          return _onAuth(m);
        default:
          throw _ProtocolViolation('$t before handshake');
      }
    }

    if (quarantined && t != Msg.req) return; // accept nothing from them

    switch (t) {
      case Msg.have:
        return _onHave(m);
      case Msg.req:
        _track(_serveReq(m).catchError((Object e) {
          _log.info('$_tag serve failed: $e');
        }));
      case Msg.events:
        return _onEvents(m);
      case Msg.envInv:
        return _onEnvInv(m);
      case Msg.envReq:
        _track(_serveEnvReq(m).catchError((Object e) {
          _log.info('$_tag env serve failed: $e');
        }));
      case Msg.envPush:
        return _onEnvPush(m);
      case Msg.acks:
        return _onAcks(m);
      case Msg.mediaReq:
        _track(_serveMediaReq(m).catchError((Object e) {
          _log.info('$_tag media serve failed: $e');
        }));
      case Msg.mediaChunk:
        return _onMediaChunk(m);
      case Msg.mediaMiss:
        return _onMediaMiss(m);
      default:
        _log.fine('$_tag ignoring unknown message $t');
    }
  }

  static Uint8List _authMessage(FeedId signer, FeedId verifier, String nonce) =>
      concatBytes([
        SigDomain.auth.codeUnits,
        CanonicalJson.encodeBytes({'by': signer, 'for': verifier, 'nonce': nonce}),
      ]);

  Future<void> _onHello(Map<String, Object?> m) async {
    if (peerFeed != null) throw _ProtocolViolation('duplicate hello');
    if (m['v'] != protocolVersion) {
      throw _ProtocolViolation('unsupported version ${m['v']}');
    }
    final cert = DeviceCert.fromJson((m['cert']! as Map).cast<String, Object?>());
    final feed = m['feed']! as String;
    if (cert.device != feed || cert.root != m['root'] || !await cert.verify()) {
      throw _ProtocolViolation('bad device certificate');
    }
    if (feed == ctx.me.feedId) throw _ProtocolViolation('connected to self');
    peerFeed = feed;
    peerRoot = cert.root;
    _peerNonce = m['nonce']! as String;
    // Prove we hold our device key by signing the peer's nonce.
    final sig = await ctx.me.device
        .sign(_authMessage(ctx.me.feedId, feed, _peerNonce!));
    _sentAuth = true;
    await _send({'t': Msg.auth, 'sig': b64(sig)});
  }

  Future<void> _onAuth(Map<String, Object?> m) async {
    if (peerFeed == null || !_sentAuth) throw _ProtocolViolation('auth before hello');
    final ok = await JaalCrypto.verify(
      message: _authMessage(peerFeed!, ctx.me.feedId, _nonce),
      signature: unb64(m['sig']! as String),
      publicKey: unb64(peerFeed!),
    );
    if (!ok) throw _ProtocolViolation('bad auth signature');
    if ((await ctx.db.blockedRoots()).contains(peerRoot)) {
      throw _ProtocolViolation('peer is blocked');
    }
    // Removed by moderators: keep a quarantined session so their (honest)
    // client can learn it was banned. We only serve moderator feeds and
    // accept nothing from them.
    quarantined = (await ctx.db.bannedRoots()).contains(peerRoot);
    state = SessionState.live;
    _authed.complete();
    await ctx.db.notePeerSeen(peerFeed!, peerRoot!, ctx.clock.nowMs());
    _log.info('$_tag live');
    await _sendInventory();
  }

  Future<void> _sendInventory() async {
    final mods = await ctx.db.moderatorRoots();
    final feeds = await ctx.db.allFeeds();
    bool isMod(FeedRow f) => f.purpose == FeedPurpose.moderation;
    await _sendPaged({'t': Msg.have}, 'feeds', [
      for (final f in feeds)
        // Quarantined peers only get moderators' moderation feeds.
        if (f.latestSeq > 0 && (!quarantined || (isMod(f) && mods.contains(f.rootId))))
          _haveEntry(f.feedId, f.rootId, f.latestSeq, isMod(f))
    ]);
    if (quarantined) return;
    final now = ctx.clock.nowMs();
    final envs = await ctx.db.liveEnvelopes(now);
    await _sendPaged({'t': Msg.envInv}, 'ids', [
      for (final e in envs)
        if (e.origin != EnvelopeOrigin.received) [e.id, e.exp]
    ]);
    final acks = await ctx.db.liveAcks(now);
    await _sendPaged({'t': Msg.acks}, 'items', [for (final a in acks) [a.secret, a.exp]]);
    await requestMedia();
  }

  /// Asks the peer for missing chunks of media we expect (a few at a time,
  /// newest posts first). Called after the inventory, after new posts
  /// arrive, and whenever a requested batch has been answered.
  Future<void> requestMedia() async {
    if (state != SessionState.live || quarantined || _mediaInflight.isNotEmpty) {
      return;
    }
    final wanted = await ctx.media.wanted(maxChunks: 8, skip: _peerLacks);
    if (wanted.isEmpty) return;
    for (final (h, idx) in wanted) {
      for (final i in idx) {
        _mediaInflight.add('$h:$i');
      }
    }
    await _send({
      't': Msg.mediaReq,
      'items': [for (final (h, idx) in wanted) [h, idx]],
    });
  }

  Future<void> _serveMediaReq(Map<String, Object?> m) async {
    final miss = <List<Object>>[];
    for (final it in (m['items']! as List).cast<List>()) {
      final hash = it[0] as String;
      final lacking = <int>[];
      for (final i in (it[1] as List).cast<int>().take(32)) {
        if (!conn.isOpen) return;
        final data = await ctx.media.chunk(hash, i);
        if (data == null) {
          lacking.add(i);
          continue;
        }
        await _send({'t': Msg.mediaChunk, 'h': hash, 'i': i, 'd': b64(data)});
        stats.chunksOut++;
      }
      if (lacking.isNotEmpty) miss.add([hash, lacking]);
    }
    if (miss.isNotEmpty) await _send({'t': Msg.mediaMiss, 'items': miss});
  }

  Future<void> _onMediaChunk(Map<String, Object?> m) async {
    final hash = m['h']! as String, i = m['i']! as int;
    _mediaInflight.remove('$hash:$i');
    if (await ctx.media.addChunk(hash, i, unb64(m['d']! as String))) {
      stats.chunksIn++;
    }
    if (_mediaInflight.isEmpty) await requestMedia();
  }

  Future<void> _onMediaMiss(Map<String, Object?> m) async {
    for (final it in (m['items']! as List).cast<List>()) {
      for (final i in (it[1] as List).cast<int>()) {
        final k = '${it[0]}:$i';
        _mediaInflight.remove(k);
        _peerLacks.add(k);
      }
    }
    if (_mediaInflight.isEmpty) await requestMedia();
  }

  Future<void> _onHave(Map<String, Object?> m) async {
    for (final f in (m['feeds']! as List).cast<List>()) {
      final feed = f[0] as String, root = f[1] as String, seq = f[2] as int;
      final mod = f.length > 3 && f[3] == 1;
      final prev = _peerHave[feed];
      if (prev == null || prev.$2 < seq) _peerHave[feed] = (root, seq, mod);
    }
    await _requestWanted();
  }

  final Mutex _wantLock = Mutex();

  /// Requests every feed the peer has ahead of us that our policy wants.
  /// Serialized so concurrent triggers can't issue overlapping requests.
  Future<void> _requestWanted() => _wantLock.run(_requestWantedLocked);

  Future<void> _requestWantedLocked() async {
    if (_peerHave.isEmpty) return;
    final wanted = await ctx.policy.wanted(ctx.db, ctx.me.rootId,
        directPeers: ctx.directPeers(), now: ctx.clock.nowMs());
    final req = <List<Object>>[];
    // Snapshot: _peerHave grows while we await below.
    for (final MapEntry(key: feed, value: (root, seq, mod))
        in _peerHave.entries.toList()) {
      if (!wanted.feed(root, modFeed: mod)) continue;
      final local = (await ctx.db.feed(feed))?.latestSeq ?? 0;
      if (local >= seq) {
        _pending.remove(feed);
        continue;
      }
      final pendingTarget = _pending[feed];
      if (pendingTarget != null && pendingTarget >= seq) continue;
      _pending[feed] = seq;
      req.add([feed, local + 1]);
    }
    await _sendPaged({'t': Msg.req}, 'feeds', req);
  }

  Future<void> _serveReq(Map<String, Object?> m) async {
    const budget = maxFrameBytes - 8 * 1024;
    final mods =
        quarantined ? await ctx.db.moderatorRoots() : const <String>{};
    for (final r in (m['feeds']! as List).cast<List>()) {
      final feed = r[0] as String;
      if (quarantined) {
        final f = await ctx.db.feed(feed);
        if (f == null || f.purpose != FeedPurpose.moderation || !mods.contains(f.rootId)) continue;
      }
      var from = r[1] as int;
      while (conn.isOpen) {
        final items = await ctx.store.readFeed(feed, from, limit: 32);
        if (items.isEmpty) break;
        // Pack as many items as fit in one frame.
        var batch = <Map<String, Object?>>[];
        var size = 64;
        for (final it in items) {
          final j = it.toJson();
          final s = CanonicalJson.encodeBytes(j).length + 1;
          if (batch.isNotEmpty && size + s > budget) {
            await _send({'t': Msg.events, 'items': batch});
            stats.eventsOut += batch.length;
            batch = [];
            size = 64;
          }
          batch.add(j);
          size += s;
        }
        await _send({'t': Msg.events, 'items': batch});
        stats.eventsOut += batch.length;
        from = items.last.event.seq + 1;
        if (items.length < 32) break;
      }
    }
  }

  Future<void> _onEvents(Map<String, Object?> m) async {
    final halted = <FeedId>{};
    var accepted = 0;
    for (final raw in (m['items']! as List)) {
      FeedItem item;
      try {
        item = FeedItem.fromJson((raw as Map).cast<String, Object?>());
      } on Object catch (e) {
        stats.eventsRejected++;
        _log.info('$_tag malformed event: $e');
        continue;
      }
      final feed = item.event.feed;
      if (halted.contains(feed)) continue;
      // Only accept feeds we asked for — no unsolicited pushes.
      if (!_pending.containsKey(feed)) {
        stats.eventsRejected++;
        continue;
      }
      final r = await ctx.store.ingest(item);
      // _pending may change while ingest awaits (re-evaluation can clear it).
      void settle() {
        final target = _pending[feed];
        if (target != null && item.event.seq >= target) _pending.remove(feed);
      }

      switch (r) {
        case Accepted():
          accepted++;
          stats.eventsIn++;
          settle();
        case Duplicate():
          settle();
        case Rejected():
          stats.eventsRejected++;
          halted.add(feed);
          _pending.remove(feed);
      }
    }
    // New follows may have widened what we want from this peer, and new
    // posts may carry media to fetch.
    if (accepted > 0) {
      await _requestWanted();
      await requestMedia();
    }
  }

  Future<void> _onEnvInv(Map<String, Object?> m) async {
    final now = ctx.clock.nowMs();
    final want = <String>[];
    for (final e in (m['ids']! as List).cast<List>()) {
      final id = e[0] as String, exp = e[1] as int;
      if (exp <= now) continue;
      if (await ctx.carrier.knows(id)) continue;
      want.add(id);
    }
    await _sendPaged({'t': Msg.envReq}, 'ids', want);
  }

  Future<void> _serveEnvReq(Map<String, Object?> m) async {
    const budget = maxFrameBytes - 8 * 1024;
    var batch = <Map<String, Object?>>[];
    var size = 64;
    for (final id in (m['ids']! as List).cast<String>()) {
      final env = await ctx.carrier.read(id);
      if (env == null) continue;
      final row = await ctx.db.envelope(id);
      final j = {'env': env.toJson(), 'h': row?.hops ?? 0};
      final s = CanonicalJson.encodeBytes(j).length + 1;
      if (batch.isNotEmpty && size + s > budget) {
        await _send({'t': Msg.envPush, 'items': batch});
        stats.envelopesOut += batch.length;
        batch = [];
        size = 64;
      }
      batch.add(j);
      size += s;
    }
    if (batch.isNotEmpty) {
      await _send({'t': Msg.envPush, 'items': batch});
      stats.envelopesOut += batch.length;
    }
  }

  Future<void> _onEnvPush(Map<String, Object?> m) async {
    for (final raw in (m['items']! as List)) {
      try {
        final j = (raw as Map).cast<String, Object?>();
        final env =
            SealedEnvelope.fromJson((j['env']! as Map).cast<String, Object?>());
        final h = j['h'];
        if (await ctx.carrier.accept(env, hops: h is int && h >= 0 ? h : 0)) {
          stats.envelopesIn++;
        }
      } on Object catch (e) {
        _log.info('$_tag bad envelope: $e');
      }
    }
  }

  Future<void> _onAcks(Map<String, Object?> m) async {
    for (final a in (m['items']! as List).cast<List>()) {
      if (await ctx.carrier.acceptAck(a[0] as String, a[1] as int)) {
        stats.acksIn++;
      }
    }
  }
}

class _ProtocolViolation implements Exception {
  _ProtocolViolation(this.message);
  final String message;
}
