import 'package:jaal_core/jaal_core.dart';
import 'package:test/test.dart';

import 'helpers.dart';

class _Store {
  _Store(this.me, this.db, this.store);
  final LocalIdentity me;
  final JaalDatabase db;
  final EventStore store;

  static Future<_Store> create(ManualClock clock) async {
    final me = await newIdentity(clock);
    final db = JaalDatabase.memory();
    final s = EventStore(db: db, me: me, clock: clock);
    await s.init();
    return _Store(me, db, s);
  }

  Future<List<FeedItem>> all() => store.readFeed(me.feedId, 1, limit: 1000);
}

void main() {
  late ManualClock clock;
  late _Store alice, bob;

  setUp(() async {
    clock = ManualClock();
    alice = await _Store.create(clock);
    bob = await _Store.create(clock);
  });

  tearDown(() async {
    await alice.db.close();
    await bob.db.close();
  });

  Future<List<IngestResult>> replicate(List<FeedItem> items) async =>
      [for (final i in items) await bob.store.ingest(i)];

  test('own feed starts with a device certificate and chains', () async {
    final p = await alice.store.append(EventType.post, Bodies.post(text: 'hi'));
    final items = await alice.all();
    expect(items.map((i) => i.event.type), [EventType.deviceCert, EventType.post]);
    expect(items[1].event.prev, items[0].event.id);
    expect(p.seq, 2);
    expect(await p.verifySignature(), isTrue);
  });

  test('replicated events are accepted, projected and counted as a hop', () async {
    await alice.store.append(EventType.profile,
        Bodies.profile(name: 'Alice', handle: 'alice', dmKey: alice.me.dmPublicKey));
    final p = await alice.store.append(EventType.post, Bodies.post(text: 'gm'));
    final results = await replicate(await alice.all());
    expect(results, everyElement(isA<Accepted>()));
    final row = (await bob.db.post(p.id))!;
    expect(row.body, 'gm');
    expect(row.rootId, alice.me.rootId);
    expect(row.hops, 1);
    expect((await bob.db.profile(alice.me.rootId))!.handle, 'alice');
    // Re-delivery is idempotent.
    expect(await bob.store.ingest((await alice.all()).last), isA<Duplicate>());
  });

  test('rejects gaps, tampered signatures and bad body hashes', () async {
    await alice.store.append(EventType.post, Bodies.post(text: 'one'));
    await alice.store.append(EventType.post, Bodies.post(text: 'two'));
    final items = await alice.all();

    final gap = await bob.store.ingest(items[1]);
    expect((gap as Rejected).reason, RejectReason.gap);

    expect(await bob.store.ingest(items[0]), isA<Accepted>());

    final tampered = FeedItem(items[1].event, {'text': 'evil', 'media': []}, 0);
    expect((await bob.store.ingest(tampered) as Rejected).reason,
        RejectReason.badBodyHash);

    final j = items[1].event.toJson()..['ts'] = 1;
    final forged = FeedItem(SignedEvent.fromJson(j), items[1].body, 0);
    expect((await bob.store.ingest(forged) as Rejected).reason,
        RejectReason.badSignature);

    expect(await bob.store.ingest(items[1]), isA<Accepted>());
  });

  test('rejects a forked chain', () async {
    final items = await alice.all();
    expect(await bob.store.ingest(items[0]), isA<Accepted>());
    // Alice's device signs a different event at seq 2 than one Bob later sees.
    final a = await SignedEvent.create(
        device: alice.me.device, seq: 2, prev: items[0].event.id, lamport: 5,
        ts: 1, type: EventType.post, body: Bodies.post(text: 'a'));
    final b = await SignedEvent.create(
        device: alice.me.device, seq: 2, prev: items[0].event.id, lamport: 5,
        ts: 2, type: EventType.post, body: Bodies.post(text: 'b'));
    expect(await bob.store.ingest(FeedItem(a, Bodies.post(text: 'a'), 0)),
        isA<Accepted>());
    expect((await bob.store.ingest(FeedItem(b, Bodies.post(text: 'b'), 0)) as Rejected)
        .reason, RejectReason.forkedChain);
  });

  test('feed must start with a valid device certificate for its key', () async {
    final rogue = await JaalCrypto.signingKeyFromSeed(randomBytes(32));
    final e = await SignedEvent.create(
        device: rogue, seq: 1, prev: null, lamport: 1, ts: 1,
        type: EventType.deviceCert, body: alice.me.cert.toJson());
    final r = await bob.store.ingest(FeedItem(e, alice.me.cert.toJson(), 0));
    expect((r as Rejected).reason, RejectReason.badDeviceCert);
  });

  test('delete erases content locally and on replicas, keeps chain valid', () async {
    final p = await alice.store.append(EventType.post, Bodies.post(text: 'oops'));
    await replicate(await alice.all());
    await alice.store.append(EventType.delete, Bodies.delete(target: p.id));
    expect((await alice.db.post(p.id))!.deleted, isTrue);
    expect((await alice.db.eventById(p.id))!.body, isNull);

    // Forwarded copy of the deleted post now travels without its body.
    final items = await alice.all();
    expect(items[1].body, isNull);
    expect(await bob.store.ingest(items.last), isA<Accepted>());
    final row = (await bob.db.post(p.id))!;
    expect(row.deleted, isTrue);
    expect(row.body, isEmpty);
    expect((await bob.db.eventById(p.id))!.body, isNull);
  });

  test('a late-arriving target is born deleted (redacted carrier copy)', () async {
    final carol = await _Store.create(clock);
    final p = await alice.store.append(EventType.post, Bodies.post(text: 'gone'));
    await alice.store.append(EventType.delete, Bodies.delete(target: p.id));
    for (final i in await alice.all()) {
      expect(await carol.store.ingest(i), isA<Accepted>());
    }
    final row = (await carol.db.post(p.id));
    // The post body was erased before it ever left Alice: no content row.
    expect(row == null || row.deleted, isTrue);
    await carol.db.close();
  });

  test('cannot delete someone else\'s post', () async {
    final p = await alice.store.append(EventType.post, Bodies.post(text: 'mine'));
    await replicate(await alice.all());
    await bob.store.append(EventType.delete, Bodies.delete(target: p.id));
    expect((await bob.db.post(p.id))!.deleted, isFalse);
  });

  test('reactions and follows are last-writer-wins', () async {
    final p = await alice.store.append(EventType.post, Bodies.post(text: 'x'));
    await replicate(await alice.all());
    await bob.store.append(EventType.reaction,
        Bodies.reaction(target: p.id, sticker: 'fire', x: 100, y: 200, rot: 7));
    await bob.store.append(EventType.reaction,
        Bodies.reaction(target: p.id, sticker: 'skull', x: 300, y: 400, rot: -3));
    final r = await bob.db.select(bob.db.reactions).getSingle();
    expect((r.sticker, r.x, r.rot), ('skull', 300, -3));

    await bob.store.append(EventType.follow,
        Bodies.follow(target: alice.me.rootId, on: true));
    expect(await bob.db.followingOf(bob.me.rootId), {alice.me.rootId});
    await bob.store.append(EventType.follow,
        Bodies.follow(target: alice.me.rootId, on: false));
    expect(await bob.db.followingOf(bob.me.rootId), isEmpty);
  });

  test('edits replace text; lwwNewer breaks ties by id', () async {
    final p = await alice.store.append(EventType.post, Bodies.post(text: 'v1'));
    await alice.store.append(EventType.postEdit, Bodies.postEdit(target: p.id, text: 'v2'));
    expect((await alice.db.post(p.id))!.body, 'v2');
    expect(lwwNewer(3, 'b', 3, 'a'), isTrue);
    expect(lwwNewer(3, 'a', 3, 'b'), isFalse);
    expect(lwwNewer(2, 'z', 3, 'a'), isFalse);
  });

  test('invalid bodies are refused locally', () {
    expect(() => alice.store.append(EventType.post, {'text': 'x' * 3000, 'media': []}),
        throwsArgumentError);
    expect(
        () => alice.store.append(EventType.profile,
            Bodies.profile(name: 'A', handle: 'NO CAPS', dmKey: 'k')),
        throwsArgumentError);
  });
}
