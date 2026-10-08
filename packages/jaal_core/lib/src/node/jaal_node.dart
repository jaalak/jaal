import 'dart:async';

import 'package:logging/logging.dart';

import '../crypto/crypto.dart';
import '../db/database.dart';
import '../events/event_store.dart';
import '../identity/identity.dart';
import '../identity/lookalike.dart';
import '../identity/meet_code.dart';
import '../media/chunking.dart';
import '../media/media_store.dart';
import '../media/photo_compressor.dart';
import '../messaging/carrier.dart';
import '../moderation/moderation_config.dart';
import '../moderation/moderation_engine.dart';
import '../protocol/bodies.dart';
import '../protocol/event.dart';
import '../sync/replication_policy.dart';
import '../sync/sync_engine.dart';
import '../sync/sync_session.dart';
import '../transport/peer_transport.dart';
import '../util/bytes.dart';
import '../util/canonical_json.dart';
import '../util/clock.dart';

/// The application-facing API of one Jaal peer. UI, simulator and tests all
/// talk to this; nothing above it knows about transports or wire formats.
class JaalNode {
  JaalNode._({
    required this.me,
    required this.db,
    required this.store,
    required this.carrier,
    required this.engine,
    required this.moderation,
    required this.media,
    required this.clock,
    required this.log,
  });

  final LocalIdentity me;
  final JaalDatabase db;
  final EventStore store;
  final Carrier carrier;
  final SyncEngine engine;
  final ModerationEngine moderation;
  final MediaStore media;
  final Clock clock;
  final Logger log;
  Timer? _sweeper;

  RootId get rootId => me.rootId;
  FeedId get feedId => me.feedId;

  static Future<JaalNode> open({
    required LocalIdentity identity,
    required JaalDatabase db,
    List<PeerTransport> transports = const [],
    Clock clock = const SystemClock(),
    ReplicationPolicy policy = const ReplicationPolicy(),
    int maxCarryBytes = 20 * 1024 * 1024,
    Duration retryDelay = const Duration(seconds: 2),
    ModerationConfig moderationConfig = ModerationConfig.production,
    String? name,
  }) async {
    final log = Logger('jaal.node.${name ?? identity.feedId.substring(0, 6)}');
    final moderation =
        ModerationEngine(db, moderationConfig, me: identity.rootId, log: log);
    final store = EventStore(
        db: db, me: identity, clock: clock, moderation: moderation, log: log);
    final media = MediaStore(db, clock);
    final carrier = Carrier(
        db: db, me: identity, clock: clock, maxCarryBytes: maxCarryBytes, log: log);
    late final SyncEngine engine;
    final ctx = SyncContext(
      me: identity,
      db: db,
      store: store,
      carrier: carrier,
      policy: policy,
      clock: clock,
      directPeers: () => engine.connectedRoots,
      media: media,
    );
    engine = SyncEngine(ctx, transports, retryDelay: retryDelay, log: log);
    final node = JaalNode._(
      me: identity,
      db: db,
      store: store,
      carrier: carrier,
      engine: engine,
      moderation: moderation,
      media: media,
      clock: clock,
      log: log,
    );
    await moderation.init();
    await store.init();
    return node;
  }

  /// Starts discovery and syncing on all transports.
  Future<void> start() async {
    await engine.start();
    _sweeper = Timer.periodic(const Duration(minutes: 5), (_) => carrier.sweep());
  }

  Future<void> close() async {
    _sweeper?.cancel();
    await engine.stop();
    await store.dispose();
    await carrier.dispose();
    await media.dispose();
    await db.close();
  }

  // ------------------------------------------------------------- profile

  Future<SignedEvent> setProfile({
    required String name,
    required String handle,
    String bio = '',
    Map<String, Object?>? avatar,
  }) =>
      store.append(
        EventType.profile,
        Bodies.profile(
            name: name, handle: handle, bio: bio, dmKey: me.dmPublicKey, avatar: avatar),
      );

  // --------------------------------------------------------------- posts

  Future<SignedEvent> post(String text,
          {List<Map<String, Object?>> media = const []}) =>
      store.append(EventType.post, Bodies.post(text: text, media: media));

  /// Posts photos. [photos] should already be compressed (see
  /// [PhotoCompressor], which the app runs in a background isolate).
  Future<SignedEvent> postPhotos(String text, List<CompressedPhoto> photos) async {
    final manifests = <Map<String, Object?>>[
      for (final p in photos)
        (await media.putLocal(p.bytes,
                mime: p.mime, owner: rootId, width: p.width, height: p.height))
            .toJson(),
    ];
    return post(text, media: manifests);
  }

  /// Sets a profile photo (keeps name/handle/bio).
  Future<SignedEvent> setAvatar(CompressedPhoto photo) async {
    final m = await media.putLocal(photo.bytes,
        mime: photo.mime, owner: rootId, width: photo.width, height: photo.height);
    final p = await db.profile(rootId);
    return setProfile(
        name: p?.name ?? 'anon',
        handle: p?.handle ?? 'anon',
        bio: p?.bio ?? '',
        avatar: m.toJson());
  }

  /// Media manifests of a post row.
  static List<MediaManifest> mediaOf(PostRow p) {
    final raw = CanonicalJson.decode(p.media);
    if (raw is! List) return const [];
    return [
      for (final m in raw)
        if (m is Map) ?_tryManifest(m.cast<String, Object?>()),
    ];
  }

  static MediaManifest? _tryManifest(Map<String, Object?> j) {
    try {
      return MediaManifest.fromJson(j);
    } on Object {
      return null;
    }
  }

  Future<SignedEvent> editPost(String postId, String text) =>
      store.append(EventType.postEdit, Bodies.postEdit(target: postId, text: text));

  /// Deletes a post or comment we authored (tombstone; peers erase content).
  Future<SignedEvent> delete(String targetId) =>
      store.append(EventType.delete, Bodies.delete(target: targetId));

  /// Slaps a sticker on a post; `sticker: null` peels it off.
  Future<SignedEvent> react(String postId,
          {required String? sticker, int x = 500, int y = 500, int rot = 0}) =>
      store.append(
        EventType.reaction,
        Bodies.reaction(target: postId, sticker: sticker, x: x, y: y, rot: rot),
      );

  Future<SignedEvent> comment(String postId, String text, {String? parent}) =>
      store.append(EventType.comment,
          Bodies.comment(target: postId, text: text, parent: parent));

  Future<SignedEvent> follow(RootId target) =>
      store.append(EventType.follow, Bodies.follow(target: target, on: true));

  Future<SignedEvent> unfollow(RootId target) =>
      store.append(EventType.follow, Bodies.follow(target: target, on: false));

  // ------------------------------------------------------------ messages

  Future<MessageRow> sendDm(RootId to, String text) => carrier.sendDm(to, text);

  // ---------------------------------------------------------- moderation

  /// Blocks [root] locally and syncs the block list privately to our own
  /// other devices (encrypted to self, opaque to everyone else).
  Future<void> block(RootId root) async {
    final roots = await db.blockedRoots()
      ..add(root);
    await _publishBlocks(roots);
  }

  Future<void> unblock(RootId root) async {
    final roots = await db.blockedRoots()
      ..remove(root);
    await _publishBlocks(roots);
  }

  Future<void> _publishBlocks(Set<RootId> roots) async {
    final nonce = randomBytes(JaalCrypto.nonceLength);
    final ct = await JaalCrypto.seal(
      key: me.root.selfKey,
      nonce: nonce,
      plaintext: CanonicalJson.encodeBytes(
          {'kind': 'blocks', 'roots': roots.toList()..sort()}),
      aad: me.feedId.codeUnits,
    );
    await store.append(
        EventType.selfPrivate, Bodies.selfPrivate(nonce: b64(nonce), ct: b64(ct)));
    // Drop open sessions with newly blocked peers.
    for (final s in engine.sessions.toList()) {
      if (roots.contains(s.peerRoot)) await s.close();
    }
  }

  // ------------------------------------------------- meet / verify (QR)

  /// The signed QR payload for meeting someone (or, with
  /// [MeetPurpose.moderator], consenting to become a moderator).
  Future<MeetCode> meetCode({String purpose = MeetPurpose.meet}) async {
    final p = await db.profile(rootId);
    return MeetCode.create(me,
        handle: p?.handle ?? 'anon', now: clock.nowMs(), purpose: purpose);
  }

  /// Scans someone's code in person: checks the signature and freshness,
  /// marks them verified, and follows them.
  Future<MeetCode> verifyInPerson(String scanned, {bool follow = true}) async {
    final code = await _scan(scanned, MeetPurpose.meet);
    await db.into(db.verified).insertOnConflictUpdate(
        VerifiedCompanion.insert(rootId: code.root, at: clock.nowMs()));
    if (follow && !(await db.followingOf(rootId)).contains(code.root)) {
      await this.follow(code.root);
    }
    return code;
  }

  Future<MeetCode> _scan(String scanned, String purpose) async {
    final code = MeetCode.decode(scanned);
    if (code.purpose != purpose) {
      throw FormatException('expected a "$purpose" code, got "${code.purpose}"');
    }
    if (!await code.verify()) throw const FormatException('code signature invalid');
    final age = clock.nowMs() - code.ts;
    if (age > moderation.config.liveCodeMaxAge.inMilliseconds || age < -60000) {
      throw const FormatException('code expired — ask them to refresh it');
    }
    if (code.root == rootId) {
      throw const FormatException('that is your own code');
    }
    return code;
  }

  /// A private nickname for someone (shown instead of their handle to you).
  Future<void> setPetname(RootId root, String? name) async {
    if (name == null || name.trim().isEmpty) {
      await (db.delete(db.petnames)..where((p) => p.rootId.equals(root))).go();
    } else {
      await db.into(db.petnames).insertOnConflictUpdate(
          PetnamesCompanion.insert(rootId: root, name: name.trim()));
    }
  }

  /// Impersonation warnings for [root] (empty if nothing looks off).
  Future<List<LookalikeWarning>> lookalikesOf(RootId root) =>
      Lookalikes.check(db, rootId, root);

  // ------------------------------------------------------------ moderation

  bool get isModerator => moderation.isModerator(rootId);
  bool get isBanned => moderation.isBanned(rootId);

  void _requireModerator() {
    if (!isModerator) throw StateError('only moderators can do this');
  }

  /// Vouch for a moderator candidate whose `purpose: mod` QR you just
  /// scanned in person. They become a moderator at 3 vouches.
  Future<SignedEvent> vouchModerator(String scannedConsent) async {
    _requireModerator();
    final code = await _scan(scannedConsent, MeetPurpose.moderator);
    return store.append(EventType.modVouch,
        Bodies.modVouch(candidate: code.root, consent: code.toJson()));
  }

  /// Vote to strip [target]'s moderator role. Actions they publish after
  /// what you've seen of their feeds stop counting once revoked.
  Future<SignedEvent> revokeModerator(RootId target) async {
    _requireModerator();
    final feeds = await (db.select(db.feeds)
          ..where((f) => f.rootId.equals(target)))
        .get();
    return store.append(EventType.modRevoke, Bodies.modRevoke(
      target: target,
      cutoff: {for (final f in feeds) f.feedId: f.latestSeq},
    ));
  }

  /// Vote to remove [target]. First vote hides them; a second moderator's
  /// vote bans them permanently.
  Future<SignedEvent> banVote(RootId target, {String reason = ''}) async {
    _requireModerator();
    return store.append(
        EventType.modBan, Bodies.modBan(target: target, on: true, reason: reason));
  }

  Future<SignedEvent> retractBanVote(RootId target) async {
    _requireModerator();
    return store.append(
        EventType.modBan, Bodies.modBan(target: target, on: false));
  }

  // --------------------------------------------------------- read models

  /// Home feed: self + follows.
  Stream<List<PostRow>> watchHomeFeed() => db
      .watchFollowingOf(rootId)
      .asyncExpand((following) => db.watchHomeFeed({rootId, ...following}));

  Future<String> displayHandle(RootId root) async {
    final p = await db.profile(root);
    return '@${p?.handle ?? 'anon'}·${fingerprintOf(root)}';
  }
}
