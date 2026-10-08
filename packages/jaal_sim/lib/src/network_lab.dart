import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:jaal_core/jaal_core.dart';

import 'content.dart';

/// A virtual peer in the lab.
class LabPeer {
  LabPeer(this.name, this.node, this.transport, {this.virtual = true});

  final String name;
  final JaalNode node;
  final SimulatedTransport transport;

  /// False for the real local user's node when the lab runs inside the app.
  final bool virtual;

  String get address => transport.address;
}

/// Something worth showing in the Network Lab timeline.
class LabLogEntry {
  LabLogEntry(this.at, this.kind, this.message);
  final DateTime at;
  final String kind; // link | post | dm | react | follow | sync | info
  final String message;

  @override
  String toString() =>
      '${at.toIso8601String().substring(11, 19)} [$kind] $message';
}

/// The simulated peer network that drives decentralized development before
/// real radios exist. Used by the in-app Network Lab, the CLI and tests.
///
/// * add virtual peers, each with its own identity and in-memory database
/// * toggle/tune links (range, latency, flakiness)
/// * run "chatter" — random posts, stickers, follows and DMs
/// * observe sessions, feeds and carried mail per peer
class NetworkLab {
  NetworkLab({
    int seed = 7,
    this.retryDelay = const Duration(milliseconds: 500),
    this.genesis = const [],
    this.photos = const [],
  })  : net = SimNetwork(seed: seed),
        _rng = Random(seed),
        moderationConfig = ModerationConfig.production
            .withGenesis({for (final g in genesis) g.id});

  /// A lab with its own three genesis moderator keys, so moderation can be
  /// exercised without the production genesis keys.
  static Future<NetworkLab> create({
    int seed = 7,
    Duration retryDelay = const Duration(milliseconds: 500),
    List<Uint8List> photos = const [],
  }) async =>
      NetworkLab(
        seed: seed,
        retryDelay: retryDelay,
        genesis: [for (var i = 0; i < 3; i++) await RootIdentity.generate()],
        photos: photos,
      );

  /// Already-compressed JPEGs virtual peers use for avatars and photo posts.
  final List<Uint8List> photos;

  CompressedPhoto _photo(int i) {
    final b = photos[i % photos.length];
    return CompressedPhoto(b, 900, 900, b.length);
  }

  final SimNetwork net;
  final Duration retryDelay;

  /// Lab genesis moderator identities (spawn them with [spawnGenesisModerators]).
  final List<RootIdentity> genesis;

  /// Rules every node in the lab (including the app's own node) must share.
  final ModerationConfig moderationConfig;
  final Random _rng;
  final List<LabPeer> peers = [];
  final _log = StreamController<LabLogEntry>.broadcast();
  final List<LabLogEntry> history = [];
  Timer? _chatter;
  int _counter = 0;

  Stream<LabLogEntry> get log => _log.stream;

  LabPeer peer(String name) => peers.firstWhere((p) => p.name == name);

  void note(String kind, String message) {
    final e = LabLogEntry(DateTime.now(), kind, message);
    history.add(e);
    if (history.length > 500) history.removeAt(0);
    if (!_log.isClosed) _log.add(e);
  }

  /// A transport on the lab network for a node created elsewhere (e.g. the
  /// app's real local node). Register it afterwards with [adopt].
  SimulatedTransport transportFor(String address) => net.transport(address);

  void adopt(String name, JaalNode node, SimulatedTransport t) {
    peers.add(LabPeer(name, node, t, virtual: false));
    note('info', '$name joined the lab');
  }

  /// Creates a virtual peer with a fresh identity and profile.
  Future<LabPeer> addPeer(
      {String? name, String? handle, String? bio, RootIdentity? root}) async {
    final persona = Personas.pick(_counter++);
    final n = name ?? persona.name;
    final t = net.transport('sim-${n.toLowerCase()}-$_counter');
    final id = await LocalIdentity.create(root ?? await RootIdentity.generate(),
        now: DateTime.now().millisecondsSinceEpoch);
    final node = await JaalNode.open(
      identity: id,
      db: JaalDatabase.memory(),
      transports: [t],
      retryDelay: retryDelay,
      moderationConfig: moderationConfig,
      name: n,
    );
    await node.setProfile(
        name: n, handle: handle ?? persona.handle, bio: bio ?? persona.bio);
    if (photos.isNotEmpty && root == null) await node.setAvatar(_photo(_counter));
    await node.start();
    final p = LabPeer(n, node, t);
    peers.add(p);
    note('info', 'spawned $n (@${handle ?? persona.handle}·${fingerprintOf(node.rootId)})');
    return p;
  }

  // ------------------------------------------------------------ moderation

  /// Spawns the three lab genesis moderators (once).
  Future<List<LabPeer>> spawnGenesisModerators() async {
    final existing = peers.where((p) => genesis.any((g) => g.id == p.node.rootId));
    if (existing.isNotEmpty) return existing.toList();
    return [
      for (final (i, g) in genesis.indexed)
        await addPeer(
            name: 'Mod${i + 1}', handle: 'mod${i + 1}', bio: 'genesis moderator', root: g),
    ];
  }

  /// [mod] scans [candidate]'s moderator-consent QR in person and vouches.
  Future<void> vouch(LabPeer mod, LabPeer candidate) async {
    final code = await candidate.node.meetCode(purpose: MeetPurpose.moderator);
    await mod.node.vouchModerator(code.encode());
    note('mod', '${mod.name} vouched for ${candidate.name} as moderator');
  }

  Future<void> banVote(LabPeer mod, LabPeer target, {String reason = 'toxic'}) async {
    await mod.node.banVote(target.node.rootId, reason: reason);
    note('mod', '${mod.name} voted to remove ${target.name} ($reason)');
  }

  Future<void> revokeModerator(LabPeer mod, LabPeer target) async {
    await mod.node.revokeModerator(target.node.rootId);
    note('mod', '${mod.name} voted to revoke ${target.name}');
  }

  /// A new key copying [victim]'s name with a lookalike handle.
  Future<LabPeer> spawnImpostor(LabPeer victim) async {
    final p = await victim.node.db.profile(victim.node.rootId);
    final handle = (p?.handle ?? 'someone').replaceFirst('m', 'rn');
    final imp = await addPeer(
        name: '${victim.name}?', handle: handle == p?.handle ? '${handle}_' : handle,
        bio: p?.bio ?? '');
    await imp.node.setProfile(
        name: p?.name ?? victim.name,
        handle: handle == p?.handle ? '${handle}_' : handle,
        bio: p?.bio ?? '');
    note('info', 'impostor of ${victim.name} spawned');
    return imp;
  }

  Future<void> removePeer(LabPeer p) async {
    peers.remove(p);
    net.isolate(p.address);
    if (p.virtual) await p.node.close();
    note('info', '${p.name} left');
  }

  LinkConfig link(LabPeer a, LabPeer b) => net.link(a.address, b.address);

  void setLink(LabPeer a, LabPeer b, LinkConfig config) {
    net.setLink(a.address, b.address, config);
    note('link',
        '${a.name} ${config.up ? '⇄' : '✕'} ${b.name}${config.up && config.latency > Duration.zero ? ' (${config.latency.inMilliseconds}ms)' : ''}${config.dropChance > 0 ? ' flaky ${(config.dropChance * 100).round()}%' : ''}');
  }

  void toggleLink(LabPeer a, LabPeer b) {
    final c = link(a, b);
    setLink(a, b, c.copyWith(up: !c.up));
  }

  /// Everyone in range of everyone.
  void fullMesh() {
    for (var i = 0; i < peers.length; i++) {
      for (var j = i + 1; j < peers.length; j++) {
        setLink(peers[i], peers[j], const LinkConfig());
      }
    }
  }

  /// A line: p0 — p1 — p2 — ... (store-and-forward stress).
  void chain() {
    isolateAll();
    for (var i = 0; i + 1 < peers.length; i++) {
      setLink(peers[i], peers[i + 1], const LinkConfig());
    }
  }

  void isolateAll() {
    for (var i = 0; i < peers.length; i++) {
      for (var j = i + 1; j < peers.length; j++) {
        if (link(peers[i], peers[j]).up) {
          setLink(peers[i], peers[j], const LinkConfig(up: false));
        }
      }
    }
  }

  /// Randomly re-arranges who is near whom, like people milling at a market.
  void shuffleProximity({double density = 0.35}) {
    for (var i = 0; i < peers.length; i++) {
      for (var j = i + 1; j < peers.length; j++) {
        final up = _rng.nextDouble() < density;
        if (link(peers[i], peers[j]).up != up) {
          setLink(peers[i], peers[j], LinkConfig(up: up));
        }
      }
    }
  }

  /// Makes virtual peers follow each other at random (and the local user).
  Future<void> seedFollowGraph({double p = 0.5}) async {
    for (final a in peers.where((x) => x.virtual)) {
      for (final b in peers) {
        if (a != b && _rng.nextDouble() < p) {
          await a.node.follow(b.node.rootId);
          note('follow', '${a.name} → ${b.name}');
        }
      }
    }
  }

  /// One random social action by a random virtual peer.
  Future<void> tick() async {
    final virtuals = peers.where((p) => p.virtual).toList();
    if (virtuals.isEmpty) return;
    final p = virtuals[_rng.nextInt(virtuals.length)];
    final roll = _rng.nextDouble();
    try {
      if (roll < 0.45) {
        final text = Captions.random(_rng);
        if (photos.isNotEmpty && _rng.nextDouble() < 0.4) {
          await p.node.postPhotos(text, [_photo(_rng.nextInt(photos.length))]);
          note('post', '${p.name} (photo): $text');
        } else {
          await p.node.post(text);
          note('post', '${p.name}: $text');
        }
      } else if (roll < 0.75) {
        final posts = await p.node.db.select(p.node.db.posts).get();
        final others = posts.where((x) => x.rootId != p.node.rootId && !x.deleted).toList();
        if (others.isEmpty) return;
        final target = others[_rng.nextInt(others.length)];
        final sticker = Bodies.stickers.elementAt(_rng.nextInt(Bodies.stickers.length));
        await p.node.react(target.id,
            sticker: sticker,
            x: 100 + _rng.nextInt(800),
            y: 100 + _rng.nextInt(800),
            rot: _rng.nextInt(31) - 15);
        note('react', '${p.name} slapped a "$sticker" sticker');
      } else {
        final profiles = await p.node.db.select(p.node.db.profiles).get();
        final others = profiles.where((x) => x.rootId != p.node.rootId).toList();
        if (others.isEmpty) return;
        final to = others[_rng.nextInt(others.length)];
        final text = Captions.dm(_rng);
        await p.node.sendDm(to.rootId, text);
        note('dm', '${p.name} → @${to.handle}: sealed envelope');
      }
    } on Object catch (e) {
      note('info', '${p.name} action failed: $e');
    }
  }

  void startChatter({Duration every = const Duration(seconds: 3)}) {
    _chatter?.cancel();
    _chatter = Timer.periodic(every, (_) => tick());
    note('info', 'chatter on (every ${every.inMilliseconds}ms)');
  }

  void stopChatter() {
    _chatter?.cancel();
    _chatter = null;
    note('info', 'chatter off');
  }

  bool get chattering => _chatter != null;

  Future<PeerSnapshot> snapshot(LabPeer p) async {
    final db = p.node.db;
    return PeerSnapshot(
      peer: p,
      events: await db.eventCount(),
      feeds: (await db.allFeeds()).length,
      posts: (await db.select(db.posts).get()).length,
      carrying: (await db.select(db.envelopes).get())
          .where((e) => e.origin == EnvelopeOrigin.carried && !e.acked)
          .length,
      delivered: await db.stat(StatKey.courierDelivered),
      messages: (await db.select(db.messages).get()).length,
      sessions: p.node.engine.sessions.length,
      moderator: p.node.isModerator,
      banned: p.node.isBanned,
      moderators: p.node.moderation.moderators.length,
    );
  }

  Future<void> dispose() async {
    _chatter?.cancel();
    for (final p in peers.where((p) => p.virtual).toList()) {
      await p.node.close();
    }
    peers.clear();
    await net.dispose();
    await _log.close();
  }
}

class PeerSnapshot {
  PeerSnapshot({
    required this.peer,
    required this.events,
    required this.feeds,
    required this.posts,
    required this.carrying,
    required this.delivered,
    required this.messages,
    required this.sessions,
    required this.moderator,
    required this.banned,
    required this.moderators,
  });

  final LabPeer peer;
  final int events, feeds, posts, carrying, delivered, messages, sessions;

  /// As the peer itself sees it.
  final bool moderator, banned;
  final int moderators;
}
