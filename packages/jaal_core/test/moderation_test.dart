import 'package:jaal_core/jaal_core.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  late TestMesh mesh;
  tearDown(() => mesh.dispose());

  /// G1..G3 genesis moderators + the given extra peers, all in range.
  Future<void> setUpMods(List<String> others) async {
    mesh = await TestMesh.create(['G1', 'G2', 'G3', ...others],
        genesis: ['G1', 'G2', 'G3']);
    mesh.net.connectAll(mesh.nodes.keys);
    await eventually(() async {
      for (final n in mesh.nodes.values) {
        if ((await n.db.select(n.db.profiles).get()).length < mesh.nodes.length) {
          return false;
        }
      }
      return true;
    }, reason: 'everyone knows everyone');
  }

  Future<String> consentOf(String name) async =>
      (await mesh[name].meetCode(purpose: MeetPurpose.moderator)).encode();

  Future<void> everywhere(Future<bool> Function(JaalNode n) cond, String why) =>
      eventually(() async {
        for (final n in mesh.nodes.values) {
          if (!await cond(n)) return false;
        }
        return true;
      }, reason: why);

  group('becoming a moderator', () {
    test('genesis keys are moderators; 3 in-person vouches promote', () async {
      await setUpMods(['Cand', 'X']);
      expect(mesh['G1'].isModerator, isTrue);
      expect(mesh['Cand'].isModerator, isFalse);

      final consent = await consentOf('Cand');
      await mesh['G1'].vouchModerator(consent);
      await mesh['G2'].vouchModerator(consent);
      await everywhere((n) async => (await n.db.select(n.db.modActions).get()).length >= 2,
          'two vouches spread');
      expect(mesh['X'].moderation.isModerator(mesh['Cand'].rootId), isFalse,
          reason: '2 of 3 is not enough');

      await mesh['G3'].vouchModerator(consent);
      await everywhere((n) async => n.moderation.isModerator(mesh['Cand'].rootId),
          'Cand is a moderator on every phone');
      expect(mesh['Cand'].isModerator, isTrue);
    });

    test('non-moderators cannot vouch; forged consent is ignored', () async {
      await setUpMods(['Cand', 'Rando', 'Faker']);
      expect(() => mesh['Rando'].vouchModerator('x'), throwsStateError);

      // A modded client writes the vouch events directly, bypassing the API.
      final consent = (await mesh['Cand'].meetCode(purpose: MeetPurpose.moderator)).toJson();
      for (final n in ['Rando', 'Faker']) {
        await mesh[n].store.append(EventType.modVouch,
            Bodies.modVouch(candidate: mesh['Cand'].rootId, consent: consent));
      }
      // A real moderator with a consent QR that belongs to someone else.
      final fakeConsent = (await mesh['Faker'].meetCode(purpose: MeetPurpose.moderator)).toJson();
      await mesh['G1'].store.append(EventType.modVouch,
          Bodies.modVouch(candidate: mesh['Cand'].rootId, consent: fakeConsent));
      await mesh['G2'].vouchModerator((await mesh['Cand'].meetCode(purpose: MeetPurpose.moderator)).encode());

      await Future<void>.delayed(const Duration(milliseconds: 200));
      for (final n in mesh.nodes.values) {
        expect(n.moderation.isModerator(mesh['Cand'].rootId), isFalse);
      }
    });

    test('consent QR must be fresh and for the moderator purpose', () async {
      await setUpMods(['Cand']);
      final meet = (await mesh['Cand'].meetCode()).encode();
      expect(() => mesh['G1'].vouchModerator(meet), throwsFormatException);
      final consent = await consentOf('Cand');
      mesh.clock.advance(const Duration(minutes: 11));
      expect(() => mesh['G1'].vouchModerator(consent), throwsFormatException);
    });
  });

  group('removing toxic people', () {
    test('1 vote hides, 2 votes ban: purged everywhere, cannot post again', () async {
      await setUpMods(['Troll', 'Fan', 'Bystander']);
      await mesh['Fan'].follow(mesh['Troll'].rootId);
      final p = await mesh['Troll'].post('something toxic');
      await everywhere((n) => hasPost(n, p.id), 'post spread');

      await mesh['G1'].banVote(mesh['Troll'].rootId, reason: 'harassment');
      await everywhere((n) async => n.moderation.isFlagged(mesh['Troll'].rootId),
          'flagged everywhere');
      // Flagged: still stored, but hidden from feeds.
      expect(await hasPost(mesh['Fan'], p.id), isTrue);
      expect(await mesh['Fan'].watchHomeFeed().first, isEmpty);

      await mesh['G2'].banVote(mesh['Troll'].rootId, reason: 'harassment');
      await everywhere((n) async =>
          n == mesh['Troll'] || n.moderation.isBanned(mesh['Troll'].rootId),
          'banned everywhere');
      await everywhere((n) async => n == mesh['Troll'] || !await hasPost(n, p.id),
          'content purged');
      final status = (await mesh['Fan'].db.modStatusOf(mesh['Troll'].rootId))!;
      expect((status.state, status.votes, status.reason), (ModState.banned, 2, 'harassment'));

      // Their honest client refuses to post...
      await eventually(() => mesh['Troll'].isBanned, reason: 'troll learns of ban');
      expect(() => mesh['Troll'].post('let me back in'), throwsA(isA<BannedException>()));
      // ...and peers keep only a quarantined link: moderator feeds out,
      // nothing accepted in.
      await eventually(
          () => mesh['Fan']
              .engine
              .sessions
              .where((x) => x.peerRoot == mesh['Troll'].rootId)
              .every((x) => x.quarantined),
          reason: 'quarantined');
    });

    test('a modded client that keeps posting goes nowhere', () async {
      await setUpMods(['Troll', 'Fan']);
      await mesh['Fan'].follow(mesh['Troll'].rootId);
      await mesh['G1'].banVote(mesh['Troll'].rootId);
      await mesh['G2'].banVote(mesh['Troll'].rootId);
      await eventually(() => mesh['Fan'].moderation.isBanned(mesh['Troll'].rootId));

      // Simulate a modded app: bypass the client-side check by signing an event
      // directly and handing it to the Fan, as if a carrier delivered it.
      final f = (await mesh['Troll'].db.feed(mesh['Troll'].feedId))!;
      final e = await SignedEvent.create(
          device: mesh['Troll'].me.device, seq: f.latestSeq + 1, prev: f.latestId,
          lamport: f.latestLamport + 1, ts: 1, type: EventType.post,
          body: Bodies.post(text: 'still here lol'));
      final r = await mesh['Fan'].store.ingest(FeedItem(e, Bodies.post(text: 'still here lol'), 0));
      expect(r, isA<Rejected>());
    });

    test('a vote can be retracted; moderators cannot be banned', () async {
      await setUpMods(['Troll']);
      await mesh['G1'].banVote(mesh['Troll'].rootId);
      await everywhere((n) async => n.moderation.isFlagged(mesh['Troll'].rootId), 'flagged');
      await mesh['G1'].retractBanVote(mesh['Troll'].rootId);
      await everywhere((n) async => !n.moderation.isFlagged(mesh['Troll'].rootId), 'unflagged');

      await mesh['G1'].banVote(mesh['G2'].rootId);
      await mesh['G3'].banVote(mesh['G2'].rootId);
      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(mesh['Troll'].moderation.isBanned(mesh['G2'].rootId), isFalse);
    });
  });

  group('rogue moderators', () {
    Future<void> promote(String name) async {
      final consent = await consentOf(name);
      for (final g in ['G1', 'G2', 'G3']) {
        await mesh[g].vouchModerator(consent);
      }
      await everywhere((n) async => n.moderation.isModerator(mesh[name].rootId), '$name promoted');
    }

    test('one genesis key revokes; later bans by the rogue stop counting', () async {
      await setUpMods(['Rogue', 'Victim', 'Troll']);
      await promote('Rogue');

      // Before revocation the Rogue legitimately flags the Troll.
      await mesh['Rogue'].banVote(mesh['Troll'].rootId);
      await everywhere((n) async => n.moderation.isFlagged(mesh['Troll'].rootId), 'troll flagged');

      await mesh['G1'].revokeModerator(mesh['Rogue'].rootId);
      await everywhere((n) async => !n.moderation.isModerator(mesh['Rogue'].rootId), 'revoked');

      // The rogue (with a modded client) votes against an innocent user.
      await mesh['Rogue'].store.append(EventType.modBan,
          Bodies.modBan(target: mesh['Victim'].rootId, on: true));
      await mesh['G2'].banVote(mesh['Victim'].rootId); // one honest mistake
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(mesh['G3'].moderation.isBanned(mesh['Victim'].rootId), isFalse,
          reason: 'post-revocation vote is void');
      // The pre-revocation flag on the troll still stands.
      expect(mesh['G3'].moderation.isFlagged(mesh['Troll'].rootId), isTrue);
    });

    test('three moderators can revoke a moderator', () async {
      await setUpMods(['M4', 'M5', 'M6', 'Rogue']);
      for (final m in ['M4', 'M5', 'M6', 'Rogue']) {
        await promote(m);
      }
      // Non-genesis voters need a quorum of 3 (a genesis key could act alone).
      await mesh['M4'].revokeModerator(mesh['Rogue'].rootId);
      await mesh['M5'].revokeModerator(mesh['Rogue'].rootId);
      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(mesh['G1'].moderation.isModerator(mesh['Rogue'].rootId), isTrue,
          reason: '2 votes are not enough');
      await mesh['M6'].revokeModerator(mesh['Rogue'].rootId);
      await everywhere((n) async => !n.moderation.isModerator(mesh['Rogue'].rootId),
          'revoked by 3 moderators');
    });
  });

  group('ban evasion with a new key', () {
    test('a fresh key does not spread friend-of-friend for 7 days', () async {
      mesh = await TestMesh.create(['Fresh', 'Friend', 'FoF']);
      await mesh['Friend'].follow(mesh['Fresh'].rootId);
      await mesh['FoF'].follow(mesh['Friend'].rootId);
      final p = await mesh['Fresh'].post('new account who dis');

      mesh.link('Fresh', 'Friend');
      await eventually(() => hasPost(mesh['Friend'], p.id), reason: 'follower gets it');
      mesh.unlink('Fresh', 'Friend');
      mesh.link('Friend', 'FoF');
      await mesh.connected('FoF', 'Friend');
      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(await hasPost(mesh['FoF'], p.id), isFalse, reason: 'newcomer: no FoF reach');

      // A week later the follow edge is established.
      mesh.clock.advance(const Duration(days: 8));
      await mesh['Friend'].post('bump'); // any feed update re-evaluates wants
      await eventually(() => hasPost(mesh['FoF'], p.id), reason: 'established after 7 days');
    });
  });

  group('impersonation', () {
    test('nobody can publish as someone else (forged device cert)', () async {
      mesh = await TestMesh.create(['Maya', 'Impostor', 'Fan']);
      // The impostor certifies their own device as belonging to Maya's root.
      final fakeDevice = await JaalCrypto.signingKeyFromSeed(randomBytes(32));
      final forgedCert = DeviceCert(
        root: mesh['Maya'].rootId,
        device: b64(fakeDevice.publicKey),
        created: 1,
        sig: mesh['Impostor'].me.cert.sig, // can't produce Maya's signature
      );
      final e = await SignedEvent.create(device: fakeDevice, seq: 1, prev: null,
          lamport: 1, ts: 1, type: EventType.deviceCert, body: forgedCert.toJson());
      final r = await mesh['Fan'].store.ingest(FeedItem(e, forgedCert.toJson(), 0));
      expect((r as Rejected).reason, RejectReason.badDeviceCert);
    });

    test('lookalike profiles are flagged; the original is not', () async {
      mesh = await TestMesh.create(['Maya', 'Fan']);
      await mesh['Maya'].setProfile(name: 'Maya', handle: 'maya.offgrid');
      mesh.link('Maya', 'Fan');
      await eventually(() async =>
          (await mesh['Fan'].db.profile(mesh['Maya'].rootId))?.handle == 'maya.offgrid');
      await mesh['Fan'].follow(mesh['Maya'].rootId);

      for (final (i, h) in ['maya_offgrid', 'rnaya.offgrid', 'maya.0ffgrid2'].indexed) {
        final imp = await mesh.add('Imp$i', handle: h);
        await imp.setProfile(name: 'Maya', handle: h);
        mesh.link('Imp$i', 'Fan');
        await eventually(() async => (await mesh['Fan'].db.profile(imp.rootId))?.handle == h);
        final w = await mesh['Fan'].lookalikesOf(imp.rootId);
        expect(w, isNotEmpty, reason: '$h should look like maya.offgrid');
        expect(w.first.lookalikeOf, mesh['Maya'].rootId);
        expect(w.first.message, contains('you follow them'));
      }
      expect(await mesh['Fan'].lookalikesOf(mesh['Maya'].rootId), isEmpty);
    });

    test('QR verification: signed, fresh, and tamper-proof', () async {
      mesh = await TestMesh.create(['Maya', 'Fan']);
      final code = await mesh['Maya'].meetCode();
      final ok = await mesh['Fan'].verifyInPerson(code.encode());
      expect(ok.root, mesh['Maya'].rootId);
      expect(await mesh['Fan'].db.isVerified(mesh['Maya'].rootId), isTrue);
      expect(await mesh['Fan'].db.followingOf(mesh['Fan'].rootId), contains(mesh['Maya'].rootId));

      // Swap in another key but keep Maya's signature: rejected.
      final j = code.toJson()..['root'] = mesh['Fan'].rootId;
      final tampered = MeetCode.fromJson(j).encode();
      expect(() => mesh['Fan'].verifyInPerson(tampered), throwsFormatException);

      mesh.clock.advance(const Duration(minutes: 11));
      expect(() => mesh['Fan'].verifyInPerson(code.encode()), throwsFormatException);
    });
  });
}
