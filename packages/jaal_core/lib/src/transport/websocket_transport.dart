import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'peer_transport.dart';

/// [PeerTransport] over WebSockets (dart:io): one binary message per frame.
///
/// Used for LAN peers (same hotspot, no internet) and for cross-language
/// interop tests with the browser client. Discovery is manual: call
/// [dial] with a `ws://host:port` address, or let peers dial the server.
class WebSocketTransport implements PeerTransport {
  WebSocketTransport({this.port = 0, this.address});

  /// Port to listen on (0 = pick a free one; see [boundPort]).
  final int port;
  final InternetAddress? address;

  HttpServer? _server;
  final _discovered = StreamController<PeerAdvert>.broadcast();
  final _lost = StreamController<String>.broadcast();
  final _incoming = StreamController<PeerConnection>.broadcast();

  int? get boundPort => _server?.port;

  @override
  String get id => 'ws';

  @override
  Stream<PeerAdvert> get discovered => _discovered.stream;

  @override
  Stream<String> get lost => _lost.stream;

  @override
  Stream<PeerConnection> get incoming => _incoming.stream;

  @override
  Future<void> start(Map<String, String> meta) async {
    final s = await HttpServer.bind(address ?? InternetAddress.anyIPv4, port);
    _server = s;
    s.listen((req) async {
      if (!WebSocketTransformer.isUpgradeRequest(req)) {
        req.response
          ..statusCode = HttpStatus.badRequest
          ..close();
        return;
      }
      final ws = await WebSocketTransformer.upgrade(req);
      _incoming.add(_WsConn(ws, '${req.connectionInfo?.remoteAddress.address}'));
    });
  }

  /// Connects to `ws://host:port` and hands the link to the sync engine.
  Future<PeerConnection> dial(String url) async {
    final ws = await WebSocket.connect(url);
    final c = _WsConn(ws, url);
    _incoming.add(c);
    return c;
  }

  @override
  Future<PeerConnection> connect(PeerAdvert peer) => dial(peer.address);

  @override
  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }
}

class _WsConn implements PeerConnection {
  _WsConn(this._ws, this.remoteAddress) {
    _ws.listen(
      (m) {
        if (m is List<int>) {
          _frames.add(Uint8List.fromList(m));
        } else if (m is String) {
          _frames.add(Uint8List.fromList(m.codeUnits));
        }
      },
      onDone: _done,
      onError: (_) => _done(),
    );
  }

  final WebSocket _ws;
  @override
  final String remoteAddress;
  final _frames = StreamController<Uint8List>();
  final _closed = Completer<void>();

  @override
  String get transport => 'ws';

  @override
  bool get isOpen => !_closed.isCompleted;

  @override
  Stream<Uint8List> get frames => _frames.stream;

  @override
  Future<void> get closed => _closed.future;

  @override
  Future<void> send(Uint8List frame) async {
    if (!isOpen) throw TransportException('connection closed');
    if (frame.length > maxFrameBytes) throw TransportException('frame too large');
    _ws.add(frame);
  }

  @override
  Future<void> close() async {
    await _ws.close();
    _done();
  }

  void _done() {
    if (_closed.isCompleted) return;
    _frames.close();
    _closed.complete();
  }
}
