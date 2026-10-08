// Renders every screen with seeded mesh data to PNGs for visual review
// against the Stitch exports (docs/stitch/exports).
//
//   flutter test test_goldens --update-goldens
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaal_core/jaal_core.dart';
import 'package:jaal_mobile/app/app.dart';
import 'package:jaal_mobile/app/router.dart';
import 'package:jaal_mobile/app/session.dart';

Future<void> settle(WidgetTester tester, {int ms = 600}) => tester.runAsync(() async {
      for (var t = 0; t < ms; t += 25) {
        await Future<void>.delayed(const Duration(milliseconds: 25));
        await tester.pump();
      }
    });

Future<bool> waitFor(Future<bool> Function() cond, {int ms = 8000}) async {
  for (var t = 0; t < ms; t += 25) {
    if (await cond()) return true;
    await Future<void>.delayed(const Duration(milliseconds: 25));
  }
  return cond();
}

void main() {
  testWidgets('screens', (tester) async {
    tester.view.physicalSize = const Size(412 * 2, 1400 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    final container = ProviderContainer(overrides: [appEnvProvider.overrideWithValue(AppEnv.memory())]);
    late String zoe, maya, postId;
    await tester.runAsync(() async {
      await container.read(sessionProvider.future);
      await container.read(sessionProvider.notifier).create(name: 'Prajod', handle: 'prajod');
      final s = container.read(requireSessionProvider);
      final me = s.node;
      final photos = [
        for (var i = 1; i <= 5; i++) (await rootBundle.load('assets/lab/photo-$i.jpg')).buffer.asUint8List(),
      ];
      final mods = await s.lab.spawnGenesisModerators();
      final z = await s.lab.addPeer(name: 'Zoe', handle: 'zoe.zine', bio: 'i make zines nobody asked for');
      final m = await s.lab.addPeer(name: 'Maya', handle: 'maya.offgrid', bio: 'film cams + mountain wifi refusal');
      final a = await s.lab.addPeer(name: 'Arjun', handle: 'arjun_rn');
      zoe = z.node.rootId;
      maya = m.node.rootId;
      for (final p in [z, m, a]) {
        await me.follow(p.node.rootId);
      }
      await z.node.follow(maya);
      final post = await m.node.postPhotos('summit selfie (no signal up here)',
          [CompressedPhoto(photos[1], 900, 900, photos[1].length)]);
      postId = post.id;
      await z.node.postPhotos('underground night market zine stall is up. come trade patches.',
          [CompressedPhoto(photos[0], 900, 900, photos[0].length)]);
      await a.node.post('remember: if you leave the valley tonight, leave your bluetooth on.');
      await me.post('first drop from my pocket. no wifi? no problem.');
      s.lab.fullMesh();
      await waitFor(() async => (await me.db.watchAllPosts().first).length >= 4);
      await waitFor(() async {
        final row = await me.db.post(postId);
        if (row == null) return false;
        return await me.media.read(JaalNode.mediaOf(row).first.hash) != null;
      });
      for (final p in [z, a]) {
        await p.node.react(postId, sticker: p == z ? 'fire' : 'real', x: p == z ? 220 : 700, y: 300, rot: p == z ? -9 : 7);
      }
      await me.react(postId, sticker: 'peak', x: 520, y: 760, rot: 4);
      await z.node.comment(postId, 'grabbed 2 copies! carrying them to north campus');
      await me.sendDm(zoe, 'bring the stickers');
      await z.node.sendDm(me.rootId, 'deal. look for the bike with pink duct tape.');
      final troll = await s.lab.addPeer(name: 'Troll', handle: 'ragebait99');
      s.lab.fullMesh();
      await troll.node.post('something toxic');
      await waitFor(() async => await me.db.profile(troll.node.rootId) != null);
      await s.lab.banVote(mods[0], troll, reason: 'harassment');
      await waitFor(() async => me.moderation.isFlagged(troll.node.rootId));
      await waitFor(() async => (await me.db.watchInbox().first).isNotEmpty);
      await Future<void>.delayed(const Duration(seconds: 1));
    });

    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const JaalApp()));
    final router = container.read(routerProvider);
    final shots = <String, String>{
      'home': Routes.home,
      'post-detail': Routes.post(postId),
      'profile-maya': Routes.profile(maya),
      'profile-me': Routes.me,
      'compose': Routes.compose,
      'inbox': Routes.inbox,
      'chat': Routes.chat(zoe),
      'nearby': Routes.nearby,
      'pouch': Routes.pouch,
      'explore': Routes.explore,
      'meet': Routes.meet,
      'settings': Routes.settings,
      'become-mod': Routes.becomeMod,
      'lab': Routes.lab,
    };
    for (final MapEntry(key: name, value: route) in shots.entries) {
      router.go(route);
      await settle(tester, ms: 900);
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/$name.png'));
    }
    await tester.pumpWidget(const SizedBox());
    container.dispose();
    await tester.pump(const Duration(seconds: 5));
  });
}

