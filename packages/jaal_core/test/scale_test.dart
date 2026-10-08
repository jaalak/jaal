import 'package:jaal_core/jaal_core.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  late TestMesh mesh;
  tearDown(() => mesh.dispose());

  test(tags: ['stress'], 'stress: 3,000 feeds and 12,000 carried letters sync between two phones', () async {
    mesh = await TestMesh.create(['A', 'B'], start: false);
    final a = mesh['A'];
    final sw = Stopwatch()..start();

    // 3,000 extra device feeds (one root, many devices) — each a valid,
    // signed seq-1 certificate that A ingests and verifies.
    const feeds = 3000;
    final root = await RootIdentity.generate();
    for (var i = 0; i < feeds; i++) {
      final dev = await JaalCrypto.signingKeyFromSeed(randomBytes(32));
      final cert = await root.certify(b64(dev.publicKey), created: 1);
      final e = await SignedEvent.create(
          device: dev, seq: 1, prev: null, lamport: 1, ts: 1,
          type: EventType.deviceCert, body: cert.toJson());
      expect(await a.store.ingest(FeedItem(e, cert.toJson(), 0)), isA<Accepted>());
    }
    final buildFeeds = sw.elapsedMilliseconds;

    // 12,000 sealed-looking letters in A's carry pouch.
    const letters = 12000;
    final exp = mesh.clock.nowMs() + const Duration(days: 10).inMilliseconds;
    await a.db.batch((b) {
      for (var i = 0; i < letters; i++) {
        final env = SealedEnvelope(
          kind: 'dm',
          hint: b64(randomBytes(2)),
          epk: b64(randomBytes(32)),
          ackHash: b64(randomBytes(32)),
          exp: exp,
          nonce: b64(randomBytes(24)),
          ct: b64(randomBytes(160)),
        );
        b.insert(a.db.envelopes, EnvelopesCompanion.insert(
          id: env.id,
          raw: CanonicalJson.encode(env.toJson()),
          hint: env.hint,
          ackHash: env.ackHash,
          exp: env.exp,
          size: env.sizeBytes,
          receivedAt: 1,
          origin: EnvelopeOrigin.carried,
        ));
      }
    });
    final setup = sw.elapsedMilliseconds;

    // B is a relay that wants everything.
    await mesh['B'].close();
    mesh.nodes.remove('B');
    final b = await mesh.add('B2', policy: const ReplicationPolicy(everything: true));
    await a.start();
    sw.reset();
    mesh.link('A', 'B2');
    await eventually(() async => (await b.db.allFeeds()).length >= feeds + 2,
        timeout: const Duration(minutes: 3), reason: 'all feeds replicated');
    final feedSync = sw.elapsedMilliseconds;
    await eventually(() async => await b.db.stat(StatKey.courierCarried) >= letters,
        timeout: const Duration(minutes: 3), reason: 'all letters carried');
    final total = sw.elapsedMilliseconds;

    // ignore: avoid_print
    print('stress: built $feeds feeds in ${buildFeeds}ms, $letters letters by ${setup}ms; '
        'synced feeds in ${feedSync}ms, everything in ${total}ms, '
        '${mesh.net.framesSent} frames, ${(mesh.net.bytesSent / 1048576).toStringAsFixed(1)} MiB');
  }, timeout: const Timeout(Duration(minutes: 6)));

  test('non-followers replicate a moderator\'s decisions, not their posts', () async {
    mesh = await TestMesh.create(['G1', 'G2', 'G3', 'Relay', 'Far', 'Troll'],
        genesis: ['G1', 'G2', 'G3']);
    // Relay follows G1 and the troll; Far follows nobody and never meets G1.
    await mesh['Relay'].follow(mesh['G1'].rootId);
    await mesh['Relay'].follow(mesh['Troll'].rootId);
    final selfie = await mesh['G1'].post('moderator\'s personal selfie');
    mesh.link('Troll', 'G1');
    mesh.link('Troll', 'G2');
    await eventually(() async =>
        await mesh['G1'].db.profile(mesh['Troll'].rootId) != null &&
        await mesh['G2'].db.profile(mesh['Troll'].rootId) != null);
    await mesh['G1'].banVote(mesh['Troll'].rootId, reason: 'spam');
    await mesh['G2'].banVote(mesh['Troll'].rootId, reason: 'spam');
    mesh.unlink('Troll', 'G1');
    mesh.unlink('Troll', 'G2');

    mesh.link('G1', 'Relay');
    mesh.link('G2', 'Relay');
    await eventually(() async => mesh['Relay'].moderation.isBanned(mesh['Troll'].rootId),
        reason: 'relay learned the ban');
    expect(await hasPost(mesh['Relay'], selfie.id), isTrue, reason: 'relay follows G1');
    mesh.unlink('G1', 'Relay');
    mesh.unlink('G2', 'Relay');

    mesh.link('Relay', 'Far');
    await eventually(() async => mesh['Far'].moderation.isBanned(mesh['Troll'].rootId),
        reason: 'ban reached Far through the relay');
    expect(await hasPost(mesh['Far'], selfie.id), isFalse,
        reason: 'Far only replicates G1\'s moderation feed');
    final g1Feeds = (await mesh['Far'].db.allFeeds()).where((f) => f.rootId == mesh['G1'].rootId).toList();
    expect(g1Feeds.map((f) => f.purpose), [FeedPurpose.moderation]);
  });

  test('a moderation feed cannot smuggle ordinary posts', () async {
    mesh = await TestMesh.create(['G1', 'B'], genesis: ['G1'], start: false);
    final g1 = mesh['G1'];
    await g1.banVote(mesh['B'].rootId); // creates G1's moderation feed
    final (key, _) = await g1.me.moderationFeed();
    final f = (await g1.db.feed(b64(key.publicKey)))!;
    expect(f.purpose, FeedPurpose.moderation);
    final items = await g1.store.readFeed(f.feedId, 1);
    for (final it in items) {
      expect(await mesh['B'].store.ingest(it), isA<Accepted>());
    }
    final post = await SignedEvent.create(
        device: key, seq: f.latestSeq + 1, prev: f.latestId, lamport: f.latestLamport + 1,
        ts: 1, type: EventType.post, body: Bodies.post(text: 'sneaky'));
    final r = await mesh['B'].store.ingest(FeedItem(post, Bodies.post(text: 'sneaky'), 0));
    expect((r as Rejected).reason, RejectReason.invalidBody);
  });

  test('long fingerprints are 80 bits in 4 groups', () async {
    final a = await RootIdentity.generate(), b = await RootIdentity.generate();
    final fa = longFingerprintOf(a.id);
    expect(RegExp(r'^[0-9a-z]{4}( [0-9a-z]{4}){3}$').hasMatch(fa), isTrue);
    expect(fa.startsWith(fingerprintOf(a.id)), isTrue);
    expect(fa, isNot(longFingerprintOf(b.id)));
  });
}
