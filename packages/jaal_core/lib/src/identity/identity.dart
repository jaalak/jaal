import 'dart:typed_data';

import 'package:bip39_mnemonic/bip39_mnemonic.dart';

import '../crypto/crypto.dart';
import '../util/bytes.dart';
import '../util/canonical_json.dart';

/// A person's identifier: base64url of their root Ed25519 public key.
typedef RootId = String;

/// A device feed's identifier: base64url of the device Ed25519 public key.
typedef FeedId = String;

/// Domain-separation prefixes for every signature in the protocol.
abstract final class SigDomain {
  static const deviceCert = 'jaal-devcert-v1:';
  static const event = 'jaal-event-v1:';
  static const dm = 'jaal-dm-v1:';
  static const auth = 'jaal-auth-v1:';
  static const meet = 'jaal-meet-v1:';
}

/// Statement, signed by a root key, that a device key may author events on
/// behalf of that root. Carried as the body of every feed's first event.
class DeviceCert {
  const DeviceCert({
    required this.root,
    required this.device,
    required this.created,
    required this.sig,
    this.purpose,
  });

  final RootId root;
  final FeedId device;
  final int created;
  final String sig;

  /// null for a normal device feed, `"mod"` for a moderation feed. Omitted
  /// from the signed JSON when null, so v1 certificates are unchanged.
  final String? purpose;

  bool get isModeration => purpose == modPurpose;
  static const modPurpose = 'mod';

  Map<String, Object?> unsignedJson() => {
        'root': root,
        'device': device,
        'created': created,
        'purpose': ?purpose,
      };

  Map<String, Object?> toJson() => {...unsignedJson(), 'sig': sig};

  static DeviceCert fromJson(Map<String, Object?> j) => DeviceCert(
        root: j['root']! as String,
        device: j['device']! as String,
        created: j['created']! as int,
        sig: j['sig']! as String,
        purpose: j['purpose'] as String?,
      );

  Future<bool> verify() => JaalCrypto.verify(
        message: _signedBytes(unsignedJson()),
        signature: unb64(sig),
        publicKey: unb64(root),
      );

  static Uint8List _signedBytes(Map<String, Object?> unsigned) =>
      concatBytes([
        SigDomain.deviceCert.codeUnits,
        CanonicalJson.encodeBytes(unsigned),
      ]);
}

/// The user's root identity. Its 32-byte seed IS the BIP39 entropy, so the
/// 24-word recovery phrase reproduces every derived key.
class RootIdentity {
  RootIdentity._(this.seed, this.signing, this.dm, this.selfKey);

  final Uint8List seed;
  final SigningKey signing;

  /// Long-term X25519 key that sealed DMs are addressed to (derived, so every
  /// device restored from the phrase can read DMs).
  final DhKey dm;

  /// Symmetric key for `self.private` events readable only by own devices.
  final Uint8List selfKey;

  RootId get id => b64(signing.publicKey);
  String get fingerprint => fingerprintOf(id);

  static Future<RootIdentity> fromSeed(List<int> seed) async {
    final s = Uint8List.fromList(seed);
    final signing = await JaalCrypto.signingKeyFromSeed(s);
    final dmSeed = await JaalCrypto.hkdf(
        ikm: s, salt: 'jaal'.codeUnits, info: 'jaal-dm-x25519-v1');
    final selfKey = await JaalCrypto.hkdf(
        ikm: s, salt: 'jaal'.codeUnits, info: 'jaal-self-aead-v1');
    return RootIdentity._(
        s, signing, await JaalCrypto.dhKeyFromSeed(dmSeed), selfKey);
  }

  static Future<RootIdentity> generate() =>
      fromSeed(randomBytes(JaalCrypto.keyLength));

  /// 24-word English BIP39 phrase encoding [seed].
  String get recoveryPhrase => Mnemonic(seed, Language.english).sentence;

  static Future<RootIdentity> fromRecoveryPhrase(String phrase) {
    final normalized =
        phrase.trim().toLowerCase().split(RegExp(r'\s+')).join(' ');
    final m = Mnemonic.fromSentence(normalized, Language.english);
    return fromSeed(m.entropy);
  }

  Future<DeviceCert> certify(FeedId device, {required int created, String? purpose}) async {
    final unsigned = {
      'root': id,
      'device': device,
      'created': created,
      'purpose': ?purpose,
    };
    final sig = await signing.sign(DeviceCert._signedBytes(unsigned));
    return DeviceCert(root: id, device: device, created: created, sig: b64(sig), purpose: purpose);
  }
}

/// Fingerprint shown next to handles: `@maya·k7f2`. Short and friendly, but
/// only 20 bits — grindable — so never use it alone to *verify* someone.
String fingerprintOf(RootId root) =>
    fingerprint(JaalCrypto.sha256(unb64(root)));

/// 80-bit fingerprint for in-person verification: `k7f2 9xqa m3ds 0p1t`.
/// Infeasible to grind, short enough to read aloud.
String longFingerprintOf(RootId root) {
  final f = fingerprint(JaalCrypto.sha256(unb64(root)), chars: 16);
  return [for (var i = 0; i < 16; i += 4) f.substring(i, i + 4)].join(' ');
}

/// 2-byte recipient hint placed on sealed envelopes (protocol/SPEC.md §6).
String dmHintOf(List<int> dmPublicKey) =>
    b64(JaalCrypto.sha256(dmPublicKey).sublist(0, 2));

/// Everything a running node needs to act as one user on one device.
class LocalIdentity {
  LocalIdentity._(this.root, this.device, this.cert);

  final RootIdentity root;
  final SigningKey device;
  final DeviceCert cert;

  (SigningKey, DeviceCert)? _mod;

  /// This device's moderation feed key + certificate, derived from the root
  /// seed and the device key (so it is stable without extra storage).
  Future<(SigningKey, DeviceCert)> moderationFeed() async {
    if (_mod != null) return _mod!;
    final seed = await JaalCrypto.hkdf(
        ikm: root.seed, salt: device.publicKey, info: 'jaal-modfeed-v1');
    final key = await JaalCrypto.signingKeyFromSeed(seed);
    final c = await root.certify(b64(key.publicKey),
        created: cert.created, purpose: DeviceCert.modPurpose);
    return _mod = (key, c);
  }

  RootId get rootId => root.id;
  FeedId get feedId => b64(device.publicKey);
  String get dmPublicKey => b64(root.dm.publicKey);
  String get dmHint => dmHintOf(root.dm.publicKey);

  static Future<LocalIdentity> create(
    RootIdentity root, {
    List<int>? deviceSeed,
    required int now,
  }) async {
    final device = await JaalCrypto.signingKeyFromSeed(
        deviceSeed ?? randomBytes(JaalCrypto.keyLength));
    final cert = await root.certify(b64(device.publicKey), created: now);
    return LocalIdentity._(root, device, cert);
  }

  /// Loads from [store], or returns null if no identity has been created.
  static Future<LocalIdentity?> load(KeyStore store) async {
    final rootSeed = await store.read(KeyStore.rootSeedKey);
    final devSeed = await store.read(KeyStore.deviceSeedKey);
    final certJson = await store.read(KeyStore.deviceCertKey);
    if (rootSeed == null || devSeed == null || certJson == null) return null;
    final root = await RootIdentity.fromSeed(unb64(rootSeed));
    final device = await JaalCrypto.signingKeyFromSeed(unb64(devSeed));
    final cert = DeviceCert.fromJson(
        CanonicalJson.decode(certJson)! as Map<String, Object?>);
    return LocalIdentity._(root, device, cert);
  }

  Future<void> save(KeyStore store, List<int> deviceSeed) async {
    await store.write(KeyStore.rootSeedKey, b64(root.seed));
    await store.write(KeyStore.deviceSeedKey, b64(deviceSeed));
    await store.write(
        KeyStore.deviceCertKey, CanonicalJson.encode(cert.toJson()));
  }

  /// Creates a fresh identity (or restores one from [phrase]) and persists it.
  static Future<LocalIdentity> createAndSave(
    KeyStore store, {
    required int now,
    String? phrase,
  }) async {
    final root = phrase == null
        ? await RootIdentity.generate()
        : await RootIdentity.fromRecoveryPhrase(phrase);
    final devSeed = randomBytes(JaalCrypto.keyLength);
    final id = await create(root, deviceSeed: devSeed, now: now);
    await id.save(store, devSeed);
    return id;
  }
}

/// Secret storage. Android uses flutter_secure_storage (Keystore-backed);
/// tests and the simulator use [MemoryKeyStore].
abstract interface class KeyStore {
  static const rootSeedKey = 'jaal.root_seed';
  static const deviceSeedKey = 'jaal.device_seed';
  static const deviceCertKey = 'jaal.device_cert';

  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class MemoryKeyStore implements KeyStore {
  final Map<String, String> _m = {};

  @override
  Future<String?> read(String key) async => _m[key];

  @override
  Future<void> write(String key, String value) async => _m[key] = value;

  @override
  Future<void> delete(String key) async => _m.remove(key);
}
