import 'dart:convert';
import 'dart:typed_data';

/// Canonical JSON encoding used for every signed or hashed structure in the
/// Jaal protocol (see protocol/SPEC.md §2).
///
/// Rules (a strict subset of RFC 8785 / JCS):
/// * object keys sorted by UTF-16 code units, no duplicates
/// * no insignificant whitespace
/// * numbers MUST be integers within ±(2^53 − 1); floats are rejected
/// * strings escaped as `\"`, `\\`, `\b`, `\f`, `\n`, `\r`, `\t`, other
///   control characters as lowercase `\u00xx`; everything else emitted raw
/// * output is UTF-8
class CanonicalJson {
  CanonicalJson._();

  static const int maxSafeInt = 9007199254740991;

  /// Encodes [value] to its canonical string form.
  static String encode(Object? value) {
    final sb = StringBuffer();
    _write(sb, value);
    return sb.toString();
  }

  /// Encodes [value] to canonical UTF-8 bytes.
  static Uint8List encodeBytes(Object? value) =>
      Uint8List.fromList(utf8.encode(encode(value)));

  /// Parses JSON text. Floats are rejected so that decode→encode round-trips.
  static Object? decode(String text) {
    final v = jsonDecode(text);
    _assertNoFloats(v);
    return v;
  }

  static Object? decodeBytes(List<int> bytes) => decode(utf8.decode(bytes));

  static void _assertNoFloats(Object? v) {
    if (v is double) {
      throw FormatException('floats are not allowed in canonical JSON: $v');
    } else if (v is List) {
      v.forEach(_assertNoFloats);
    } else if (v is Map) {
      v.values.forEach(_assertNoFloats);
    }
  }

  static void _write(StringBuffer sb, Object? v) {
    if (v == null) {
      sb.write('null');
    } else if (v is bool) {
      sb.write(v ? 'true' : 'false');
    } else if (v is int) {
      if (v > maxSafeInt || v < -maxSafeInt) {
        throw ArgumentError.value(v, 'value', 'integer outside safe range');
      }
      sb.write(v);
    } else if (v is double) {
      throw ArgumentError.value(v, 'value', 'floats are not allowed');
    } else if (v is String) {
      _writeString(sb, v);
    } else if (v is List) {
      sb.write('[');
      for (var i = 0; i < v.length; i++) {
        if (i > 0) sb.write(',');
        _write(sb, v[i]);
      }
      sb.write(']');
    } else if (v is Map) {
      final keys = v.keys.map((k) {
        if (k is! String) {
          throw ArgumentError.value(k, 'key', 'object keys must be strings');
        }
        return k;
      }).toList()
        ..sort(_compareUtf16);
      sb.write('{');
      for (var i = 0; i < keys.length; i++) {
        if (i > 0) sb.write(',');
        _writeString(sb, keys[i]);
        sb.write(':');
        _write(sb, v[keys[i]]);
      }
      sb.write('}');
    } else {
      throw ArgumentError.value(v, 'value', 'unsupported type ${v.runtimeType}');
    }
  }

  /// Dart's String.compareTo already compares UTF-16 code units, but we keep
  /// an explicit implementation so the rule is obvious and portable.
  static int _compareUtf16(String a, String b) {
    final n = a.length < b.length ? a.length : b.length;
    for (var i = 0; i < n; i++) {
      final d = a.codeUnitAt(i) - b.codeUnitAt(i);
      if (d != 0) return d;
    }
    return a.length - b.length;
  }

  static void _writeString(StringBuffer sb, String s) {
    sb.write('"');
    for (final c in s.codeUnits) {
      switch (c) {
        case 0x22:
          sb.write(r'\"');
        case 0x5c:
          sb.write(r'\\');
        case 0x08:
          sb.write(r'\b');
        case 0x0c:
          sb.write(r'\f');
        case 0x0a:
          sb.write(r'\n');
        case 0x0d:
          sb.write(r'\r');
        case 0x09:
          sb.write(r'\t');
        default:
          if (c < 0x20) {
            sb.write(r'\u00');
            sb.write(c.toRadixString(16).padLeft(2, '0'));
          } else {
            sb.writeCharCode(c);
          }
      }
    }
    sb.write('"');
  }
}
