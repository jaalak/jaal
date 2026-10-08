import 'dart:typed_data';

import 'package:jaal_core/jaal_core.dart';
import 'package:test/test.dart';

void main() {
  group('RootIdentity', () {
    test('recovery phrase is 24 words and restores the same keys', () async {
      final a = await RootIdentity.generate();
      final words = a.recoveryPhrase.split(' ');
      expect(words, hasLength(24));
      final b = await RootIdentity.fromRecoveryPhrase(
          '  ${a.recoveryPhrase.toUpperCase()}  ');
      expect(b.id, a.id);
      expect(b.dm.publicKey, a.dm.publicKey);
      expect(b.selfKey, a.selfKey);
    });

    test('rejects a phrase with a bad checksum', () async {
      final a = await RootIdentity.generate();
      final words = a.recoveryPhrase.split(' ');
      words[0] = words[0] == 'abandon' ? 'ability' : 'abandon';
      expect(() => RootIdentity.fromRecoveryPhrase(words.join(' ')),
          throwsA(anything));
    });

    test('device certificates verify and detect tampering', () async {
      final clock = ManualClock();
      final id = await LocalIdentity.create(await RootIdentity.generate(),
          now: clock.nowMs());
      expect(await id.cert.verify(), isTrue);
      final forged = DeviceCert(
        root: id.cert.root,
        device: b64(randomBytes(32)),
        created: id.cert.created,
        sig: id.cert.sig,
      );
      expect(await forged.verify(), isFalse);
    });

    test('identity persists through a KeyStore', () async {
      final store = MemoryKeyStore();
      final a = await LocalIdentity.createAndSave(store, now: 1);
      final b = (await LocalIdentity.load(store))!;
      expect(b.rootId, a.rootId);
      expect(b.feedId, a.feedId);
      expect(await b.cert.verify(), isTrue);
    });
  });

  group('JaalCrypto', () {
    test('AEAD round-trip and tamper detection', () async {
      final key = randomBytes(32), nonce = randomBytes(24);
      final sealed = await JaalCrypto.seal(
          key: key, nonce: nonce, plaintext: [1, 2, 3], aad: [9]);
      expect(await JaalCrypto.open(key: key, nonce: nonce, sealed: sealed, aad: [9]),
          [1, 2, 3]);
      expect(await JaalCrypto.open(key: key, nonce: nonce, sealed: sealed, aad: [8]),
          isNull);
      final bad = Uint8List.fromList(sealed)..[0] ^= 1;
      expect(await JaalCrypto.open(key: key, nonce: nonce, sealed: bad, aad: [9]),
          isNull);
    });

    test('X25519 agreement is symmetric', () async {
      final a = await JaalCrypto.newDhKey(), b = await JaalCrypto.newDhKey();
      expect(await a.agree(b.publicKey), await b.agree(a.publicKey));
    });
  });
}
