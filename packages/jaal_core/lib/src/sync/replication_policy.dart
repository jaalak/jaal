import 'package:drift/drift.dart';

import '../db/database.dart';
import '../identity/identity.dart';

/// Decides which feeds this node replicates (protocol/SPEC.md §5.2):
///
/// 1. our own root,
/// 2. roots we follow,
/// 3. roots directly connected to us right now (so you can discover the
///    people physically around you),
/// 4. moderators' *moderation feeds* — always, so bans and vouches reach
///    every phone (their personal posts only if wanted for another reason),
/// 5. roots our follows follow ("friends of friends"), up to [maxFofRoots],
///    but only **established** ones: we first saw them ≥ [newcomerWindow]
///    ago, or someone we follow has followed them for that long. A fresh key
///    (e.g. a banned user starting over) reaches only its followers and the
///    people physically near it until then.
///
/// Banned and blocked roots are never replicated.
///
/// For moderators who aren't otherwise wanted, only their small moderation
/// feeds are replicated — not their personal posts.
class ReplicationPolicy {
  const ReplicationPolicy({
    this.friendsOfFriends = true,
    this.maxFofRoots = 150,
    this.newcomerWindow = const Duration(days: 7),
    this.everything = false,
  });

  final bool friendsOfFriends;
  final int maxFofRoots;
  final Duration newcomerWindow;

  /// Relay / test mode: want every feed that isn't blocked or banned.
  final bool everything;

  Future<Wanted> wanted(JaalDatabase db, RootId me,
      {Iterable<RootId> directPeers = const [], required int now}) async {
    final excluded = {...await db.blockedRoots(), ...await db.bannedRoots()};
    final mods = await db.moderatorRoots();
    if (everything) return Wanted(const {}, mods, excluded, all: true);
    final roots = await wantedRoots(db, me, directPeers: directPeers, now: now);
    return Wanted(roots, mods, excluded);
  }

  Future<Set<RootId>> wantedRoots(
    JaalDatabase db,
    RootId me, {
    Iterable<RootId> directPeers = const [],
    required int now,
  }) async {
    final excluded = {...await db.blockedRoots(), ...await db.bannedRoots()};
    final following = await db.followingOf(me);
    final wanted = <RootId>{me, ...following, ...directPeers};
    if (friendsOfFriends && following.isNotEmpty) {
      final cutoff = now - newcomerWindow.inMilliseconds;
      final marks = List.filled(following.length, '?').join(',');
      final rows = await db.customSelect(
        'SELECT f.target AS target, COUNT(*) AS n FROM follows f '
        'JOIN events e ON e.id = f.event_id '
        'WHERE f.is_on = 1 AND f.root_id IN ($marks) '
        '  AND (e.ts <= ? OR f.target IN ('
        '       SELECT root_id FROM events GROUP BY root_id '
        '       HAVING MIN(first_seen_at) <= ?)) '
        'GROUP BY f.target ORDER BY n DESC LIMIT ?',
        variables: [
          for (final f in following) Variable.withString(f),
          Variable.withInt(cutoff),
          Variable.withInt(cutoff),
          Variable.withInt(maxFofRoots),
        ],
        readsFrom: {db.follows, db.events},
      ).get();
      wanted.addAll(rows.map((r) => r.read<String>('target')));
    }
    return wanted..removeAll(excluded);
  }
}

/// What a node wants from a peer's inventory.
class Wanted {
  const Wanted(this.roots, this.moderators, this.excluded, {this.all = false});
  final Set<RootId> roots;
  final Set<RootId> moderators;
  final Set<RootId> excluded;
  final bool all;

  bool feed(RootId root, {required bool modFeed}) {
    if (excluded.contains(root)) return false;
    if (all || roots.contains(root)) return true;
    return modFeed && moderators.contains(root);
  }
}
