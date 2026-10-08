import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jaal_core/jaal_core.dart';

import '../../app/session.dart';

/// The running local node.
final nodeProvider = Provider<JaalNode>((ref) => ref.watch(requireSessionProvider).node);

// ------------------------------------------------------------------ people

/// Every profile we hold, keyed by root.
final profilesProvider = StreamProvider<Map<String, ProfileRow>>((ref) => ref
    .watch(nodeProvider)
    .db
    .watchProfiles()
    .map((l) => {for (final p in l) p.rootId: p}));

final profileProvider = Provider.family<ProfileRow?, String>(
    (ref, root) => ref.watch(profilesProvider).value?[root]);

final followingProvider = StreamProvider<Set<String>>((ref) {
  final n = ref.watch(nodeProvider);
  return n.db.watchFollowingOf(n.rootId);
});

final followersCountProvider = StreamProvider.family<int, String>(
    (ref, root) => ref.watch(nodeProvider).db.watchFollowerCount(root));

final followingCountProvider = StreamProvider.family<int, String>((ref, root) => ref
    .watch(nodeProvider)
    .db
    .watchFollowingOf(root)
    .map((s) => s.length));

final verifiedProvider = StreamProvider<Set<String>>((ref) => ref.watch(nodeProvider).db.watchVerified());

final petnamesProvider =
    StreamProvider<Map<String, String>>((ref) => ref.watch(nodeProvider).db.watchPetnames());

final lookalikesProvider = FutureProvider.autoDispose.family<List<LookalikeWarning>, String>((ref, root) {
  ref.watch(profilesProvider);
  ref.watch(followingProvider);
  ref.watch(verifiedProvider);
  return ref.watch(nodeProvider).lookalikesOf(root);
});

// --------------------------------------------------------------- moderation

/// Re-evaluated whenever moderation events land (their state lives in
/// derived tables, so watch those).
final moderatorsProvider = StreamProvider<Set<String>>((ref) => ref
    .watch(nodeProvider)
    .db
    .watchModerators()
    .map((l) => l.map((m) => m.rootId).toSet()));

final modStatusProvider = StreamProvider<Map<String, ModStatusRow>>((ref) => ref
    .watch(nodeProvider)
    .db
    .watchModStatus()
    .map((l) => {for (final s in l) s.rootId: s}));

final meBannedProvider = Provider<bool>((ref) {
  ref.watch(modStatusProvider);
  final n = ref.watch(nodeProvider);
  return n.isBanned;
});

// -------------------------------------------------------------------- posts

final homeFeedProvider = StreamProvider<List<PostRow>>((ref) => ref.watch(nodeProvider).watchHomeFeed());

final allPostsProvider =
    StreamProvider<List<PostRow>>((ref) => ref.watch(nodeProvider).db.watchAllPosts(limit: 300));

final postsByProvider = StreamProvider.family<List<PostRow>, String>(
    (ref, root) => ref.watch(nodeProvider).db.watchPostsBy(root));

final postProvider = StreamProvider.autoDispose.family<PostRow?, String>(
    (ref, id) => ref.watch(nodeProvider).db.watchPost(id));

final reactionsProvider = StreamProvider.autoDispose.family<List<ReactionRow>, String>(
    (ref, postId) => ref.watch(nodeProvider).db.watchReactions(postId));

final commentsProvider = StreamProvider.autoDispose.family<List<CommentRow>, String>(
    (ref, postId) => ref.watch(nodeProvider).db.watchComments(postId));

final commentCountProvider = Provider.autoDispose.family<int, String>(
    (ref, postId) => ref.watch(commentsProvider(postId)).value?.length ?? 0);

// -------------------------------------------------------------------- media

final mediaProgressProvider = StreamProvider.autoDispose.family<MediaProgress?, String>(
    (ref, hash) => ref.watch(nodeProvider).media.watch(hash));

/// Assembled bytes once complete (null while chunks are still arriving).
final mediaBytesProvider = FutureProvider.autoDispose.family<Uint8List?, String>((ref, hash) async {
  final p = ref.watch(mediaProgressProvider(hash)).value;
  if (p == null || !p.complete) return null;
  ref.keepAlive();
  return ref.watch(nodeProvider).media.read(hash);
});

// --------------------------------------------------------------- messaging

final inboxProvider = StreamProvider<List<MessageRow>>((ref) => ref.watch(nodeProvider).db.watchInbox());

final conversationProvider = StreamProvider.autoDispose.family<List<MessageRow>, String>(
    (ref, peer) => ref.watch(nodeProvider).db.watchConversation(peer));

final carryPouchProvider = StreamProvider<List<EnvelopeRow>>(
    (ref) => ref.watch(nodeProvider).db.watchCarryPouch(DateTime.now().millisecondsSinceEpoch));

final courierCloutProvider =
    StreamProvider<int>((ref) => ref.watch(nodeProvider).db.watchStat(StatKey.courierDelivered));

/// Delivered carried envelopes (recent courier deliveries).
final deliveriesProvider =
    StreamProvider<List<EnvelopeRow>>((ref) => ref.watch(nodeProvider).db.watchDeliveries());

final searchProvider = StreamProvider.autoDispose.family<List<PostRow>, String>(
    (ref, q) => ref.watch(nodeProvider).db.watchSearch(q));

// --------------------------------------------------------------- proximity

/// Live sessions (nearby + syncing). Polled lightly: session stats change
/// on every frame, the list itself on connect/disconnect.
final sessionsProvider = StreamProvider<List<SyncSession>>((ref) {
  final engine = ref.watch(nodeProvider).engine;
  final c = StreamController<List<SyncSession>>();
  void emit() {
    if (!c.isClosed) c.add(engine.sessions.where((s) => !s.quarantined).toList());
  }

  emit();
  final sub = engine.sessionsChanged.listen((_) => emit());
  final t = Timer.periodic(const Duration(seconds: 1), (_) => emit());
  ref.onDispose(() {
    sub.cancel();
    t.cancel();
    c.close();
  });
  return c.stream;
});

final nearbyRootsProvider = Provider<Set<String>>((ref) =>
    (ref.watch(sessionsProvider).value ?? const []).map((s) => s.peerRoot).whereType<String>().toSet());

final peersSeenProvider = StreamProvider<List<PeerSeenRow>>((ref) => ref.watch(nodeProvider).db.watchPeersSeen());
