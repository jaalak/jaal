import '../identity/identity.dart';
import 'genesis_keys.dart';

/// Rules of the moderation system (protocol/SPEC.md §10). Every honest
/// client must use the same values, or peers will disagree on who's banned.
class ModerationConfig {
  const ModerationConfig({
    this.genesis = const {},
    this.vouchesRequired = 3,
    this.banQuorum = 2,
    this.revokeQuorum = 3,
    this.consentMaxSkew = const Duration(hours: 24),
    this.liveCodeMaxAge = const Duration(minutes: 10),
  });

  /// Production rules with the shipped genesis keys.
  static const production = ModerationConfig(genesis: GenesisKeys.roots);

  /// Root keys that are moderators by definition and can't be revoked or
  /// banned. Changing them requires an app update.
  final Set<RootId> genesis;

  /// Distinct moderator vouches (in-person QR) needed to become a moderator.
  final int vouchesRequired;

  /// Distinct moderator ban votes for a permanent ban. One vote = flagged.
  final int banQuorum;

  /// Distinct moderators needed to revoke a moderator (any one genesis key
  /// can also revoke alone).
  final int revokeQuorum;

  /// Max gap between a vouch and the consent QR it embeds (protocol check).
  final Duration consentMaxSkew;

  /// Max age of a QR when scanned (enforced by the scanning device).
  final Duration liveCodeMaxAge;

  ModerationConfig withGenesis(Set<RootId> roots) => ModerationConfig(
        genesis: {...genesis, ...roots},
        vouchesRequired: vouchesRequired,
        banQuorum: banQuorum,
        revokeQuorum: revokeQuorum,
        consentMaxSkew: consentMaxSkew,
        liveCodeMaxAge: liveCodeMaxAge,
      );
}
