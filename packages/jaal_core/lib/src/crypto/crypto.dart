import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:cryptography/dart.dart';

import '../util/bytes.dart';

/// Thin, opinionated wrapper around `package:cryptography` that exposes only
/// the primitives the Jaal protocol uses (protocol/SPEC.md §3):
///
/// * Ed25519 — identity, device and event signatures
/// * X25519 — sealed-envelope key agreement
/// * HKDF-SHA256 — key derivation
/// * XChaCha20-Poly1305 — authenticated encryption
/// * SHA-256 — content addressing
///
/// Everything else in the codebase goes through this file so primitives can be
/// swapped for platform-accelerated ones (cryptography_flutter) in one place.
class JaalCrypto {
  JaalCrypto._();

  static final Ed25519 _ed = Ed25519();
  static final X25519 _x = X25519();
  static final Xchacha20 _aead = Xchacha20.poly1305Aead();
  static const DartSha256 _sha = DartSha256();

  static const int keyLength = 32;
  static const int signatureLength = 64;
  static const int nonceLength = 24;
  static const int macLength = 16;

  // ---------------------------------------------------------------- hashing

  static Uint8List sha256(List<int> data) =>
      Uint8List.fromList(_sha.hashSync(data).bytes);

  static Uint8List sha256Utf8(String s) => sha256(utf8.encode(s));

  // ---------------------------------------------------------------- signing

  static Future<SigningKey> signingKeyFromSeed(List<int> seed) async {
    _checkLen(seed, keyLength, 'seed');
    final kp = await _ed.newKeyPairFromSeed(seed);
    final pub = await kp.extractPublicKey();
    return SigningKey._(kp, Uint8List.fromList(pub.bytes));
  }

  static Future<bool> verify({
    required List<int> message,
    required List<int> signature,
    required List<int> publicKey,
  }) async {
    if (signature.length != signatureLength || publicKey.length != keyLength) {
      return false;
    }
    try {
      return await _ed.verify(
        message,
        signature: Signature(
          signature,
          publicKey: SimplePublicKey(publicKey, type: KeyPairType.ed25519),
        ),
      );
    } catch (_) {
      return false;
    }
  }

  // ------------------------------------------------------- key agreement

  static Future<DhKey> dhKeyFromSeed(List<int> seed) async {
    _checkLen(seed, keyLength, 'seed');
    final kp = await _x.newKeyPairFromSeed(seed);
    final pub = await kp.extractPublicKey();
    return DhKey._(kp, Uint8List.fromList(pub.bytes));
  }

  static Future<DhKey> newDhKey() => dhKeyFromSeed(randomBytes(keyLength));

  // ------------------------------------------------------------------ hkdf

  static Future<Uint8List> hkdf({
    required List<int> ikm,
    required List<int> salt,
    required String info,
    int length = keyLength,
  }) async {
    final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: length);
    final key = await hkdf.deriveKey(
      secretKey: SecretKey(ikm),
      nonce: salt,
      info: utf8.encode(info),
    );
    return Uint8List.fromList(await key.extractBytes());
  }

  // ------------------------------------------------------------------ aead

  /// Returns ciphertext‖mac (16-byte Poly1305 tag appended).
  static Future<Uint8List> seal({
    required List<int> key,
    required List<int> nonce,
    required List<int> plaintext,
    List<int> aad = const [],
  }) async {
    _checkLen(key, keyLength, 'key');
    _checkLen(nonce, nonceLength, 'nonce');
    final box = await _aead.encrypt(
      plaintext,
      secretKey: SecretKey(key),
      nonce: nonce,
      aad: aad,
    );
    return concatBytes([box.cipherText, box.mac.bytes]);
  }

  /// Returns null when authentication fails.
  static Future<Uint8List?> open({
    required List<int> key,
    required List<int> nonce,
    required List<int> sealed,
    List<int> aad = const [],
  }) async {
    if (sealed.length < macLength) return null;
    final ct = sealed.sublist(0, sealed.length - macLength);
    final mac = sealed.sublist(sealed.length - macLength);
    try {
      final clear = await _aead.decrypt(
        SecretBox(ct, nonce: nonce, mac: Mac(mac)),
        secretKey: SecretKey(key),
        aad: aad,
      );
      return Uint8List.fromList(clear);
    } on SecretBoxAuthenticationError {
      return null;
    }
  }

  static void _checkLen(List<int> b, int n, String what) {
    if (b.length != n) {
      throw ArgumentError('$what must be $n bytes, got ${b.length}');
    }
  }
}

/// An Ed25519 key pair held in memory.
class SigningKey {
  SigningKey._(this._kp, this.publicKey);

  final SimpleKeyPair _kp;
  final Uint8List publicKey;

  Future<Uint8List> sign(List<int> message) async {
    final sig = await Ed25519().sign(message, keyPair: _kp);
    return Uint8List.fromList(sig.bytes);
  }
}

/// An X25519 key pair held in memory.
class DhKey {
  DhKey._(this._kp, this.publicKey);

  final SimpleKeyPair _kp;
  final Uint8List publicKey;

  Future<Uint8List> agree(List<int> remotePublicKey) async {
    final secret = await X25519().sharedSecretKey(
      keyPair: _kp,
      remotePublicKey:
          SimplePublicKey(remotePublicKey, type: KeyPairType.x25519),
    );
    return Uint8List.fromList(await secret.extractBytes());
  }
}
