import 'package:drift/drift.dart';

abstract final class FeedPurpose {
  static const normal = 0;

  /// Holds only `mod.*` events, so every phone can replicate moderators'
  /// decisions without their personal posts.
  static const moderation = 1;
}

// ---------------------------------------------------------------------------
// Raw replicated log. These two tables are the source of truth; everything
// below the "projections" line can be rebuilt from them.
// ---------------------------------------------------------------------------

/// One row per device feed we hold (including our own).
@DataClassName('FeedRow')
class Feeds extends Table {
  TextColumn get feedId => text()();
  TextColumn get rootId => text()();
  IntColumn get latestSeq => integer().withDefault(const Constant(0))();
  TextColumn get latestId => text().nullable()();
  IntColumn get latestLamport => integer().withDefault(const Constant(0))();

  /// Set by `device.revoke`: events with seq > this are ignored.
  IntColumn get revokedAfterSeq => integer().nullable()();

  /// [FeedPurpose]: 0 = normal device feed, 1 = moderation feed (v4).
  IntColumn get purpose => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {feedId};
}

@DataClassName('EventRow')
class Events extends Table {
  TextColumn get id => text()();
  TextColumn get feedId => text()();
  IntColumn get seq => integer()();
  TextColumn get rootId => text()();
  IntColumn get lamport => integer()();
  IntColumn get ts => integer()();
  TextColumn get type => text()();

  /// Canonical JSON of the signed event.
  TextColumn get raw => text()();

  /// Canonical JSON of the body; null once erased by a tombstone.
  TextColumn get body => text().nullable()();

  /// Unsigned hop counter (0 = authored here). Cosmetic: postmarks only.
  IntColumn get hops => integer().withDefault(const Constant(0))();
  IntColumn get firstSeenAt => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {feedId, seq},
      ];
}

// ---------------------------------------------------------------------------
// Projections (materialized views maintained by the Projector).
// ---------------------------------------------------------------------------

@DataClassName('ProfileRow')
class Profiles extends Table {
  TextColumn get rootId => text()();
  TextColumn get name => text()();
  TextColumn get handle => text()();
  TextColumn get bio => text().withDefault(const Constant(''))();
  TextColumn get dmKey => text()();
  TextColumn get avatar => text().nullable()();
  IntColumn get lamport => integer()();
  TextColumn get eventId => text()();

  /// Lookalike skeletons of handle and name (v4, indexed).
  TextColumn get handleSkel => text().withDefault(const Constant(''))();
  TextColumn get nameSkel => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {rootId};
}

@DataClassName('PostRow')
class Posts extends Table {
  TextColumn get id => text()();
  TextColumn get rootId => text()();
  TextColumn get feedId => text()();
  TextColumn get body => text()();
  TextColumn get media => text().withDefault(const Constant('[]'))();
  IntColumn get ts => integer()();
  IntColumn get lamport => integer()();

  /// Lamport of the winning `post.edit`, 0 if never edited.
  IntColumn get editLamport => integer().withDefault(const Constant(0))();
  TextColumn get editId => text().nullable()();
  IntColumn get hops => integer().withDefault(const Constant(0))();
  IntColumn get firstSeenAt => integer()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Sticker reactions. One per (author, post); last-writer-wins.
@DataClassName('ReactionRow')
class Reactions extends Table {
  TextColumn get rootId => text()();
  TextColumn get target => text()();
  TextColumn get sticker => text().nullable()();
  IntColumn get x => integer()();
  IntColumn get y => integer()();
  IntColumn get rot => integer()();
  IntColumn get lamport => integer()();
  TextColumn get eventId => text()();

  @override
  Set<Column> get primaryKey => {rootId, target};
}

@DataClassName('CommentRow')
class Comments extends Table {
  TextColumn get id => text()();
  TextColumn get target => text()();
  TextColumn get rootId => text()();
  TextColumn get body => text()();
  TextColumn get parent => text().nullable()();
  IntColumn get ts => integer()();
  IntColumn get lamport => integer()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Follow edges. One per (follower, target); last-writer-wins.
@DataClassName('FollowRow')
class Follows extends Table {
  TextColumn get rootId => text()();
  TextColumn get target => text()();
  BoolColumn get isOn => boolean()();
  IntColumn get lamport => integer()();
  TextColumn get eventId => text()();

  @override
  Set<Column> get primaryKey => {rootId, target};
}

/// Deletes are kept even when the target hasn't arrived yet, so a late
/// target is born already deleted.
@DataClassName('TombstoneRow')
class Tombstones extends Table {
  TextColumn get target => text()();
  TextColumn get byRoot => text()();
  IntColumn get lamport => integer()();
  TextColumn get eventId => text()();

  @override
  Set<Column> get primaryKey => {target};
}

// ---------------------------------------------------------------------------
// Store-and-forward carry inbox.
// ---------------------------------------------------------------------------

abstract final class EnvelopeOrigin {
  /// Carried on behalf of someone else (the "carry pouch").
  static const carried = 0;

  /// Sealed by this node.
  static const sent = 1;

  /// Addressed to this node and successfully opened.
  static const received = 2;
}

@DataClassName('EnvelopeRow')
class Envelopes extends Table {
  TextColumn get id => text()();
  TextColumn get raw => text()();
  TextColumn get hint => text()();
  TextColumn get ackHash => text()();
  IntColumn get exp => integer()();
  IntColumn get size => integer()();
  IntColumn get receivedAt => integer()();
  IntColumn get hops => integer().withDefault(const Constant(0))();
  IntColumn get origin => integer()();
  BoolColumn get acked => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Revealed ack secrets (delivery receipts) we know about and forward.
@DataClassName('AckRow')
class Acks extends Table {
  TextColumn get ackHash => text()();
  TextColumn get secret => text()();
  IntColumn get exp => integer()();

  @override
  Set<Column> get primaryKey => {ackHash};
}

// ---------------------------------------------------------------------------
// Local-only state (never replicated as-is).
// ---------------------------------------------------------------------------

@DataClassName('MessageRow')
class Messages extends Table {
  /// Envelope id.
  TextColumn get id => text()();
  TextColumn get peerRoot => text()();
  BoolColumn get outgoing => boolean()();
  TextColumn get body => text()();
  IntColumn get sentAt => integer()();
  IntColumn get receivedAt => integer().nullable()();
  TextColumn get ackHash => text()();
  BoolColumn get delivered => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('BlockRow')
class Blocks extends Table {
  TextColumn get rootId => text()();
  IntColumn get since => integer()();

  @override
  Set<Column> get primaryKey => {rootId};
}

/// Peers met directly over a transport (feeds the "nearby radar wall").
@DataClassName('PeerSeenRow')
class PeersSeen extends Table {
  TextColumn get feedId => text()();
  TextColumn get rootId => text()();
  IntColumn get lastSeen => integer()();
  IntColumn get encounters => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {feedId};
}

/// Small counters, e.g. courier clout.
@DataClassName('StatRow')
class Stats extends Table {
  TextColumn get key => text()();
  IntColumn get value => integer()();

  @override
  Set<Column> get primaryKey => {key};
}

// ---------------------------------------------------------------------------
// Moderation (schema v2). `mod_actions` mirrors every mod.* event we hold;
// `moderators` and `mod_status` are derived by the ModerationEngine.
// ---------------------------------------------------------------------------

@DataClassName('ModActionRow')
class ModActions extends Table {
  TextColumn get eventId => text()();
  TextColumn get author => text()();
  TextColumn get feedId => text()();
  IntColumn get seq => integer()();
  TextColumn get type => text()();
  TextColumn get target => text()();

  /// For mod.ban: vote on (true) or retracted (false). Unused otherwise.
  BoolColumn get isOn => boolean().withDefault(const Constant(true))();
  IntColumn get lamport => integer()();
  IntColumn get ts => integer()();

  /// Canonical JSON of the body (consent proof, revoke cutoffs, reason).
  TextColumn get body => text()();

  /// Structural/cryptographic validity checked at ingest (e.g. consent sig).
  BoolColumn get valid => boolean()();

  @override
  Set<Column> get primaryKey => {eventId};
}

abstract final class ModRole {
  static const genesis = 0;
  static const vouched = 1;
}

@DataClassName('ModeratorRow')
class Moderators extends Table {
  TextColumn get rootId => text()();
  IntColumn get role => integer()();

  /// Roots whose vouches made this moderator (comma-separated, display only).
  TextColumn get vouchedBy => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {rootId};
}

abstract final class ModState {
  static const none = 0;

  /// One moderator voted: content hidden, still replicated (reversible).
  static const flagged = 1;

  /// Quorum reached: not replicated, not shown, refused at ingest, purged.
  static const banned = 2;
}

@DataClassName('ModStatusRow')
class ModStatus extends Table {
  TextColumn get rootId => text()();
  IntColumn get state => integer()();
  IntColumn get votes => integer()();
  TextColumn get reason => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {rootId};
}

/// Revoked moderators and the cutoff after which their actions are void.
@DataClassName('ModRevocationRow')
class ModRevocations extends Table {
  TextColumn get rootId => text()();

  /// Canonical JSON map {feedId: lastValidSeq}.
  TextColumn get cutoff => text()();

  @override
  Set<Column> get primaryKey => {rootId};
}

// ---------------------------------------------------------------------------
// Anti-impersonation (schema v2), local only.
// ---------------------------------------------------------------------------

/// People whose key you confirmed face to face by scanning their QR.
@DataClassName('VerifiedRow')
class Verified extends Table {
  TextColumn get rootId => text()();
  IntColumn get at => integer()();

  @override
  Set<Column> get primaryKey => {rootId};
}

/// Private nicknames you give people; never replicated.
@DataClassName('PetnameRow')
class Petnames extends Table {
  TextColumn get rootId => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {rootId};
}

// ---------------------------------------------------------------------------
// Media (schema v3): content-addressed blobs split into verified chunks.
// ---------------------------------------------------------------------------

@DataClassName('MediaBlobRow')
class MediaBlobs extends Table {
  /// base64url SHA-256 of the whole file.
  TextColumn get hash => text()();

  /// Canonical JSON of the MediaManifest.
  TextColumn get manifest => text()();
  TextColumn get mime => text()();
  IntColumn get size => integer()();
  IntColumn get chunkCount => integer()();
  IntColumn get chunksHeld => integer().withDefault(const Constant(0))();
  BoolColumn get complete => boolean().withDefault(const Constant(false))();

  /// Author of the first post/profile that referenced it (for purges).
  TextColumn get rootId => text()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {hash};
}

@DataClassName('MediaChunkRow')
class MediaChunks extends Table {
  TextColumn get hash => text()();
  IntColumn get idx => integer()();
  BlobColumn get data => blob()();

  @override
  Set<Column> get primaryKey => {hash, idx};
}
