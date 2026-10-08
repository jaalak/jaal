import 'dart:convert';

import '../crypto/crypto.dart';
import '../util/bytes.dart';
import '../util/canonical_json.dart';
import 'identity.dart';

/// What a QR code is for.
abstract final class MeetPurpose {
  /// "this is me" — verify in person / follow.
  static const meet = 'meet';

  /// "I consent to being a moderator" — shown to a moderator who vouches.
  static const moderator = 'mod';
}

/// The QR payload people scan face to face (protocol/SPEC.md §10).
///
/// Signed by the presenter's *root* key, so a QR can't be doctored to swap
/// in a different key: whoever shows it provably holds the key it names. The
/// human check is comparing the 4-char fingerprint out loud.
class MeetCode {
  const MeetCode({
    required this.purpose,
    required this.root,
    required this.dm,
    required this.handle,
    required this.nonce,
    required this.ts,
    required this.sig,
  });

  static const prefix = 'jaal:1:';

  final String purpose;
  final RootId root;
  final String dm;
  final String handle;
  final String nonce;
  final int ts;
  final String sig;

  Map<String, Object?> unsignedJson() => {
        'purpose': purpose,
        'root': root,
        'dm': dm,
        'handle': handle,
        'nonce': nonce,
        'ts': ts,
      };

  Map<String, Object?> toJson() => {...unsignedJson(), 'sig': sig};

  String get fingerprint => fingerprintOf(root);

  /// Text to render as a QR code.
  String encode() => '$prefix${b64(utf8.encode(CanonicalJson.encode(toJson())))}';

  static MeetCode fromJson(Map<String, Object?> j) {
    T req<T>(String k) {
      final v = j[k];
      if (v is! T) throw FormatException('meet code: $k missing');
      return v;
    }

    return MeetCode(
      purpose: req<String>('purpose'),
      root: req<String>('root'),
      dm: req<String>('dm'),
      handle: req<String>('handle'),
      nonce: req<String>('nonce'),
      ts: req<int>('ts'),
      sig: req<String>('sig'),
    );
  }

  /// Parses a scanned string. Throws [FormatException] if it isn't a Jaal code.
  static MeetCode decode(String text) {
    final t = text.trim();
    if (!t.startsWith(prefix)) throw const FormatException('not a jaal code');
    final json = CanonicalJson.decodeBytes(unb64(t.substring(prefix.length)));
    if (json is! Map) throw const FormatException('bad jaal code');
    return fromJson(json.cast<String, Object?>());
  }

  Future<bool> verify() => JaalCrypto.verify(
        message: concatBytes([
          SigDomain.meet.codeUnits,
          CanonicalJson.encodeBytes(unsignedJson()),
        ]),
        signature: unb64(sig),
        publicKey: unb64(root),
      );

  static Future<MeetCode> create(
    LocalIdentity me, {
    required String handle,
    required int now,
    String purpose = MeetPurpose.meet,
  }) async {
    final unsigned = {
      'purpose': purpose,
      'root': me.rootId,
      'dm': me.dmPublicKey,
      'handle': handle,
      'nonce': b64(randomBytes(12)),
      'ts': now,
    };
    final sig = await me.root.signing.sign(concatBytes([
      SigDomain.meet.codeUnits,
      CanonicalJson.encodeBytes(unsigned),
    ]));
    return MeetCode.fromJson({...unsigned, 'sig': b64(sig)});
  }
}
