import 'dart:async';

import 'package:logging/logging.dart';

import '../events/event_store.dart';
import '../identity/identity.dart';
import '../messaging/carrier.dart';
import '../protocol/event.dart';
import '../transport/peer_transport.dart';
import 'sync_session.dart';

/// Owns transports and sessions: connects to discovered peers, runs a
/// [SyncSession] per link, fans local changes out to live sessions and
/// reconnects when peers come back into range.
class SyncEngine {
  SyncEngine(this.ctx, this.transports,
      {this.retryDelay = const Duration(seconds: 2), Logger? log})
      : _log = log ?? Logger('jaal.engine');

  final SyncContext ctx;
  final List<PeerTransport> transports;
  final Duration retryDelay;
  final Logger _log;

  final Map<String, PeerAdvert> _visible = {};
  final Set<String> _dialing = {};
  final Map<String, SyncSession> _byLink = {};
  final List<StreamSubscription<Object?>> _subs = [];
  final Map<String, Timer> _retries = {};
  final Set<Future<void>> _runs = {};
  final _sessionsChanged = StreamController<void>.broadcast();
  bool _running = false;

  /// Live (authenticated) sessions.
  Iterable<SyncSession> get sessions =>
      _byLink.values.where((s) => s.state == SessionState.live);

  /// All sessions including handshaking ones.
  Iterable<SyncSession> get allSessions => _byLink.values;

  Iterable<RootId> get connectedRoots =>
      sessions.map((s) => s.peerRoot).whereType<RootId>();

  Iterable<PeerAdvert> get visiblePeers => _visible.values;

  /// Fires whenever sessions open or close.
  Stream<void> get sessionsChanged => _sessionsChanged.stream;

  Future<void> start() async {
    _running = true;
    _subs.add(ctx.store.changes.listen(_onStored));
    _subs.add(ctx.carrier.changes.listen(_onCarrier));
    // A chunk arriving on one link may unblock requests on idle others.
    _subs.add(ctx.media.changes.listen((_) {
      for (final s in sessions) {
        unawaited(s.requestMedia().catchError((_) {}));
      }
    }));
    for (final t in transports) {
      _subs.add(t.discovered.listen(_onDiscovered));
      _subs.add(t.lost.listen((addr) => _visible.remove('${t.id}:$addr')));
      _subs.add(t.incoming.listen(_onIncoming));
      await t.start({'feed': ctx.me.feedId});
    }
  }

  Future<void> stop() async {
    _running = false;
    for (final r in _retries.values) {
      r.cancel();
    }
    _retries.clear();
    for (final s in _subs) {
      await s.cancel();
    }
    _subs.clear();
    for (final s in _byLink.values.toList()) {
      await s.close();
    }
    for (final t in transports) {
      await t.stop();
    }
    // Let sessions finish in-flight work before the database closes.
    await Future.wait(_runs.toList())
        .timeout(const Duration(seconds: 5), onTimeout: () => const []);
    await _sessionsChanged.close();
  }

  void _onStored(StoredEvent s) {
    final mod = EventType.isModeration(s.event.type);
    // Follows and moderator changes widen/narrow what we want from peers.
    final reevaluate = mod || s.event.type == EventType.follow;
    final banned = ctx.store.moderation?.banned ?? const <RootId>{};
    for (final session in sessions.toList()) {
      if (mod && !session.quarantined && banned.contains(session.peerRoot)) {
        // Newly removed by moderators: the reconnect lands in quarantine.
        session.close();
        continue;
      }
      session.notifyFeed(s.event.feed, s.root, s.event.seq,
          reevaluate: reevaluate, modFeed: s.modFeed);
    }
  }

  void _onCarrier(CarrierChange c) {
    for (final session in sessions) {
      switch (c) {
        case EnvelopeStored(:final id, :final exp):
          session.notifyEnvelope(id, exp);
        case AckLearned(:final secret, :final exp):
          session.notifyAck(secret, exp);
        case MessageReceived():
          break;
      }
    }
  }

  void _onDiscovered(PeerAdvert p) {
    _visible[p.key] = p;
    _maybeDial(p);
  }

  /// Exactly one side dials: the one with the smaller feed id. If the advert
  /// carries no feed hint, both may dial and the duplicate is dropped after
  /// the handshake.
  void _maybeDial(PeerAdvert p) {
    if (!_running) return;
    if (_byLink.containsKey(p.key) || _dialing.contains(p.key)) return;
    final theirFeed = p.meta['feed'];
    if (theirFeed != null && theirFeed.compareTo(ctx.me.feedId) < 0) return;
    if (theirFeed != null && _hasSessionWithFeed(theirFeed)) return;
    final t = transports.firstWhere((t) => t.id == p.transport);
    _dialing.add(p.key);
    t.connect(p).then((conn) {
      _dialing.remove(p.key);
      _run(p.key, conn);
    }, onError: (Object e) {
      _dialing.remove(p.key);
      _log.info('dial ${p.key} failed: $e');
      _scheduleRetry(p.key);
    });
  }

  bool _hasSessionWithFeed(String feed) =>
      _byLink.values.any((s) => s.peerFeed == feed);

  int _adopted = 0;

  /// Runs a session over a link created outside the transports' discovery,
  /// e.g. a WebRTC data channel set up by scanning QR codes.
  void adopt(PeerConnection conn) => _run('${conn.transport}:adopted-${_adopted++}', conn);

  void _onIncoming(PeerConnection conn) =>
      _run('${conn.transport}:${conn.remoteAddress}', conn);

  void _run(String key, PeerConnection conn) {
    if (!_running) {
      conn.close();
      return;
    }
    final session = SyncSession(conn, ctx);
    final old = _byLink[key];
    _byLink[key] = session;
    if (old != null) old.close();

    session.authenticated.then((_) {
      // Drop duplicates (both sides dialed over different links/transports).
      final dupes = _byLink.entries.where((e) =>
          e.value != session &&
          e.value.peerFeed == session.peerFeed &&
          e.value.state == SessionState.live);
      if (dupes.isNotEmpty) {
        _log.fine('dropping duplicate session with ${session.peerFeed}');
        session.close();
        return;
      }
      if (!_sessionsChanged.isClosed) _sessionsChanged.add(null);
    }, onError: (_) {});

    late final Future<void> run;
    run = session.run().whenComplete(() {
      _runs.remove(run);
      if (_byLink[key] == session) _byLink.remove(key);
      if (!_sessionsChanged.isClosed) _sessionsChanged.add(null);
      _scheduleRetry(key);
    });
    _runs.add(run);
  }

  void _scheduleRetry(String key) {
    if (!_running) return;
    _retries[key]?.cancel();
    _retries[key] = Timer(retryDelay, () {
      _retries.remove(key);
      final p = _visible[key];
      if (p != null) _maybeDial(p);
    });
  }
}
