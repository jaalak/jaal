import 'dart:async';

import 'package:jaal_core/jaal_core.dart';

/// Polls [cond] until it's true or [timeout] elapses.
Future<void> eventually(
  FutureOr<bool> Function() cond, {
  Duration timeout = const Duration(seconds: 10),
  String? reason,
}) async {
  final sw = Stopwatch()..start();
  while (!await cond()) {
    if (sw.elapsed > timeout) {
      throw TimeoutException('condition not met: ${reason ?? 'eventually'}');
    }
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}

Future<LocalIdentity> newIdentity(Clock clock) async =>
    LocalIdentity.create(await RootIdentity.generate(), now: clock.nowMs());

/// A handful of simulated peers on one [SimNetwork].
class TestMesh {
  TestMesh._(this.net, this.clock);

  final SimNetwork net;
  final ManualClock clock;
  final Map<String, JaalNode> nodes = {};

  /// [genesis] names become the genesis moderators.
  static Future<TestMesh> create(List<String> names,
      {ReplicationPolicy policy = const ReplicationPolicy(),
      int maxCarryBytes = 20 * 1024 * 1024,
      List<String> genesis = const [],
      bool start = true}) async {
    final m = TestMesh._(SimNetwork(), ManualClock());
    final ids = {for (final n in names) n: await newIdentity(m.clock)};
    final config = ModerationConfig(
        genesis: {for (final g in genesis) ids[g]!.rootId});
    for (final n in names) {
      await m.add(n, identity: ids[n]!, policy: policy,
          maxCarryBytes: maxCarryBytes, config: config, start: start);
    }
    return m;
  }

  ModerationConfig get config =>
      nodes.isEmpty ? const ModerationConfig() : nodes.values.first.moderation.config;

  /// Adds a node (e.g. a newcomer mid-test) sharing the mesh's rules.
  Future<JaalNode> add(String n,
      {LocalIdentity? identity,
      ReplicationPolicy policy = const ReplicationPolicy(),
      int maxCarryBytes = 20 * 1024 * 1024,
      ModerationConfig? config,
      String? handle,
      bool start = true}) async {
    final node = await JaalNode.open(
      identity: identity ?? await newIdentity(clock),
      db: JaalDatabase.memory(),
      transports: [net.transport(n)],
      clock: clock,
      policy: policy,
      maxCarryBytes: maxCarryBytes,
      moderationConfig: config ?? this.config,
      retryDelay: const Duration(milliseconds: 20),
      name: n,
    );
    await node.setProfile(name: n, handle: handle ?? 'peer_${n.toLowerCase()}');
    nodes[n] = node;
    if (start) await node.start();
    return node;
  }

  JaalNode operator [](String name) => nodes[name]!;

  void link(String a, String b, {LinkConfig config = const LinkConfig()}) =>
      net.setLink(a, b, config);

  void unlink(String a, String b) =>
      net.setLink(a, b, const LinkConfig(up: false));

  /// Waits until [a] and [b] have a live session.
  Future<void> connected(String a, String b) => eventually(
        () => this[a].engine.connectedRoots.contains(this[b].rootId),
        reason: '$a connected to $b',
      );

  Future<void> disconnected(String a, String b) => eventually(
        () => !this[a].engine.connectedRoots.contains(this[b].rootId),
        reason: '$a disconnected from $b',
      );

  Future<void> dispose() async {
    for (final n in nodes.values) {
      await n.close();
    }
    await net.dispose();
  }
}

Future<int> postCount(JaalNode n) async =>
    (await n.db.select(n.db.posts).get()).where((p) => !p.deleted).length;

Future<bool> hasPost(JaalNode n, String id) async => await n.db.post(id) != null;
