/// The three genesis moderator root keys shipped with the official app.
///
/// Generate them ONCE, offline, on a machine you trust:
///
///   cd packages/jaal_core && dart run tool/genesis.dart
///
/// The tool prints each key's 24-word recovery phrase exactly once (write
/// them on paper, keep them apart) and rewrites this file with the public
/// keys. Never commit the phrases.
///
/// While this set is empty, production builds have no moderators (moderation
/// events are inert). The Network Lab and tests inject their own genesis
/// keys through [ModerationConfig].
abstract final class GenesisKeys {
  static const Set<String> roots = {};
}
