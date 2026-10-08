import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaal_mobile/app/app.dart';
import 'package:jaal_mobile/app/router.dart';
import 'package:jaal_mobile/app/session.dart';
import 'package:jaal_mobile/design/zine.dart';

/// Real async work (SQLite, timers) needs runAsync; pump between waits.
Future<void> settle(WidgetTester tester, {int ms = 400}) => tester.runAsync(() async {
      for (var t = 0; t < ms; t += 20) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        await tester.pump();
      }
    });

Future<bool> waitFor(Future<bool> Function() cond, {int ms = 6000}) async {
  for (var t = 0; t < ms; t += 20) {
    if (await cond()) return true;
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
  return cond();
}

void main() {
  testWidgets('fresh install lands on welcome', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [appEnvProvider.overrideWithValue(AppEnv.memory())],
      child: const JaalApp(),
    ));
    await settle(tester);
    expect(find.text('make me a node'), findsOneWidget);
    expect(find.textContaining('no wifi?'), findsOneWidget);
  });

  testWidgets('create identity → home feed → network lab syncs a peer', (tester) async {
    tester.view.physicalSize = const Size(412 * 2, 915 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final container = ProviderContainer(overrides: [appEnvProvider.overrideWithValue(AppEnv.memory())]);
    addTearDown(container.dispose);

    late String phrase;
    await tester.runAsync(() async {
      await container.read(sessionProvider.future);
      phrase = await container.read(sessionProvider.notifier).create(name: 'Maya', handle: 'maya');
    });
    expect(phrase.split(' '), hasLength(24));

    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const JaalApp()));
    await settle(tester);
    expect(find.text('mesh feed (live)'), findsOneWidget, reason: 'home tab');
    expect(find.text('explore'), findsWidgets, reason: 'bottom nav');

    container.read(routerProvider).push(Routes.lab);
    await settle(tester);
    expect(find.text('network lab'), findsOneWidget);

    // Lab actions do real crypto + SQLite work, so run them in real time.
    final session = container.read(requireSessionProvider);
    await tester.runAsync(() async {
      final peer = await session.lab.addPeer();
      final you = session.lab.peers.firstWhere((p) => !p.virtual);
      session.lab.toggleLink(you, peer);
      expect(await waitFor(() async => await session.node.db.profile(peer.node.rootId) != null), isTrue,
          reason: 'synced the peer profile over the simulated link');
    });
    await settle(tester);
    expect(find.byType(Switch), findsWidgets, reason: 'peer card with the near-you switch');
    await tester.pumpWidget(const SizedBox());
    container.dispose(); // cancels provider timers before the test ends
    await tester.pump(const Duration(seconds: 5)); // flush one-shot fake timers
  });

  testWidgets('the app node honours lab moderators', (tester) async {
    final container = ProviderContainer(overrides: [appEnvProvider.overrideWithValue(AppEnv.memory())]);
    addTearDown(container.dispose);
    await tester.runAsync(() async {
      await container.read(sessionProvider.future);
      await container.read(sessionProvider.notifier).create(name: 'Me', handle: 'me');
      final s = container.read(requireSessionProvider);
      final mods = await s.lab.spawnGenesisModerators();
      final troll = await s.lab.addPeer(name: 'Troll', handle: 'troll');
      s.lab.fullMesh();
      await s.node.follow(troll.node.rootId);
      final p = await troll.node.post('vile');
      expect(await waitFor(() async => await s.node.db.post(p.id) != null), isTrue);
      await s.lab.banVote(mods[0], troll);
      await s.lab.banVote(mods[1], troll);
      expect(await waitFor(() async => s.node.moderation.isBanned(troll.node.rootId)), isTrue);
      expect(await waitFor(() async => await s.node.db.post(p.id) == null), isTrue);
    });
  });

  testWidgets('every tab and screen builds without errors', (tester) async {
    tester.view.physicalSize = const Size(412 * 2, 915 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final container = ProviderContainer(overrides: [appEnvProvider.overrideWithValue(AppEnv.memory())]);
    addTearDown(container.dispose);
    late String peerRoot;
    late String postId;
    await tester.runAsync(() async {
      await container.read(sessionProvider.future);
      await container.read(sessionProvider.notifier).create(name: 'Me', handle: 'me');
      final s = container.read(requireSessionProvider);
      final peer = await s.lab.addPeer(name: 'Zoe', handle: 'zoe');
      s.lab.fullMesh();
      await s.node.follow(peer.node.rootId);
      final e = await peer.node.post('zine stall is up');
      postId = e.id;
      peerRoot = peer.node.rootId;
      await waitFor(() async => await s.node.db.post(postId) != null);
      await s.node.sendDm(peerRoot, 'bring the stickers');
    });
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const JaalApp()));
    final router = container.read(routerProvider);
    final original = FlutterError.onError;
    FlutterError.onError = (d) {
      // Print the full report (includes the error-causing widget location).
      debugPrint(d.toString());
      original?.call(d);
    };
    addTearDown(() => FlutterError.onError = original);
    for (final route in [
      Routes.home,
      Routes.explore,
      Routes.inbox,
      Routes.me,
      Routes.compose,
      Routes.post(postId),
      Routes.profile(peerRoot),
      Routes.chat(peerRoot),
      Routes.nearby,
      Routes.pouch,
      Routes.meet,
      Routes.settings,
      Routes.becomeMod,
      Routes.modDesk,
      Routes.lab,
      Routes.share,
      Routes.link,
    ]) {
      router.go(route);
      await settle(tester, ms: 200);
      final e = tester.takeException();
      if (e != null) fail('$route: ${e is FlutterError ? e.toStringDeep() : e}');
    }
    await tester.pumpWidget(const SizedBox());
    container.dispose(); // cancels provider timers before the test ends
    await tester.pump(const Duration(seconds: 5)); // flush one-shot fake timers
  });

  testWidgets('zine button collapses shadow on press', (tester) async {
    var taps = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: Center(child: ZineButton(label: 'tap', onPressed: () => taps++))),
    ));
    await tester.tap(find.text('tap'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(taps, 1);
  });
}

