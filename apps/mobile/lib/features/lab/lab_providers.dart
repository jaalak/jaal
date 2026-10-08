import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jaal_core/jaal_core.dart';
import 'package:jaal_sim/jaal_sim.dart';

import '../../app/session.dart';

/// Polled snapshots of every peer in the lab (cheap: in-memory DBs).
final labSnapshotsProvider = StreamProvider<List<PeerSnapshot>>((ref) {
  final lab = ref.watch(requireSessionProvider).lab;
  final controller = StreamController<List<PeerSnapshot>>();
  Future<void> poll() async {
    final snaps = <PeerSnapshot>[];
    for (final p in List.of(lab.peers)) {
      try {
        snaps.add(await lab.snapshot(p));
      } on Object {
        // peer removed mid-poll
      }
    }
    if (!controller.isClosed) controller.add(snaps);
  }

  poll();
  final t = Timer.periodic(const Duration(milliseconds: 700), (_) => poll());
  final sub = lab.log.listen((_) => poll());
  ref.onDispose(() {
    t.cancel();
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});

/// The local node's home feed.
final homeFeedProvider = StreamProvider<List<PostRow>>((ref) =>
    ref.watch(requireSessionProvider).node.watchHomeFeed());

/// Every post the local node holds (for the debug console).
final allPostsProvider = StreamProvider<List<PostRow>>((ref) =>
    ref.watch(requireSessionProvider).node.db.watchAllPosts());

final profilesProvider = StreamProvider<List<ProfileRow>>((ref) =>
    ref.watch(requireSessionProvider).node.db.watchProfiles());

final followingProvider = StreamProvider<Set<String>>((ref) {
  final node = ref.watch(requireSessionProvider).node;
  return node.db.watchFollowingOf(node.rootId);
});

final inboxProvider = StreamProvider<List<MessageRow>>((ref) =>
    ref.watch(requireSessionProvider).node.db.watchInbox());

final carryPouchProvider = StreamProvider<List<EnvelopeRow>>((ref) {
  final node = ref.watch(requireSessionProvider).node;
  return node.db.watchCarryPouch(DateTime.now().millisecondsSinceEpoch);
});

final courierCloutProvider = StreamProvider<int>((ref) => ref
    .watch(requireSessionProvider)
    .node
    .db
    .watchStat(StatKey.courierDelivered));
