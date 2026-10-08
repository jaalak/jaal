import 'package:jaal_core/jaal_core.dart';
import 'package:test/test.dart';

void main() {
  group('CanonicalJson', () {
    test('sorts keys recursively and strips whitespace', () {
      expect(
        CanonicalJson.encode({
          'b': 1,
          'a': {'z': true, 'y': null},
          'c': [3, 'x'],
        }),
        '{"a":{"y":null,"z":true},"b":1,"c":[3,"x"]}',
      );
    });

    test('sorts by UTF-16 code units', () {
      // 'é' (U+00E9) > 'z' (U+007A); '😀' surrogate D83D > 'é'
      expect(CanonicalJson.encode({'é': 1, 'z': 2, '😀': 3, 'A': 4}),
          '{"A":4,"z":2,"é":1,"😀":3}');
    });

    test('escapes only what JSON requires', () {
      expect(CanonicalJson.encode('a"b\\c\n\t\u0001é😀/'),
          r'"a\"b\\c\n\t\u0001é😀/"');
    });

    test('rejects floats and unsafe integers', () {
      expect(() => CanonicalJson.encode({'x': 1.5}), throwsArgumentError);
      expect(() => CanonicalJson.encode(9007199254740992), throwsArgumentError);
      expect(() => CanonicalJson.decode('{"x":1.0}'), throwsFormatException);
    });

    test('round-trips', () {
      const s = '{"a":[1,2,{"b":"c"}],"d":false,"e":-42}';
      expect(CanonicalJson.encode(CanonicalJson.decode(s)), s);
    });
  });

  group('bytes', () {
    test('base64url is unpadded and round-trips', () {
      for (var n = 0; n < 40; n++) {
        final b = randomBytes(n);
        final s = b64(b);
        expect(s.contains('='), isFalse);
        expect(unb64(s), b);
      }
    });

    test('fingerprint is 4 crockford chars', () {
      expect(fingerprint([0, 0, 0]), '0000');
      expect(fingerprint([0xff, 0xff, 0xff]), 'zzzz');
    });
  });
}
