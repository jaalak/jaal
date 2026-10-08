import 'dart:typed_data';

import '../crypto/crypto.dart';
import '../identity/identity.dart';
import '../util/bytes.dart';
import '../util/canonical_json.dart';

/// Protocol version carried in every event (`v`).
const int protocolVersion = 1;

/// Event types defined by protocol v1 (protocol/SPEC.md §4).
abstract final class EventType {
  static const deviceCert = 'device.cert';
  static const deviceRevoke = 'device.revoke';
  static const profile = 'profile';
  static const post = 'post';
  static const postEdit = 'post.edit';
  static const delete = 'delete';
  static const reaction = 'reaction';
  static const comment = 'comment';
  static const follow = 'follow';
  static const selfPrivate = 'self.private';

  /// Moderation (protocol/SPEC.md §10). Inert unless authored by a moderator.
  static const modVouch = 'mod.vouch';
  static const modRevoke = 'mod.revoke';
  static const modBan = 'mod.ban';

  static bool isModeration(String type) => type.startsWith('mod.');

  static const all = {
    deviceCert,
    deviceRevoke,
    profile,
    post,
    postEdit,
    delete,
    reaction,
    comment,
    follow,
    selfPrivate,
    modVouch,
    modRevoke,
    modBan,
  };
}

/// A signed entry in a device feed.
///
/// The signature covers the *body hash* (`bh`), not the body, so a body can
/// be erased after a `delete` while the hash chain stays verifiable and the
/// event can still be forwarded (protocol/SPEC.md §4.3).
class SignedEvent {
  SignedEvent._({
    required this.feed,
    required this.seq,
    required this.prev,
    required this.lamport,
    required this.ts,
    required this.type,
    required this.bodyHash,
    required this.sig,
    this.v = protocolVersion,
  }) : id = computeId({
          'v': v,
          'feed': feed,
          'seq': seq,
          'prev': prev,
          'lamport': lamport,
          'ts': ts,
          'type': type,
          'bh': bodyHash,
        });

  final int v;
  final FeedId feed;
  final int seq;
  final String? prev;
  final int lamport;
  final int ts;
  final String type;
  final String bodyHash;
  final String sig;

  /// base64url(SHA-256(canonical(unsigned event))).
  final String id;

  Map<String, Object?> unsignedJson() => {
        'v': v,
        'feed': feed,
        'seq': seq,
        'prev': prev,
        'lamport': lamport,
        'ts': ts,
        'type': type,
        'bh': bodyHash,
      };

  Map<String, Object?> toJson() => {...unsignedJson(), 'sig': sig};

  String toCanonical() => CanonicalJson.encode(toJson());

  static String computeId(Map<String, Object?> unsigned) =>
      b64(JaalCrypto.sha256(CanonicalJson.encodeBytes(unsigned)));

  static String hashBody(Map<String, Object?> body) =>
      b64(JaalCrypto.sha256(CanonicalJson.encodeBytes(body)));

  static Uint8List _signedBytes(Map<String, Object?> unsigned) => concatBytes([
        SigDomain.event.codeUnits,
        CanonicalJson.encodeBytes(unsigned),
      ]);

  /// Parses and structurally checks an event. Throws [FormatException].
  static SignedEvent fromJson(Map<String, Object?> j) {
    T req<T>(String k) {
      final v = j[k];
      if (v is! T) throw FormatException('event.$k missing or wrong type');
      return v;
    }

    const allowed = {'v', 'feed', 'seq', 'prev', 'lamport', 'ts', 'type', 'bh', 'sig'};
    final extra = j.keys.where((k) => !allowed.contains(k));
    if (extra.isNotEmpty) throw FormatException('unknown event fields $extra');

    final prev = j['prev'];
    if (prev != null && prev is! String) {
      throw const FormatException('event.prev wrong type');
    }
    final e = SignedEvent._(
      v: req<int>('v'),
      feed: req<String>('feed'),
      seq: req<int>('seq'),
      prev: prev as String?,
      lamport: req<int>('lamport'),
      ts: req<int>('ts'),
      type: req<String>('type'),
      bodyHash: req<String>('bh'),
      sig: req<String>('sig'),
    );
    if (e.v != protocolVersion) {
      throw FormatException('unsupported protocol version ${e.v}');
    }
    if (e.seq < 1) throw const FormatException('event.seq must be >= 1');
    if ((e.seq == 1) != (e.prev == null)) {
      throw const FormatException('event.prev must be null iff seq == 1');
    }
    if (e.lamport < 1) throw const FormatException('event.lamport must be >= 1');
    return e;
  }

  static SignedEvent parse(String canonical) =>
      fromJson(CanonicalJson.decode(canonical)! as Map<String, Object?>);

  Future<bool> verifySignature() => JaalCrypto.verify(
        message: _signedBytes(unsignedJson()),
        signature: unb64(sig),
        publicKey: unb64(feed),
      );

  /// Creates and signs a new event. Callers (the [FeedWriter]) are
  /// responsible for supplying the correct seq/prev/lamport.
  static Future<SignedEvent> create({
    required SigningKey device,
    required int seq,
    required String? prev,
    required int lamport,
    required int ts,
    required String type,
    required Map<String, Object?> body,
  }) async {
    final unsigned = {
      'v': protocolVersion,
      'feed': b64(device.publicKey),
      'seq': seq,
      'prev': prev,
      'lamport': lamport,
      'ts': ts,
      'type': type,
      'bh': hashBody(body),
    };
    final sig = await device.sign(_signedBytes(unsigned));
    return SignedEvent._(
      feed: unsigned['feed']! as String,
      seq: seq,
      prev: prev,
      lamport: lamport,
      ts: ts,
      type: type,
      bodyHash: unsigned['bh']! as String,
      sig: b64(sig),
    );
  }

  @override
  String toString() => 'Event($type ${feed.substring(0, 6)}#$seq)';
}

/// An event plus its (possibly erased) body and the unsigned hop counter, as
/// carried in sync `events` messages: `{"e": event, "b": body|null, "h": hops}`.
class FeedItem {
  const FeedItem(this.event, this.body, this.hops);

  final SignedEvent event;
  final Map<String, Object?>? body;
  final int hops;

  Map<String, Object?> toJson() =>
      {'e': event.toJson(), 'b': body, 'h': hops};

  static FeedItem fromJson(Map<String, Object?> j) {
    final b = j['b'];
    final h = j['h'];
    return FeedItem(
      SignedEvent.fromJson(j['e']! as Map<String, Object?>),
      b == null ? null : (b as Map).cast<String, Object?>(),
      h is int && h >= 0 ? h : 0,
    );
  }
}
