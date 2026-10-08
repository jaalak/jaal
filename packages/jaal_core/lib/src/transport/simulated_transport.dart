import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'peer_transport.dart';

/// Quality of a simulated radio link between two nodes.
class LinkConfig {
  const LinkConfig({
    this.up = true,
    this.latency = Duration.zero,
    this.dropChance = 0,
  });

  /// In range. Taking a link down closes its connections.
  final bool up;

  /// One-way delay applied to every frame (order is preserved).
  final Duration latency;

  /// Probability per frame that the link breaks mid-transfer, used to
  /// exercise resumable sync. Frames are never silently lost: like a real
  /// RFCOMM/TCP stream, a bad link disconnects instead.
  final double dropChance;

  LinkConfig copyWith({bool? up, Duration? latency, double? dropChance}) =>
      LinkConfig(
        up: up ?? this.up,
        latency: latency ?? this.latency,
        dropChance: dropChance ?? this.dropChance,
      );
}

/// Observable things that happen on the simulated network (Network Lab).
sealed class SimNetEvent {
  const SimNetEvent();
}

class LinkChanged extends SimNetEvent {
  const LinkChanged(this.a, this.b, this.config);
  final String a, b;
  final LinkConfig config;
}

class FrameSent extends SimNetEvent {
  const FrameSent(this.from, this.to, this.bytes);
  final String from, to;
  final int bytes;
}

class LinkBroke extends SimNetEvent {
  const LinkBroke(this.a, this.b);
  final String a, b;
}

/// An in-process "radio environment" connecting [SimulatedTransport]s.
/// Links are undirected and down until configured.
class SimNetwork {
  SimNetwork({int seed = 42}) : _rng = Random(seed);

  final Random _rng;
  final Map<String, SimulatedTransport> _nodes = {};
  final Map<String, LinkConfig> _links = {};
  final Set<_SimConn> _conns = {};
  final _events = StreamController<SimNetEvent>.broadcast();

  int framesSent = 0;
  int bytesSent = 0;

  Stream<SimNetEvent> get events => _events.stream;
  Iterable<String> get addresses => _nodes.keys;

  /// Creates a transport bound to [address] on this network.
  SimulatedTransport transport(String address) {
    if (_nodes.containsKey(address)) {
      throw ArgumentError('address $address already in use');
    }
    final t = SimulatedTransport._(this, address);
    _nodes[address] = t;
    return t;
  }

  static String _key(String a, String b) =>
      a.compareTo(b) < 0 ? '$a|$b' : '$b|$a';

  LinkConfig link(String a, String b) =>
      _links[_key(a, b)] ?? const LinkConfig(up: false);

  void setLink(String a, String b, LinkConfig config) {
    final before = link(a, b);
    _links[_key(a, b)] = config;
    _emit(LinkChanged(a, b, config));
    if (before.up == config.up) return;
    final ta = _nodes[a], tb = _nodes[b];
    if (config.up) {
      if (ta != null && tb != null && ta._running && tb._running) {
        ta._see(tb);
        tb._see(ta);
      }
    } else {
      ta?._unsee(b);
      tb?._unsee(a);
      for (final c in _conns.where((c) => c._between(a, b)).toList()) {
        c._break();
      }
    }
  }

  void connectAll(Iterable<String> addrs,
      [LinkConfig config = const LinkConfig()]) {
    final l = addrs.toList();
    for (var i = 0; i < l.length; i++) {
      for (var j = i + 1; j < l.length; j++) {
        setLink(l[i], l[j], config);
      }
    }
  }

  /// Takes every link of [address] down (walked out of range / airplane mode).
  void isolate(String address) {
    for (final other in _nodes.keys) {
      if (other != address && link(address, other).up) {
        setLink(address, other, link(address, other).copyWith(up: false));
      }
    }
  }

  void _started(SimulatedTransport t) {
    for (final other in _nodes.values) {
      if (other != t && other._running && link(t.address, other.address).up) {
        t._see(other);
        other._see(t);
      }
    }
  }

  void _stopped(SimulatedTransport t) {
    for (final other in _nodes.values) {
      if (other != t) other._unsee(t.address);
    }
    for (final c in _conns.where((c) => c._touches(t.address)).toList()) {
      c._break();
    }
  }

  Future<PeerConnection> _connect(SimulatedTransport from, String to) async {
    final target = _nodes[to];
    if (target == null || !target._running) {
      throw TransportException('$to unreachable');
    }
    final cfg = link(from.address, to);
    if (!cfg.up) throw TransportException('$to out of range');
    final a = _SimConn(this, from.address, to);
    final b = _SimConn(this, to, from.address);
    a._peer = b;
    b._peer = a;
    _conns..add(a)..add(b);
    target._incoming.add(b);
    return a;
  }

  bool _shouldBreak(String a, String b) {
    final p = link(a, b).dropChance;
    return p > 0 && _rng.nextDouble() < p;
  }

  void _emit(SimNetEvent e) {
    if (!_events.isClosed) _events.add(e);
  }

  Future<void> dispose() async {
    for (final c in _conns.toList()) {
      c._break();
    }
    await _events.close();
  }
}

/// [PeerTransport] backed by a [SimNetwork].
class SimulatedTransport implements PeerTransport {
  SimulatedTransport._(this._net, this.address);

  final SimNetwork _net;
  final String address;
  bool _running = false;
  Map<String, String> _meta = const {};
  final Set<String> _visible = {};

  final _discovered = StreamController<PeerAdvert>.broadcast();
  final _lost = StreamController<String>.broadcast();
  final _incoming = StreamController<PeerConnection>.broadcast();

  @override
  String get id => 'sim';

  @override
  Stream<PeerAdvert> get discovered => _discovered.stream;

  @override
  Stream<String> get lost => _lost.stream;

  @override
  Stream<PeerConnection> get incoming => _incoming.stream;

  /// Peers currently in range.
  Set<String> get visible => Set.unmodifiable(_visible);

  @override
  Future<void> start(Map<String, String> meta) async {
    _meta = Map.of(meta);
    _running = true;
    // Defer so callers can subscribe to [discovered] after start().
    scheduleMicrotask(() => _net._started(this));
  }

  @override
  Future<void> stop() async {
    _running = false;
    _net._stopped(this);
  }

  @override
  Future<PeerConnection> connect(PeerAdvert peer) {
    if (!_running) throw TransportException('transport stopped');
    return _net._connect(this, peer.address);
  }

  void _see(SimulatedTransport other) {
    if (_visible.add(other.address)) {
      _discovered.add(PeerAdvert(
        address: other.address,
        transport: id,
        meta: other._meta,
        signal: 100,
      ));
    }
  }

  void _unsee(String address) {
    if (_visible.remove(address)) _lost.add(address);
  }
}

class _SimConn implements PeerConnection {
  _SimConn(this._net, this.localAddress, this.remoteAddress);

  final SimNetwork _net;
  final String localAddress;
  @override
  final String remoteAddress;
  late _SimConn _peer;

  final _frames = StreamController<Uint8List>();
  final _closed = Completer<void>();
  Future<void> _deliveryChain = Future.value();
  bool _open = true;

  @override
  String get transport => 'sim';

  @override
  bool get isOpen => _open;

  @override
  Stream<Uint8List> get frames => _frames.stream;

  @override
  Future<void> get closed => _closed.future;

  bool _between(String a, String b) =>
      (localAddress == a && remoteAddress == b) ||
      (localAddress == b && remoteAddress == a);

  bool _touches(String a) => localAddress == a || remoteAddress == a;

  @override
  Future<void> send(Uint8List frame) async {
    if (!_open) throw TransportException('connection closed');
    if (frame.length > maxFrameBytes) {
      throw TransportException('frame of ${frame.length} bytes too large');
    }
    final cfg = _net.link(localAddress, remoteAddress);
    if (!cfg.up) {
      _break();
      throw TransportException('link down');
    }
    if (_net._shouldBreak(localAddress, remoteAddress)) {
      _net._emit(LinkBroke(localAddress, remoteAddress));
      _break();
      throw TransportException('link broke');
    }
    _net.framesSent++;
    _net.bytesSent += frame.length;
    _net._emit(FrameSent(localAddress, remoteAddress, frame.length));
    final copy = Uint8List.fromList(frame);
    final peer = _peer;
    _deliveryChain = _deliveryChain.then((_) async {
      if (cfg.latency > Duration.zero) await Future.delayed(cfg.latency);
      if (peer._open) peer._frames.add(copy);
    });
  }

  @override
  Future<void> close() async {
    if (!_open) return;
    // Let frames already in flight arrive before the remote sees the close.
    await _deliveryChain;
    _break();
  }

  void _break() {
    if (_open) {
      _open = false;
      _net._conns.remove(this);
      _frames.close();
      _closed.complete();
    }
    if (_peer._open) _peer._break();
  }
}
