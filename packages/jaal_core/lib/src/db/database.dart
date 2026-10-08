import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'tables.dart';

export 'tables.dart';

part 'database.g.dart';

/// Local-first store for one node. The replicated log (feeds + events) is the
/// source of truth; the remaining tables are projections or local state.
@DriftDatabase(tables: [
  Feeds,
  Events,
  Profiles,
  Posts,
  Reactions,
  Comments,
  Follows,
  Tombstones,
  Envelopes,
  Acks,
  Messages,
  Blocks,
  PeersSeen,
  Stats,
  ModActions,
  Moderators,
  ModStatus,
  ModRevocations,
  Verified,
  Petnames,
  MediaBlobs,
  MediaChunks,
])
class JaalDatabase extends _$JaalDatabase {
  JaalDatabase(super.e);

  /// In-memory database for tests and simulated peers. Many of these exist
  /// at once (one per simulated peer), each with its own executor.
  factory JaalDatabase.memory() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    return JaalDatabase(NativeDatabase.memory());
  }

  /// File-backed database; [file] is created if missing.
  factory JaalDatabase.file(File file) =>
      JaalDatabase(NativeDatabase.createInBackground(file));

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // v2: moderation + anti-impersonation tables.
            await m.createTable(modActions);
            await m.createTable(moderators);
            await m.createTable(modStatus);
            await m.createTable(modRevocations);
            await m.createTable(verified);
            await m.createTable(petnames);
            await customStatement(
                'CREATE INDEX idx_mod_actions_target ON mod_actions (target)');
          }
          if (from < 3) {
            // v3: media blobs + chunks.
            await m.createTable(mediaBlobs);
            await m.createTable(mediaChunks);
          }
          if (from < 4) {
            // v4: moderation feeds + indexed lookalike skeletons.
            await m.addColumn(feeds, feeds.purpose);
            await m.addColumn(profiles, profiles.handleSkel);
            await m.addColumn(profiles, profiles.nameSkel);
            await _createV4Indexes();
            for (final p in await select(profiles).get()) {
              await (update(profiles)..where((x) => x.rootId.equals(p.rootId))).write(
                  ProfilesCompanion(
                      handleSkel: Value(skeletonOf(p.handle)), nameSkel: Value(skeletonOf(p.name))));
            }
          }
        },
        onCreate: (m) async {
          await m.createAll();
          await _createV4Indexes();
          await customStatement(
              'CREATE INDEX idx_mod_actions_target ON mod_actions (target)');
          await customStatement(
              'CREATE INDEX idx_events_feed_seq ON events (feed_id, seq)');
          await customStatement(
              'CREATE INDEX idx_posts_ts ON posts (ts DESC)');
          await customStatement(
              'CREATE INDEX idx_comments_target ON comments (target, ts)');
          await customStatement(
              'CREATE INDEX idx_reactions_target ON reactions (target)');
          await customStatement(
              'CREATE INDEX idx_envelopes_hint ON envelopes (hint)');
        },
      );

  Future<void> _createV4Indexes() async {
    await customStatement('CREATE INDEX IF NOT EXISTS idx_profiles_hskel ON profiles (handle_skel)');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_profiles_nskel ON profiles (name_skel)');
  }

  /// Hook for the lookalike skeleton function (set by identity/lookalike.dart
  /// to avoid a db → identity import cycle).
  static String Function(String) skeletonOf = (s) => s.toLowerCase();

  // ------------------------------------------------------------------ feeds

  Future<FeedRow?> feed(String feedId) =>
      (select(feeds)..where((f) => f.feedId.equals(feedId))).getSingleOrNull();

  Future<List<FeedRow>> allFeeds() => select(feeds).get();

  Stream<List<FeedRow>> watchFeeds() =>
      (select(feeds)..orderBy([(f) => OrderingTerm.asc(f.rootId)])).watch();

  Future<int> maxLamport() async {
    final row = await customSelect(
            'SELECT COALESCE(MAX(lamport), 0) AS m FROM events')
        .getSingle();
    return row.read<int>('m');
  }

  // ----------------------------------------------------------------- events

  Future<EventRow?> eventById(String id) =>
      (select(events)..where((e) => e.id.equals(id))).getSingleOrNull();

  Future<List<EventRow>> eventsFrom(String feedId, int fromSeq,
          {int limit = 64}) =>
      (select(events)
            ..where((e) => e.feedId.equals(feedId) & e.seq.isBiggerOrEqualValue(fromSeq))
            ..orderBy([(e) => OrderingTerm.asc(e.seq)])
            ..limit(limit))
          .get();

  Stream<List<EventRow>> watchRecentEvents({int limit = 200}) =>
      (select(events)
            ..orderBy([(e) => OrderingTerm.desc(e.firstSeenAt)])
            ..limit(limit))
          .watch();

  Future<int> eventCount() async =>
      (await customSelect('SELECT COUNT(*) AS c FROM events').getSingle())
          .read<int>('c');

  // --------------------------------------------------------------- profiles

  Future<ProfileRow?> profile(String rootId) =>
      (select(profiles)..where((p) => p.rootId.equals(rootId)))
          .getSingleOrNull();

  Stream<ProfileRow?> watchProfile(String rootId) =>
      (select(profiles)..where((p) => p.rootId.equals(rootId)))
          .watchSingleOrNull();

  Stream<List<ProfileRow>> watchProfiles() =>
      (select(profiles)..orderBy([(p) => OrderingTerm.asc(p.handle)])).watch();

  // ------------------------------------------------------------------ posts

  /// Home feed: posts by [authors] (usually self + follows), newest first,
  /// excluding deleted posts and blocked authors.
  Stream<List<PostRow>> watchHomeFeed(Iterable<String> authors,
      {int limit = 100}) {
    final list = authors.toList();
    return (select(posts)
          ..where((p) =>
              p.rootId.isIn(list) &
              p.deleted.equals(false) &
              p.rootId.isNotInQuery(selectOnly(blocks)..addColumns([blocks.rootId])) &
              p.rootId.isNotInQuery(_hiddenByModeration()))
          ..orderBy([(p) => OrderingTerm.desc(p.ts)])
          ..limit(limit))
        .watch();
  }

  /// Everything known locally (discovery / "explore").
  Stream<List<PostRow>> watchAllPosts({int limit = 200}) => (select(posts)
        ..where((p) =>
            p.deleted.equals(false) &
            p.rootId.isNotInQuery(selectOnly(blocks)..addColumns([blocks.rootId])) &
              p.rootId.isNotInQuery(_hiddenByModeration()))
        ..orderBy([(p) => OrderingTerm.desc(p.ts)])
        ..limit(limit))
      .watch();

  Stream<List<PostRow>> watchPostsBy(String rootId) => (select(posts)
        ..where((p) =>
            p.rootId.equals(rootId) &
            p.deleted.equals(false) &
            p.rootId.isNotInQuery(_hiddenByModeration()))
        ..orderBy([(p) => OrderingTerm.desc(p.ts)]))
      .watch();

  Future<PostRow?> post(String id) =>
      (select(posts)..where((p) => p.id.equals(id))).getSingleOrNull();

  /// Roots flagged or banned by moderators (content hidden).
  BaseSelectStatement _hiddenByModeration() => selectOnly(modStatus)
    ..addColumns([modStatus.rootId])
    ..where(modStatus.state.isBiggerOrEqualValue(ModState.flagged));

  // ---------------------------------------------------- reactions, comments

  Stream<List<ReactionRow>> watchReactions(String postId) => (select(reactions)
        ..where((r) => r.target.equals(postId) & r.sticker.isNotNull()))
      .watch();

  Stream<List<CommentRow>> watchComments(String postId) => (select(comments)
        ..where((c) =>
            c.target.equals(postId) &
            c.deleted.equals(false) &
            c.rootId.isNotInQuery(_hiddenByModeration()))
        ..orderBy([(c) => OrderingTerm.asc(c.ts)]))
      .watch();

  // ---------------------------------------------------------------- follows

  Future<Set<String>> followingOf(String rootId) async {
    final rows = await (select(follows)
          ..where((f) => f.rootId.equals(rootId) & f.isOn.equals(true)))
        .get();
    return rows.map((r) => r.target).toSet();
  }

  Stream<Set<String>> watchFollowingOf(String rootId) => (select(follows)
        ..where((f) => f.rootId.equals(rootId) & f.isOn.equals(true)))
      .watch()
      .map((rows) => rows.map((r) => r.target).toSet());

  Stream<int> watchFollowerCount(String rootId) => (select(follows)
        ..where((f) => f.target.equals(rootId) & f.isOn.equals(true)))
      .watch()
      .map((l) => l.length);

  Future<Set<String>> followersOf(String rootId) async {
    final rows = await (select(follows)
          ..where((f) => f.target.equals(rootId) & f.isOn.equals(true)))
        .get();
    return rows.map((r) => r.rootId).toSet();
  }

  // ---------------------------------------------------------------- carrying

  Future<EnvelopeRow?> envelope(String id) =>
      (select(envelopes)..where((e) => e.id.equals(id))).getSingleOrNull();

  /// Envelopes still worth offering to peers (not expired, not acked).
  Future<List<EnvelopeRow>> liveEnvelopes(int now) => (select(envelopes)
        ..where((e) => e.exp.isBiggerThanValue(now) & e.acked.equals(false)))
      .get();

  /// The carry pouch: sealed mail held for strangers.
  Stream<List<EnvelopeRow>> watchCarryPouch(int now) => (select(envelopes)
        ..where((e) =>
            e.origin.equals(EnvelopeOrigin.carried) &
            e.acked.equals(false) &
            e.exp.isBiggerThanValue(now))
        ..orderBy([(e) => OrderingTerm.desc(e.receivedAt)]))
      .watch();

  /// Carried envelopes that were delivered (courier history).
  Stream<List<EnvelopeRow>> watchDeliveries({int limit = 10}) => (select(envelopes)
        ..where((e) => e.origin.equals(EnvelopeOrigin.carried) & e.acked.equals(true))
        ..orderBy([(e) => OrderingTerm.desc(e.receivedAt)])
        ..limit(limit))
      .watch();

  Future<int> carriedBytes() async => (await customSelect(
              'SELECT COALESCE(SUM(size), 0) AS s FROM envelopes '
              'WHERE origin = ${EnvelopeOrigin.carried} AND acked = 0')
          .getSingle())
      .read<int>('s');

  Future<List<AckRow>> liveAcks(int now) =>
      (select(acks)..where((a) => a.exp.isBiggerThanValue(now))).get();

  // --------------------------------------------------------------- messages

  Stream<List<MessageRow>> watchConversation(String peerRoot) =>
      (select(messages)
            ..where((m) => m.peerRoot.equals(peerRoot))
            ..orderBy([(m) => OrderingTerm.asc(m.sentAt)]))
          .watch();

  /// One row per conversation partner: their latest message.
  Stream<List<MessageRow>> watchInbox() => customSelect(
        'SELECT m.* FROM messages m '
        'JOIN (SELECT peer_root, MAX(sent_at) AS t FROM messages GROUP BY peer_root) l '
        'ON m.peer_root = l.peer_root AND m.sent_at = l.t '
        'ORDER BY m.sent_at DESC',
        readsFrom: {messages},
      ).watch().asyncMap((rows) async =>
          Future.wait(rows.map((r) => messages.mapFromRow(r))));

  // ----------------------------------------------------------------- blocks

  Future<Set<String>> blockedRoots() async =>
      (await select(blocks).get()).map((b) => b.rootId).toSet();

  Stream<Set<String>> watchBlocked() =>
      select(blocks).watch().map((r) => r.map((b) => b.rootId).toSet());

  // ------------------------------------------------------------- peers seen

  Stream<List<PeerSeenRow>> watchPeersSeen() => (select(peersSeen)
        ..orderBy([(p) => OrderingTerm.desc(p.lastSeen)]))
      .watch();

  Future<void> notePeerSeen(String feedId, String rootId, int now) =>
      customStatement(
        'INSERT INTO peers_seen (feed_id, root_id, last_seen, encounters) '
        'VALUES (?, ?, ?, 1) ON CONFLICT(feed_id) DO UPDATE SET '
        'last_seen = excluded.last_seen, encounters = encounters + 1',
        [feedId, rootId, now],
      );

  // ------------------------------------------------------------- moderation

  Future<Set<String>> moderatorRoots() async =>
      (await select(moderators).get()).map((m) => m.rootId).toSet();

  Stream<List<ModeratorRow>> watchModerators() => select(moderators).watch();

  Future<Set<String>> bannedRoots() async => (await (select(modStatus)
            ..where((s) => s.state.equals(ModState.banned)))
          .get())
      .map((s) => s.rootId)
      .toSet();

  Future<ModStatusRow?> modStatusOf(String rootId) =>
      (select(modStatus)..where((s) => s.rootId.equals(rootId)))
          .getSingleOrNull();

  Stream<ModStatusRow?> watchModStatusOf(String rootId) =>
      (select(modStatus)..where((s) => s.rootId.equals(rootId)))
          .watchSingleOrNull();

  Stream<List<ModStatusRow>> watchModStatus() => (select(modStatus)
        ..where((s) => s.state.isBiggerOrEqualValue(ModState.flagged)))
      .watch();

  // ---------------------------------------------------------- trust (local)

  Future<bool> isVerified(String rootId) async =>
      await (select(verified)..where((v) => v.rootId.equals(rootId)))
          .getSingleOrNull() !=
      null;

  Stream<Set<String>> watchVerified() =>
      select(verified).watch().map((r) => r.map((v) => v.rootId).toSet());

  Stream<Map<String, String>> watchPetnames() =>
      select(petnames).watch().map((l) => {for (final p in l) p.rootId: p.name});

  Stream<PostRow?> watchPost(String id) =>
      (select(posts)..where((p) => p.id.equals(id))).watchSingleOrNull();

  /// Full-text-ish local search over posts (what's on your phone).
  Stream<List<PostRow>> watchSearch(String q, {int limit = 100}) => (select(posts)
        ..where((p) =>
            p.deleted.equals(false) &
            p.body.lower().like('%${q.toLowerCase().replaceAll('%', '')}%') &
            p.rootId.isNotInQuery(_hiddenByModeration()))
        ..orderBy([(p) => OrderingTerm.desc(p.ts)])
        ..limit(limit))
      .watch();

  Future<Map<String, String>> petnameMap() async =>
      {for (final p in await select(petnames).get()) p.rootId: p.name};

  /// Earliest time this node saw anything from [rootId] (null if never).
  Future<int?> firstSeenOf(String rootId) async {
    final row = await customSelect(
      'SELECT MIN(first_seen_at) AS t FROM events WHERE root_id = ?',
      variables: [Variable.withString(rootId)],
      readsFrom: {events},
    ).getSingle();
    return row.read<int?>('t');
  }

  // ------------------------------------------------------------------ stats

  Future<void> bumpStat(String key, [int by = 1]) => customStatement(
        'INSERT INTO stats (key, value) VALUES (?, ?) '
        'ON CONFLICT(key) DO UPDATE SET value = value + excluded.value',
        [key, by],
      );

  Future<int> stat(String key) async =>
      (await (select(stats)..where((s) => s.key.equals(key))).getSingleOrNull())
          ?.value ??
      0;

  Stream<int> watchStat(String key) =>
      (select(stats)..where((s) => s.key.equals(key)))
          .watchSingleOrNull()
          .map((r) => r?.value ?? 0);
}
