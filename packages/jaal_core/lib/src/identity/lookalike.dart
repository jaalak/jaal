import 'package:drift/drift.dart';

import '../db/database.dart';
import 'identity.dart';

/// Anti-impersonation (protocol/SPEC.md §11).
///
/// Nobody can *forge* another person's posts: that needs their private key.
/// What an impersonator can do is mint a new key with the same name, handle
/// and photo. [Lookalikes] spots that: it normalises names into a
/// "skeleton" (case, separators, digit/letter confusables, trailing
/// numbers) and flags any profile whose skeleton collides with someone
/// already established for you.
abstract final class Lookalikes {
  static const _confusables = {
    '0': 'o', '1': 'l', 'i': 'l', '|': 'l', '3': 'e', '4': 'a', '@': 'a',
    '5': 's', '\$': 's', '7': 't', '8': 'b', '9': 'g', '6': 'g', '2': 'z',
  };

  /// Reduces a handle or name to the shape a human reads at a glance.
  static String skeleton(String s) {
    var t = s.toLowerCase().replaceAll(RegExp(r'[\s._\-·]+'), '');
    t = t.replaceAll(RegExp(r'\d+$'), ''); // maya → maya2, maya_99
    t = t.replaceAll('rn', 'm').replaceAll('vv', 'w').replaceAll('cl', 'd');
    final sb = StringBuffer();
    for (final ch in t.split('')) {
      sb.write(_confusables[ch] ?? ch);
    }
    return sb.toString();
  }

  /// Wires [skeleton] into the database (for indexed skeleton columns).
  static void install() => JaalDatabase.skeletonOf = skeleton;

  /// Warnings for [root]: established people whose handle or name looks the
  /// same. Empty if [root] is itself established (you follow or verified
  /// it) — the *newcomer* gets the warning, not the original.
  static Future<List<LookalikeWarning>> check(
      JaalDatabase db, RootId me, RootId root) async {
    install();
    final p = await db.profile(root);
    if (p == null || root == me) return const [];
    final following = await db.followingOf(me);
    final verified = await (db.select(db.verified)).get();
    final verifiedSet = verified.map((v) => v.rootId).toSet();
    bool trusted(RootId r) =>
        r == me || following.contains(r) || verifiedSet.contains(r);
    if (trusted(root)) return const [];

    final mine = await db.firstSeenOf(root);
    final hs = skeleton(p.handle), ns = skeleton(p.name);
    final out = <LookalikeWarning>[];
    // Indexed lookup: only profiles whose skeleton collides.
    final candidates = await (db.select(db.profiles)
          ..where((x) =>
              x.handleSkel.equals(hs) |
              (ns.length >= 3 ? x.nameSkel.equals(ns) : const Constant(false))))
        .get();
    for (final other in candidates) {
      if (other.rootId == root) continue;
      final sameHandle = skeleton(other.handle) == hs;
      final sameName = ns.length >= 3 && skeleton(other.name) == ns;
      if (!sameHandle && !sameName) continue;
      final theirs = await db.firstSeenOf(other.rootId);
      final older = theirs != null && (mine == null || theirs < mine);
      if (!trusted(other.rootId) && !older) continue;
      out.add(LookalikeWarning(
        root: root,
        lookalikeOf: other.rootId,
        handle: other.handle,
        sameHandle: sameHandle,
        sameName: sameName,
        originalVerified: verifiedSet.contains(other.rootId),
        originalFollowed: following.contains(other.rootId) || other.rootId == me,
      ));
    }
    return out;
  }
}

class LookalikeWarning {
  const LookalikeWarning({
    required this.root,
    required this.lookalikeOf,
    required this.handle,
    required this.sameHandle,
    required this.sameName,
    required this.originalVerified,
    required this.originalFollowed,
  });

  final RootId root;
  final RootId lookalikeOf;
  final String handle;
  final bool sameHandle, sameName;
  final bool originalVerified, originalFollowed;

  /// e.g. "looks like @maya·k7f2 (verified in person) — different key"
  String get message =>
      'looks like @$handle·${fingerprintOf(lookalikeOf)}'
      '${originalVerified ? ' (verified in person)' : originalFollowed ? ' (you follow them)' : ''}'
      ' — different key';
}
