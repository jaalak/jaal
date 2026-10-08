import 'event.dart';

/// Builders and validators for event bodies (protocol/SPEC.md §4.4).
///
/// Validation is strict on known types and lenient on unknown ones: an event
/// of a type this client doesn't understand is still stored and forwarded so
/// newer clients on the mesh are not cut off by older carriers.
abstract final class Bodies {
  static const maxPostText = 2200;
  static const maxCommentText = 1000;
  static const maxName = 50;
  static const maxBio = 300;
  static final handlePattern = RegExp(r'^[a-z0-9_.]{2,24}$');

  /// Built-in sticker set. Unknown sticker ids render as a generic stamp.
  static const stickers = {
    'heart', 'fire', 'lol', 'real', 'slay', 'mid', 'cry', 'peak', 'w', 'skull',
  };

  static Map<String, Object?> profile({
    required String name,
    required String handle,
    String bio = '',
    required String dmKey,
    Map<String, Object?>? avatar,
  }) =>
      {'name': name, 'handle': handle, 'bio': bio, 'dm': dmKey, 'avatar': avatar};

  static Map<String, Object?> post({
    required String text,
    List<Map<String, Object?>> media = const [],
  }) =>
      {'text': text, 'media': media};

  static Map<String, Object?> postEdit({
    required String target,
    required String text,
  }) =>
      {'target': target, 'text': text};

  static Map<String, Object?> delete({required String target}) =>
      {'target': target};

  /// [sticker] null removes the reaction. Position is in per-mille of the
  /// post's media box (0..1000); rotation in whole degrees (-45..45).
  static Map<String, Object?> reaction({
    required String target,
    required String? sticker,
    int x = 500,
    int y = 500,
    int rot = 0,
  }) =>
      {'target': target, 'sticker': sticker, 'x': x, 'y': y, 'rot': rot};

  static Map<String, Object?> comment({
    required String target,
    required String text,
    String? parent,
  }) =>
      {'target': target, 'text': text, 'parent': parent};

  static Map<String, Object?> follow({
    required String target,
    required bool on,
  }) =>
      {'target': target, 'on': on};

  static Map<String, Object?> selfPrivate({
    required String nonce,
    required String ct,
  }) =>
      {'nonce': nonce, 'ct': ct};

  static Map<String, Object?> deviceRevoke({
    required String device,
    required int afterSeq,
    required String rootSig,
  }) =>
      {'device': device, 'afterSeq': afterSeq, 'rootSig': rootSig};

  static const maxModReason = 280;

  /// A moderator vouches for [candidate], who consented by showing a
  /// `purpose: mod` QR code (the signed [consent]).
  static Map<String, Object?> modVouch({
    required String candidate,
    required Map<String, Object?> consent,
  }) =>
      {'candidate': candidate, 'consent': consent};

  /// Votes to strip [target]'s moderator role. [cutoff] maps each of the
  /// target's feeds to the last seq the voter had seen: target actions after
  /// it don't count once the revocation takes effect.
  static Map<String, Object?> modRevoke({
    required String target,
    required Map<String, int> cutoff,
  }) =>
      {'target': target, 'cutoff': cutoff};

  /// A moderator's ban vote on [target] (`on: false` retracts it).
  static Map<String, Object?> modBan({
    required String target,
    required bool on,
    String reason = '',
  }) =>
      {'target': target, 'on': on, 'reason': reason};

  /// Returns an error message, or null if [body] is valid for [type].
  static String? validate(String type, Map<String, Object?> body) {
    String? str(String k, {int? max, bool optional = false}) {
      final v = body[k];
      if (v == null && optional) return null;
      if (v is! String) return '$k must be a string';
      if (max != null && v.length > max) return '$k longer than $max';
      return null;
    }

    String? integer(String k, int min, int max) {
      final v = body[k];
      if (v is! int || v < min || v > max) return '$k must be int in [$min,$max]';
      return null;
    }

    String? first(List<String? Function()> checks) {
      for (final c in checks) {
        final r = c();
        if (r != null) return r;
      }
      return null;
    }

    switch (type) {
      case EventType.deviceCert:
        return first([
          () => str('root'),
          () => str('device'),
          () => body['created'] is int ? null : 'created must be int',
          () => str('sig'),
        ]);
      case EventType.deviceRevoke:
        return first([
          () => str('device'),
          () => body['afterSeq'] is int ? null : 'afterSeq must be int',
          () => str('rootSig'),
        ]);
      case EventType.profile:
        return first([
          () => str('name', max: maxName),
          () => str('bio', max: maxBio),
          () => str('dm'),
          () {
            final h = body['handle'];
            return h is String && handlePattern.hasMatch(h)
                ? null
                : 'handle must match ${handlePattern.pattern}';
          },
          () => body['avatar'] == null || body['avatar'] is Map
              ? null
              : 'avatar must be a media ref',
        ]);
      case EventType.post:
        return first([
          () => str('text', max: maxPostText),
          () => body['media'] is List ? null : 'media must be a list',
        ]);
      case EventType.postEdit:
        return first([() => str('target'), () => str('text', max: maxPostText)]);
      case EventType.delete:
        return str('target');
      case EventType.reaction:
        return first([
          () => str('target'),
          () => str('sticker', max: 32, optional: true),
          () => integer('x', 0, 1000),
          () => integer('y', 0, 1000),
          () => integer('rot', -45, 45),
        ]);
      case EventType.comment:
        return first([
          () => str('target'),
          () => str('text', max: maxCommentText),
          () => str('parent', optional: true),
        ]);
      case EventType.follow:
        return first([
          () => str('target'),
          () => body['on'] is bool ? null : 'on must be bool',
        ]);
      case EventType.selfPrivate:
        return first([() => str('nonce'), () => str('ct')]);
      case EventType.modVouch:
        return first([
          () => str('candidate'),
          () => body['consent'] is Map ? null : 'consent must be a meet code',
        ]);
      case EventType.modRevoke:
        return first([
          () => str('target'),
          () {
            final c = body['cutoff'];
            return c is Map && c.values.every((v) => v is int)
                ? null
                : 'cutoff must map feed -> seq';
          },
        ]);
      case EventType.modBan:
        return first([
          () => str('target'),
          () => body['on'] is bool ? null : 'on must be bool',
          () => str('reason', max: maxModReason),
        ]);
      default:
        return null; // unknown types: forward-compatible, not projected
    }
  }
}
