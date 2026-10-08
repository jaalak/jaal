import 'package:jaal_core/jaal_core.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  final clock = ManualClock();
  late LocalIdentity alice, bob, carol;

  setUpAll(() async {
    alice = await newIdentity(clock);
    bob = await newIdentity(clock);
    carol = await newIdentity(clock);
  });

  Future<SealResult> seal(String text, {LocalIdentity? to}) => Sealer.sealDm(
        sender: alice,
        to: (to ?? bob).rootId,
        recipientDmKey: (to ?? bob).dmPublicKey,
        text: text,
        now: clock.nowMs(),
      );

  test('recipient opens and verifies sender; header hides identities', () async {
    final s = await seal('meet at the chai stall');
    final env = s.envelope;
    final header = CanonicalJson.encode(env.headerJson());
    expect(header.contains(alice.rootId), isFalse);
    expect(header.contains(bob.rootId), isFalse);
    expect(env.hint, bob.dmHint);

    final m = (await Sealer.open(env, bob))!;
    expect(m.text, 'meet at the chai stall');
    expect(m.from, alice.rootId);
    expect(m.fromDevice, alice.feedId);
    expect(Sealer.ackHashOf(m.ackSecret), env.ackHash);
  });

  test('non-recipients cannot open', () async {
    final s = await seal('secret');
    expect(await Sealer.open(s.envelope, carol), isNull);
  });

  test('tampered header or ciphertext fails', () async {
    final env = (await seal('x')).envelope;
    final j = env.toJson()..['exp'] = env.exp + 1;
    expect(await Sealer.open(SealedEnvelope.fromJson(j), bob), isNull);
    final ct = unb64(env.ct)..[3] ^= 0x40;
    final j2 = env.toJson()..['ct'] = b64(ct);
    expect(await Sealer.open(SealedEnvelope.fromJson(j2), bob), isNull);
  });

  test('envelope ids are unique per message', () async {
    final a = await seal('same'), b = await seal('same');
    expect(a.envelope.id, isNot(b.envelope.id));
  });
}
