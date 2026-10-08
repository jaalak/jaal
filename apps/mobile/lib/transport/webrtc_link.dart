import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:jaal_core/jaal_core.dart' as jaal;

/// WebRTC data channel to an iPhone (or any browser) on the same Wi-Fi /
/// hotspot, set up by swapping two QR codes — no server, no internet.
///
///   this phone: offer = await JaalRtc.createOffer();  show QR(offer.code)
///   iphone:     scans, shows its answer QR
///   this phone: conn = await offer.accept(answerCode)
///
/// or the reverse with [JaalRtc.answer]. Codes and framing are shared with
/// apps/pwa/src/core/webrtc.ts via [jaal.RtcSignal].
abstract final class JaalRtc {
  static const _config = <String, dynamic>{'iceServers': <Map<String, dynamic>>[]};

  static Future<RtcOffer> createOffer() async {
    final pc = await createPeerConnection(_config);
    final ch = await pc.createDataChannel('jaal', RTCDataChannelInit()..ordered = true);
    await pc.setLocalDescription(await pc.createOffer());
    await _iceComplete(pc);
    final desc = await pc.getLocalDescription();
    return RtcOffer._(pc, ch, jaal.RtcSignal.encode('o', desc!.sdp!));
  }

  /// Answers a scanned offer. Returns the answer code to show, and the link
  /// that opens once the other phone scans it.
  static Future<({String code, Future<jaal.PeerConnection> connection})> answer(String offerCode) async {
    final o = jaal.RtcSignal.decode(offerCode);
    if (o.kind != 'o') throw const FormatException('that is a reply code — scan their first code');
    final pc = await createPeerConnection(_config);
    final conn = Completer<jaal.PeerConnection>();
    pc.onDataChannel = (ch) async {
      await _channelOpen(ch);
      if (!conn.isCompleted) conn.complete(RtcConnection._(pc, ch));
    };
    await pc.setRemoteDescription(RTCSessionDescription(o.sdp, 'offer'));
    await pc.setLocalDescription(await pc.createAnswer());
    await _iceComplete(pc);
    final desc = await pc.getLocalDescription();
    return (code: jaal.RtcSignal.encode('a', desc!.sdp!), connection: conn.future);
  }

  static Future<void> _iceComplete(RTCPeerConnection pc) {
    final done = Completer<void>();
    pc.onIceGatheringState = (s) {
      if (s == RTCIceGatheringState.RTCIceGatheringStateComplete && !done.isCompleted) done.complete();
    };
    // Host candidates arrive within milliseconds on a LAN; don't wait forever.
    return done.future.timeout(const Duration(seconds: 4), onTimeout: () {});
  }

  static Future<void> _channelOpen(RTCDataChannel ch) {
    if (ch.state == RTCDataChannelState.RTCDataChannelOpen) return Future.value();
    final c = Completer<void>();
    ch.onDataChannelState = (s) {
      if (s == RTCDataChannelState.RTCDataChannelOpen && !c.isCompleted) c.complete();
    };
    return c.future.timeout(const Duration(seconds: 30));
  }
}

class RtcOffer {
  RtcOffer._(this._pc, this._ch, this.code);
  final RTCPeerConnection _pc;
  final RTCDataChannel _ch;

  /// Show this as a QR code.
  final String code;

  Future<jaal.PeerConnection> accept(String answerCode) async {
    final a = jaal.RtcSignal.decode(answerCode);
    if (a.kind != 'a') throw const FormatException('that is a first code — scan their reply');
    await _pc.setRemoteDescription(RTCSessionDescription(a.sdp, 'answer'));
    await JaalRtc._channelOpen(_ch);
    return RtcConnection._(_pc, _ch);
  }

  Future<void> cancel() => _pc.close();
}

/// [jaal.PeerConnection] over an RTCDataChannel (16 KiB framing).
class RtcConnection implements jaal.PeerConnection {
  RtcConnection._(this._pc, this._ch) {
    _ch.onMessage = (m) {
      if (!m.isBinary) return;
      final f = _framer.push(m.binary);
      if (f != null && !_frames.isClosed) _frames.add(f);
    };
    _ch.onDataChannelState = (s) {
      if (s == RTCDataChannelState.RTCDataChannelClosed) _done();
    };
    _pc.onConnectionState = (s) {
      if (s == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          s == RTCPeerConnectionState.RTCPeerConnectionStateClosed ||
          s == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        _done();
      }
    };
  }

  final RTCPeerConnection _pc;
  final RTCDataChannel _ch;
  final _framer = jaal.RtcFramer();
  final _frames = StreamController<Uint8List>();
  final _closed = Completer<void>();

  @override
  String get remoteAddress => 'webrtc';

  @override
  String get transport => 'webrtc';

  @override
  bool get isOpen => !_closed.isCompleted;

  @override
  Stream<Uint8List> get frames => _frames.stream;

  @override
  Future<void> get closed => _closed.future;

  @override
  Future<void> send(Uint8List frame) async {
    if (!isOpen) throw jaal.TransportException('connection closed');
    for (final p in jaal.RtcSignal.split(frame)) {
      await _ch.send(RTCDataChannelMessage.fromBinary(p));
    }
  }

  @override
  Future<void> close() async {
    await _ch.close();
    await _pc.close();
    _done();
  }

  void _done() {
    if (_closed.isCompleted) return;
    _frames.close();
    _closed.complete();
  }
}
