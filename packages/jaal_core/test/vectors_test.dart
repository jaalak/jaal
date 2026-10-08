import 'dart:convert';
import 'dart:io';

import 'package:jaal_core/jaal_core.dart';
import 'package:test/test.dart';

/// Guards protocol stability: the committed vectors must keep verifying.
void main() {
  final file = File('../../protocol/test-vectors/v1.json');

  test('protocol v1 test vectors still hold', () async {
    final v = jsonDecode(await file.readAsString()) as Map<String, dynamic>;

    for (final c in v['canonicalJson'] as List) {
      expect(CanonicalJson.encode(c['input']), c['output']);
    }

    final id = v['identity'] as Map<String, dynamic>;
    final root = await RootIdentity.fromSeed(unb64(id['rootSeed'] as String));
    expect(root.id, id['rootPublicKey']);
    expect(root.recoveryPhrase, id['recoveryPhrase']);
    expect(root.fingerprint, id['fingerprint']);
    expect(b64(root.dm.publicKey), id['dmPublicKey']);
    expect(b64(root.selfKey), id['selfKey']);
    expect(
        await DeviceCert.fromJson((id['deviceCert'] as Map).cast()).verify(), isTrue);

    for (final e in v['events'] as List) {
      final ev = SignedEvent.fromJson((e['event'] as Map).cast());
      expect(ev.id, e['id']);
      expect(CanonicalJson.encode(ev.unsignedJson()), e['unsignedCanonical']);
      expect(SignedEvent.hashBody((e['body'] as Map).cast()), ev.bodyHash);
      expect(await ev.verifySignature(), isTrue);
    }
  }, skip: file.existsSync() ? false : 'run tool/gen_vectors.dart first');
}
