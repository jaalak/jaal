import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../util/bytes.dart';

/// QR-borne WebRTC signalling + data-channel framing, shared with the
/// browser client (apps/pwa/src/core/webrtc.ts).
///
///   code  = "jaal:rtc:1:" + ("o"|"a") + ":" + b64url(deflate-raw(utf8(sdp)))
///   frame = 1-byte flag (1 = last piece) + ≤16 KiB piece
abstract final class RtcSignal {
  static const prefix = 'jaal:rtc:1:';
  static const piece = 16 * 1024;

  static String encode(String kind, String sdp) {
    if (kind != 'o' && kind != 'a') throw ArgumentError.value(kind, 'kind');
    final deflated = ZLibCodec(raw: true, level: 9).encode(utf8.encode(sdp));
    return '$prefix$kind:${b64(deflated)}';
  }

  static ({String kind, String sdp}) decode(String code) {
    final t = code.trim();
    if (!t.startsWith(prefix)) throw const FormatException('not a jaal connect code');
    final rest = t.substring(prefix.length);
    final i = rest.indexOf(':');
    if (i < 0) throw const FormatException('bad connect code');
    final kind = rest.substring(0, i);
    if (kind != 'o' && kind != 'a') throw const FormatException('bad connect code');
    final sdp = utf8.decode(ZLibCodec(raw: true).decode(unb64(rest.substring(i + 1))));
    return (kind: kind, sdp: sdp);
  }

  static List<Uint8List> split(Uint8List frame) {
    final out = <Uint8List>[];
    var o = 0;
    do {
      final end = o + piece > frame.length ? frame.length : o + piece;
      final last = end >= frame.length;
      out.add(Uint8List(end - o + 1)
        ..[0] = last ? 1 : 0
        ..setRange(1, end - o + 1, frame, o));
      o = end;
    } while (o < frame.length);
    return out;
  }
}

/// Reassembles frames split by [RtcSignal.split].
class RtcFramer {
  final _parts = BytesBuilder(copy: false);

  Uint8List? push(Uint8List msg) {
    _parts.add(Uint8List.sublistView(msg, 1));
    if (msg[0] != 1) return null;
    return _parts.takeBytes();
  }
}
