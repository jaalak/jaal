import 'dart:async';
import 'dart:typed_data';

/// Largest frame any transport must accept (protocol/SPEC.md §7.1). Sync
/// batches and media chunks are sized to fit.
const int maxFrameBytes = 256 * 1024;

/// A nearby peer announced by a transport's discovery mechanism
/// (BLE advertisement, Wi-Fi Direct service record, simulator, ...).
class PeerAdvert {
  const PeerAdvert({
    required this.address,
    required this.transport,
    this.meta = const {},
    this.signal,
  });

  /// Transport-specific address (MAC, endpoint id, sim address, ...).
  final String address;

  /// [PeerTransport.id] of the transport that saw it.
  final String transport;

  /// Small unauthenticated hints, e.g. `{'feed': '<b64 device key>'}`.
  /// Never trusted — identity is proven by the sync handshake.
  final Map<String, String> meta;

  /// Relative signal strength 0..100 when the transport knows it.
  final int? signal;

  String get key => '$transport:$address';

  @override
  String toString() => 'Peer($key)';
}

/// A reliable, ordered, message-framed duplex link to one peer.
///
/// Implementations: SimulatedTransport (now), Bluetooth RFCOMM / BLE L2CAP,
/// Wi-Fi Direct sockets, LAN TCP (later). The sync engine only sees this.
abstract interface class PeerConnection {
  String get remoteAddress;
  String get transport;
  bool get isOpen;

  /// Incoming frames, in order. Single subscription.
  Stream<Uint8List> get frames;

  /// Completes when the link closes for any reason.
  Future<void> get closed;

  Future<void> send(Uint8List frame);
  Future<void> close();
}

/// Abstraction every physical or simulated network implements. The
/// application layer never touches radios directly.
abstract interface class PeerTransport {
  /// Stable id: `sim`, `ble`, `wifi-direct`, `lan`, ...
  String get id;

  /// Peers coming into range.
  Stream<PeerAdvert> get discovered;

  /// Addresses of peers going out of range.
  Stream<String> get lost;

  /// Connections initiated by remote peers.
  Stream<PeerConnection> get incoming;

  /// Starts advertising [meta] and discovering peers.
  Future<void> start(Map<String, String> meta);

  Future<void> stop();

  Future<PeerConnection> connect(PeerAdvert peer);
}

class TransportException implements Exception {
  TransportException(this.message);
  final String message;
  @override
  String toString() => 'TransportException: $message';
}
