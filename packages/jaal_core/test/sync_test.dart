import 'dart:typed_data';

import 'package:jaal_core/jaal_core.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  late TestMesh mesh;

  tearDown(() => mesh.dispose());

  test('two peers in range authenticate and swap feeds', () async {
    mesh = await TestMesh.create(['A', 'B']);
    final p = await mesh['A'].post('no wifi? no problem.');
    mesh.link('A', 'B');
    await mesh.connected('A', 'B');
    await eventually(() => hasPost(mesh['B'], p.id), reason: 'B has A post');
    expect((await mesh['B'].db.profile(mesh['A'].rootId))!.handle, 'peer_a');
    final peers = await mesh['B'].db.select(mesh['B'].db.peersSeen).get();
    expect(peers.single.rootId, mesh['A'].rootId);
  });

  test('live updates flow in real time while connected', () async {
    mesh = await TestMesh.create(['A', 'B']);
    mesh.link('A', 'B');
    await mesh.connected('A', 'B');
    await mesh.connected('B', 'A');
    final p = await mesh['A'].post('live');
    await eventually(() => hasPost(mesh['B'], p.id));
    await mesh['B'].react(p.id, sticker: 'fire', x: 10, y: 20, rot: 5);
    await eventually(() async =>
        (await mesh['A'].db.select(mesh['A'].db.reactions).get()).isNotEmpty);
  });

  test('store-and-forward: B carries A\'s posts to C who never meets A', () async {
    mesh = await TestMesh.create(['A', 'B', 'C']);
    // B and C both follow A (they know A's root id, e.g. from a QR scan).
    await mesh['B'].follow(mesh['A'].rootId);
    await mesh['C'].follow(mesh['A'].rootId);
    final p = await mesh['A'].post('postcard from the hills');

    mesh.link('A', 'B');
    await eventually(() => hasPost(mesh['B'], p.id), reason: 'B got it');
    mesh.unlink('A', 'B');
    await mesh.disconnected('B', 'A');

    mesh.link('B', 'C');
    await eventually(() => hasPost(mesh['C'], p.id), reason: 'C got it via B');
    final row = (await mesh['C'].db.post(p.id))!;
    expect(row.hops, 2, reason: 'A â†’ B â†’ C');
    expect(row.rootId, mesh['A'].rootId);
  });

  test('replication policy: non-followed, non-adjacent feeds are not pulled', () async {
    mesh = await TestMesh.create(['A', 'B', 'C']);
    final p = await mesh['A'].post('only for my people');
    mesh.link('A', 'B'); // B doesn't follow A but is adjacent â†’ replicates
    await eventually(() => hasPost(mesh['B'], p.id));
    mesh.unlink('A', 'B');
    mesh.link('B', 'C'); // C follows nobody and A isn't adjacent to C
    await mesh.connected('C', 'B');
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(await hasPost(mesh['C'], p.id), isFalse);
    // ...until C follows A: the open session re-evaluates and pulls.
    await mesh['C'].follow(mesh['A'].rootId);
    await eventually(() => hasPost(mesh['C'], p.id), reason: 'pulled after follow');
  });

  test('friends-of-friends are replicated', () async {
    mesh = await TestMesh.create(['A', 'B', 'C']);
    await mesh['B'].follow(mesh['A'].rootId);
    await mesh['C'].follow(mesh['B'].rootId);
    final p = await mesh['A'].post('fof');
    // B has followed A for over a week: A is established, not a newcomer.
    mesh.clock.advance(const Duration(days: 8));
    mesh.link('A', 'B');
    await eventually(() => hasPost(mesh['B'], p.id));
    mesh.unlink('A', 'B');
    mesh.link('B', 'C');
    await eventually(() => hasPost(mesh['C'], p.id), reason: 'C gets FoF post');
  });

  test('DM is carried by a stranger, delivered, and acked back', () async {
    mesh = await TestMesh.create(['A', 'B', 'C']);
    // A needs C's profile (DM key): they met once.
    mesh.link('A', 'C');
    await eventually(() async => await mesh['A'].db.profile(mesh['C'].rootId) != null);
    mesh.unlink('A', 'C');
    await mesh.disconnected('A', 'C');

    final sent = await mesh['A'].sendDm(mesh['C'].rootId, 'carried by a courier');
    expect(sent.delivered, isFalse);

    // A meets B (a stranger to both): B takes the sealed envelope.
    mesh.link('A', 'B');
    await eventually(() async =>
        (await mesh['B'].db.select(mesh['B'].db.envelopes).get())
            .any((e) => e.origin == EnvelopeOrigin.carried),
        reason: 'B carries envelope');
    final carried = (await mesh['B'].db.select(mesh['B'].db.envelopes).get()).single;
    expect(carried.raw.contains('courier'), isFalse, reason: 'B sees ciphertext only');
    mesh.unlink('A', 'B');

    // B walks over to C.
    mesh.link('B', 'C');
    await eventually(() async =>
        (await mesh['C'].db.select(mesh['C'].db.messages).get()).isNotEmpty,
        reason: 'C received DM');
    final m = (await mesh['C'].db.select(mesh['C'].db.messages).get()).single;
    expect(m.body, 'carried by a courier');
    expect(m.peerRoot, mesh['A'].rootId);

    // C's receipt reaches B immediately: courier clout, ciphertext dropped.
    await eventually(() async =>
        await mesh['B'].db.stat(StatKey.courierDelivered) == 1,
        reason: 'B earned courier clout');
    expect((await mesh['B'].db.envelope(carried.id))!.raw, isEmpty);

    // Later B meets A again and the receipt marks the message delivered.
    mesh.unlink('B', 'C');
    mesh.link('A', 'B');
    await eventually(() async =>
        (await mesh['A'].db.select(mesh['A'].db.messages).getSingle()).delivered,
        reason: 'A sees delivered');
  });

  test('real-time DM when both are in range', () async {
    mesh = await TestMesh.create(['A', 'B']);
    mesh.link('A', 'B');
    await eventually(() async => await mesh['A'].db.profile(mesh['B'].rootId) != null);
    await mesh['A'].sendDm(mesh['B'].rootId, 'yo');
    await eventually(() async =>
        (await mesh['B'].db.select(mesh['B'].db.messages).get()).isNotEmpty);
    await eventually(() async =>
        (await mesh['A'].db.select(mesh['A'].db.messages).getSingle()).delivered);
  });

  test('sync resumes and converges over a flaky link', () async {
    mesh = await TestMesh.create(['A', 'B']);
    for (var i = 0; i < 120; i++) {
      await mesh['A'].post('post $i');
    }
    mesh.link('A', 'B', config: const LinkConfig(dropChance: 0.08));
    await eventually(() async => await postCount(mesh['B']) == 120,
        timeout: const Duration(seconds: 60), reason: 'converged');
    expect(mesh.net.framesSent, greaterThan(0));
  });

  test('blocked peers are not synced and their feeds are refused', () async {
    mesh = await TestMesh.create(['A', 'B']);
    await mesh['B'].block(mesh['A'].rootId);
    await mesh['A'].post('let me in');
    mesh.link('A', 'B');
    await Future<void>.delayed(const Duration(milliseconds: 150));
    expect(await postCount(mesh['B']), 0);
    expect(mesh['B'].engine.connectedRoots, isEmpty);
    // The block list round-trips through the encrypted self.private event.
    final ev = (await mesh['B'].db.select(mesh['B'].db.events).get())
        .where((e) => e.type == EventType.selfPrivate)
        .single;
    expect(ev.body!.contains(mesh['A'].rootId), isFalse);
  });

  test('deletes propagate as tombstones', () async {
    mesh = await TestMesh.create(['A', 'B']);
    mesh.link('A', 'B');
    final p = await mesh['A'].post('regret');
    await eventually(() => hasPost(mesh['B'], p.id));
    await mesh['A'].delete(p.id);
    await eventually(() async => (await mesh['B'].db.post(p.id))!.deleted);
    expect((await mesh['B'].db.post(p.id))!.body, isEmpty);
  });

  test('carry pouch evicts oldest envelopes when over budget', () async {
    mesh = await TestMesh.create(['A', 'B', 'C'], maxCarryBytes: 3000);
    mesh.link('A', 'C');
    await eventually(() async => await mesh['A'].db.profile(mesh['C'].rootId) != null);
    mesh.unlink('A', 'C');
    for (var i = 0; i < 6; i++) {
      await mesh['A'].sendDm(mesh['C'].rootId, 'msg $i');
    }
    mesh.link('A', 'B');
    await eventually(() async => await mesh['B'].db.stat(StatKey.courierCarried) >= 6);
    expect(await mesh['B'].db.carriedBytes(), lessThanOrEqualTo(3000));
  });

  test('media chunks verify and assemble in any order', () {
    final data = Uint8List.fromList(List.generate(200000, (i) => i * 7 % 251));
    final m = Chunker.manifestFor(data, mime: 'image/jpeg');
    expect(m.chunks, hasLength(4));
    final chunks = Chunker.split(data, m.chunkSize);
    final asm = ChunkAssembler(m);
    expect(asm.add(2, chunks[2]), isTrue);
    expect(asm.add(0, chunks[1]), isFalse, reason: 'wrong chunk rejected');
    expect(asm.missing, [0, 1, 3]);
    for (final i in [3, 0, 1]) {
      asm.add(i, chunks[i]);
    }
    expect(asm.assemble(), data);
  });
}
