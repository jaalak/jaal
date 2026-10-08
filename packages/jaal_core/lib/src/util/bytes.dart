import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

/// Unpadded base64url, the only binary-to-text encoding used on the wire.
String b64(List<int> bytes) => base64Url.encode(bytes).replaceAll('=', '');

Uint8List unb64(String s) {
  final pad = (4 - s.length % 4) % 4;
  if (pad == 3) throw FormatException('invalid base64url length', s);
  return base64Url.decode(s + '=' * pad);
}

/// Lowercase hex, used only for logs and debug views.
String hex(List<int> bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

bool bytesEqual(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    diff |= a[i] ^ b[i];
  }
  return diff == 0;
}

Uint8List concatBytes(List<List<int>> parts) {
  final out = BytesBuilder(copy: false);
  for (final p in parts) {
    out.add(p);
  }
  return out.toBytes();
}

final Random _secure = Random.secure();

Uint8List randomBytes(int n) =>
    Uint8List.fromList(List<int>.generate(n, (_) => _secure.nextInt(256)));

/// Short, human-checkable fingerprint of a key: 4 chars of Crockford base32.
/// Shown next to handles, e.g. `@maya·k7f2`.
String fingerprint(List<int> digest, {int chars = 4}) {
  const alphabet = '0123456789abcdefghjkmnpqrstvwxyz';
  var bits = 0, value = 0;
  final sb = StringBuffer();
  for (final b in digest) {
    value = (value << 8) | b;
    bits += 8;
    while (bits >= 5 && sb.length < chars) {
      sb.write(alphabet[(value >> (bits - 5)) & 31]);
      bits -= 5;
    }
    if (sb.length >= chars) break;
  }
  return sb.toString();
}
