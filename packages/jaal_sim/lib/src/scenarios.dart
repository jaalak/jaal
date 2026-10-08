import 'dart:async';

import 'package:jaal_core/jaal_core.dart';

import 'network_lab.dart';

/// Outcome of a scripted scenario.
class ScenarioResult {
  ScenarioResult(this.name);
  final String name;
  final List<String> lines = [];
  bool passed = true;
  final Stopwatch clock = Stopwatch()..start();

  void say(String s) => lines.add(s);

  void expect(bool ok, String what) {
    lines.add('${ok ? '✓' : '✗'} $what');
    if (!ok) passed = false;
  }
}

Future<bool> _until(FutureOr<bool> Function() cond,
    {Duration timeout = const Duration(seconds: 30)}) async {
  final sw = Stopwatch()..start();
  while (!await cond()) {
    if (sw.elapsed > timeout) return false;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  return true;
}

typedef Scenario = Future<ScenarioResult> Function(NetworkLab lab);

/// Named scenarios runnable from the CLI and the Network Lab.
final Map<String, (String, Scenario)> scenarios = {
  'mesh': ('everyone in range: posts converge everywhere', meshScenario),
  'courier': ('a stranger carries a sealed DM and a post across town', courierScenario),
  'market': ('people drift in and out of range while chatting', marketScenario),
  'flaky': ('a bad link keeps breaking; sync resumes until done', flakyScenario),
  'moderation': ('3 vouches make a moderator; 2 votes remove a troll', moderationScenario),
};

Future<ScenarioResult> meshScenario(NetworkLab lab, {int peers = 6}) async {
  final r = ScenarioResult('mesh');
  for (var i = 0; i < peers; i++) {
    await lab.addPeer();
  }
  for (final p in lab.peers) {
    await p.node.post('hello from ${p.name}');
  }
  final sw = Stopwatch()..start();
  lab.fullMesh();
  final ok = await _until(() async {
    for (final p in lab.peers) {
      if ((await p.node.db.select(p.node.db.posts).get()).length < peers) {
        return false;
      }
    }
    return true;
  });
  r.expect(ok, 'all $peers peers hold all $peers posts');
  r.say('converged in ${sw.elapsedMilliseconds}ms, '
      '${lab.net.framesSent} frames / ${(lab.net.bytesSent / 1024).toStringAsFixed(1)} KiB');
  return r;
}

Future<ScenarioResult> courierScenario(NetworkLab lab) async {
  final r = ScenarioResult('courier');
  final maya = await lab.addPeer(name: 'Maya', handle: 'maya');
  final arjun = await lab.addPeer(name: 'Arjun', handle: 'arjun');
  final dev = await lab.addPeer(name: 'Dev', handle: 'dev');

  // Maya and Dev met once (exchanged profiles via QR) — then went apart.
  lab.setLink(maya, dev, const LinkConfig());
  await _until(() async => await maya.node.db.profile(dev.node.rootId) != null);
  await dev.node.follow(maya.node.rootId);
  await arjun.node.follow(maya.node.rootId);
  lab.setLink(maya, dev, const LinkConfig(up: false));
  await _until(() => maya.node.engine.sessions.isEmpty);

  final post = await maya.node.post('summit selfie (no signal up here)');
  final msg = await maya.node.sendDm(dev.node.rootId, 'made it to the top!!');
  r.say('Maya posted + sealed a DM for Dev while alone');

  lab.setLink(maya, arjun, const LinkConfig());
  r.expect(
      await _until(() async =>
          await arjun.node.db.post(post.id) != null &&
          await arjun.node.db.stat(StatKey.courierCarried) >= 1),
      'Arjun picked up the post and the sealed envelope');
  lab.setLink(maya, arjun, const LinkConfig(up: false));

  lab.setLink(arjun, dev, const LinkConfig());
  r.expect(await _until(() async => await dev.node.db.post(post.id) != null),
      'Dev got Maya\'s post via Arjun');
  r.expect(
      await _until(() async =>
          (await dev.node.db.select(dev.node.db.messages).get()).isNotEmpty),
      'Dev opened the DM');
  r.expect(
      await _until(() async =>
          await arjun.node.db.stat(StatKey.courierDelivered) >= 1),
      'Arjun earned courier clout from the receipt');
  final row = (await dev.node.db.post(post.id))!;
  r.say('postmark: ${row.hops} hops');

  lab.setLink(arjun, dev, const LinkConfig(up: false));
  lab.setLink(arjun, maya, const LinkConfig());
  r.expect(
      await _until(() async =>
          (await (maya.node.db.select(maya.node.db.messages)
                    ..where((m) => m.id.equals(msg.id)))
                  .getSingle())
              .delivered),
      'Maya sees "delivered" once Arjun returns');
  return r;
}

Future<ScenarioResult> marketScenario(NetworkLab lab,
    {int peers = 8, Duration duration = const Duration(seconds: 8)}) async {
  final r = ScenarioResult('market');
  for (var i = 0; i < peers; i++) {
    await lab.addPeer();
  }
  lab.fullMesh();
  await _until(() async {
    for (final p in lab.peers) {
      if ((await p.node.db.select(p.node.db.profiles).get()).length < peers) {
        return false;
      }
    }
    return true;
  });
  await lab.seedFollowGraph(p: 0.4);
  lab.isolateAll();
  lab.startChatter(every: const Duration(milliseconds: 60));
  final end = DateTime.now().add(duration);
  var shuffles = 0;
  while (DateTime.now().isBefore(end)) {
    lab.shuffleProximity(density: 0.25);
    shuffles++;
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }
  lab.stopChatter();
  var sent = 0, received = 0, delivered = 0, carried = 0;
  for (final p in lab.peers) {
    final msgs = await p.node.db.select(p.node.db.messages).get();
    sent += msgs.where((m) => m.outgoing).length;
    received += msgs.where((m) => !m.outgoing).length;
    delivered += msgs.where((m) => m.outgoing && m.delivered).length;
    carried += await p.node.db.stat(StatKey.courierDelivered);
  }
  r.say('$shuffles proximity shuffles, ${lab.net.framesSent} frames');
  r.say('DMs: $sent sent, $received received, $delivered sender-confirmed, '
      '$carried courier deliveries');
  r.expect(received > 0, 'some DMs crossed the mesh');
  return r;
}

Future<ScenarioResult> flakyScenario(NetworkLab lab, {int posts = 200}) async {
  final r = ScenarioResult('flaky');
  final a = await lab.addPeer(name: 'Leo', handle: 'leo');
  final b = await lab.addPeer(name: 'Isha', handle: 'isha');
  for (var i = 0; i < posts; i++) {
    await a.node.post('backlog #$i');
  }
  var breaks = 0;
  final sub = lab.net.events.listen((e) {
    if (e is LinkBroke) breaks++;
  });
  final sw = Stopwatch()..start();
  lab.setLink(a, b, const LinkConfig(dropChance: 0.05));
  final ok = await _until(
      () async => (await b.node.db.select(b.node.db.posts).get()).length == posts,
      timeout: const Duration(seconds: 60));
  await sub.cancel();
  r.expect(ok, 'all $posts posts arrived despite the link');
  r.say('$breaks link breaks, ${sw.elapsedMilliseconds}ms');
  return r;
}

Future<ScenarioResult> moderationScenario(NetworkLab lab) async {
  final r = ScenarioResult('moderation');
  if (lab.genesis.length < 3) {
    r.expect(false, 'needs NetworkLab.create() (lab genesis keys)');
    return r;
  }
  final mods = await lab.spawnGenesisModerators();
  final zoe = await lab.addPeer(name: 'Zoe', handle: 'zoe');
  final troll = await lab.addPeer(name: 'Troll', handle: 'troll');
  final fan = await lab.addPeer(name: 'Fan', handle: 'fan');
  lab.fullMesh();
  await _until(() async {
    for (final p in lab.peers) {
      if ((await p.node.db.select(p.node.db.profiles).get()).length < lab.peers.length) {
        return false;
      }
    }
    return true;
  });
  await fan.node.follow(troll.node.rootId);

  for (final m in mods) {
    await lab.vouch(m, zoe);
  }
  r.expect(
      await _until(() => lab.peers.every((p) => p.node.moderation.isModerator(zoe.node.rootId))),
      'zoe became a moderator on every phone after 3 in-person vouches');

  final post = await troll.node.post('something vile');
  await _until(() async => await fan.node.db.post(post.id) != null);

  await lab.banVote(zoe, troll, reason: 'harassment');
  r.expect(
      await _until(() async => (await fan.node.watchHomeFeed().first).isEmpty),
      'one vote: troll flagged and hidden from feeds');
  await lab.banVote(mods.first, troll, reason: 'harassment');
  r.expect(
      await _until(() async =>
          fan.node.moderation.isBanned(troll.node.rootId) &&
          await fan.node.db.post(post.id) == null),
      'second vote: troll banned and their posts purged');
  r.expect(await _until(() => troll.node.isBanned),
      "troll's own app learns it was removed (quarantined link)");
  try {
    await troll.node.post('let me back in');
    r.expect(false, 'troll can no longer post');
  } on BannedException {
    r.expect(true, 'troll can no longer post');
  }

  final imp = await lab.spawnImpostor(zoe);
  lab.fullMesh();
  await _until(() async => await fan.node.db.profile(imp.node.rootId) != null);
  await fan.node.follow(zoe.node.rootId);
  final w = await fan.node.lookalikesOf(imp.node.rootId);
  r.expect(w.isNotEmpty, 'impostor flagged: ${w.isEmpty ? '-' : w.first.message}');
  return r;
}
