import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:jaal_core/jaal_core.dart';
import 'package:test/test.dart';

const _sdp = 'v=0\r\no=- 4611731400430051336 2 IN IP4 127.0.0.1\r\ns=-\r\nt=0 0\r\n'
    'a=group:BUNDLE 0\r\na=msid-semantic: WMS\r\nm=application 9 UDP/DTLS/SCTP webrtc-datachannel\r\n'
    'c=IN IP4 0.0.0.0\r\na=candidate:1 1 udp 2122260223 192.168.1.6 54321 typ host\r\n'
    'a=ice-ufrag:abcd\r\na=ice-pwd:0123456789abcdefghijklmn\r\na=fingerprint:sha-256 '
    'AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99\r\n'
    'a=setup:actpass\r\na=mid:0\r\na=sctp-port:5000\r\na=max-message-size:262144\r\n';

void main() {
  test('signal codes round-trip and write a vector for the browser', () {
    final code = RtcSignal.encode('o', _sdp);
    expect(code.startsWith('jaal:rtc:1:o:'), isTrue);
    expect(code.length, lessThan(_sdp.length), reason: 'deflate shrinks the QR payload');
    final d = RtcSignal.decode(code);
    expect((d.kind, d.sdp), ('o', _sdp));
    File('../../protocol/test-vectors/rtc.json')
        .writeAsStringSync('${const JsonEncoder.withIndent('  ').convert({'sdp': _sdp, 'code': code})}\n');
  });

  test('frames split into ≤16 KiB pieces and reassemble', () {
    for (final n in [0, 1, 16 * 1024, 16 * 1024 + 1, 200000]) {
      final f = Uint8List.fromList(List.generate(n, (i) => i & 255));
      final parts = RtcSignal.split(f);
      expect(parts.every((p) => p.length <= 16 * 1024 + 1), isTrue);
      final r = RtcFramer();
      Uint8List? out;
      for (final p in parts) {
        out = r.push(p);
      }
      expect(out, f);
    }
  });
}
