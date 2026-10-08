import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jaal_core/jaal_core.dart';

import '../../app/router.dart';
import '../../design/tokens.dart';
import '../../design/zine.dart';
import '../shared/people.dart';
import '../shared/providers.dart';
import '../shell/app_shell.dart';

const _reasons = ['harassment', 'hate', 'spam', 'impersonation', 'threats', 'other'];

/// Confirm-removal sheet (design 18, artboard 2). One vote flags; the second
/// moderator's vote removes.
Future<void> showRemoveSheet(BuildContext context, WidgetRef ref, String root) async {
  final node = ref.read(nodeProvider);
  var reason = 'harassment';
  final note = TextEditingController();
  final go = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, set) => Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.viewInsetsOf(ctx).bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('remove ${handleOf(ref, root)}?', style: displayStyle(24, color: inkOf(ctx))),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final r in _reasons)
              GestureDetector(
                onTap: () => set(() => reason = r),
                child: MonoChip(r, color: r == reason ? JaalColors.stamp : null, textColor: r == reason ? JaalColors.paper : null),
              ),
          ]),
          const SizedBox(height: 12),
          TextField(controller: note, maxLength: Bodies.maxModReason - 20, decoration: const InputDecoration(hintText: 'note for other mods')),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(border: Border.all(color: inkOf(ctx), width: 2)),
            child: Text(
              '✕ their posts vanish from every phone that syncs\n'
              '✕ they can\'t post, comment or stick again\n'
              '✕ their dms are dropped\n'
              '✓ any moderator can retract\n'
              '→ your vote flags them; a 2nd moderator removes them',
              style: monoStyle(11),
            ),
          ),
          const SizedBox(height: 14),
          ZineButton(
            color: JaalColors.stamp,
            icon: Icons.gavel,
            label: 'stamp it',
            expand: true,
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ]),
      ),
    ),
  );
  if (go != true) return;
  final text = note.text.trim().isEmpty ? reason : '$reason: ${note.text.trim()}';
  try {
    await node.banVote(root, reason: text);
  } on Object catch (e) {
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
  }
}

/// The moderation desk (design 18): cases needing a second vote, removed
/// people, and the moderator roster.
class ModerationDeskScreen extends ConsumerStatefulWidget {
  const ModerationDeskScreen({super.key});

  @override
  ConsumerState<ModerationDeskScreen> createState() => _DeskState();
}

class _DeskState extends ConsumerState<ModerationDeskScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final node = ref.watch(nodeProvider);
    final status = ref.watch(modStatusProvider).value ?? const {};
    final mods = ref.watch(moderatorsProvider).value ?? const {};
    final flagged = status.values.where((s) => s.state == ModState.flagged).toList();
    final removed = status.values.where((s) => s.state == ModState.banned).toList();

    if (!node.isModerator) {
      return Scaffold(
        appBar: const ZineAppBar(title: 'the desk'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const HandNote('moderators only. get vouched in first.'),
              const SizedBox(height: 16),
              ZineButton(label: 'become a moderator', onPressed: () => context.pushReplacement(Routes.becomeMod)),
            ]),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: const ZineAppBar(title: 'the desk', actions: [ModBadge()]),
      body: Grain(
        child: ListView(padding: const EdgeInsets.all(JaalSpace.s4), children: [
          const HandNote('1 vote hides them. 2 votes remove them for good.'),
          const SizedBox(height: JaalSpace.s4),
          Row(children: [
            for (final (i, l) in ['needs a 2nd vote (${flagged.length})', 'removed (${removed.length})', 'mods (${mods.length})'].indexed)
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _tab = i),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _tab == i ? JaalColors.acid : null,
                      border: Border.all(color: inkOf(context), width: _tab == i ? 3 : 1.5),
                    ),
                    child: Text(l, textAlign: TextAlign.center, style: monoStyle(11, bold: _tab == i, color: _tab == i ? JaalColors.ink : null)),
                  ),
                ),
              ),
          ]),
          const SizedBox(height: JaalSpace.s4),
          if (_tab == 0) ...[
            if (flagged.isEmpty) const HandNote('nothing waiting. quiet night.', color: JaalColors.xerox),
            for (final (i, s) in flagged.indexed) _CaseCard(status: s, index: i),
            const SizedBox(height: JaalSpace.s4),
            ZineButton(
              color: JaalColors.paper,
              icon: Icons.person_search_outlined,
              label: 'flag someone',
              onPressed: () => _pickPerson(context),
            ),
          ],
          if (_tab == 1) ...[
            if (removed.isEmpty) const HandNote('nobody removed.', color: JaalColors.xerox),
            for (final s in removed)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ZineBox(
                  shadow: JaalStroke.shadowSmall,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Row(children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(handleOf(ref, s.rootId), style: monoStyle(13, bold: true)),
                        Text('${s.votes} votes · ${s.reason}', style: monoStyle(11, color: JaalColors.stamp)),
                      ]),
                    ),
                    TextButton(
                      onPressed: () => node.retractBanVote(s.rootId),
                      child: Text('retract my vote', style: monoStyle(11, color: JaalColors.blue)),
                    ),
                  ]),
                ),
              ),
          ],
          if (_tab == 2)
            for (final m in mods)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Polaroid(root: m, size: 36, caption: false),
                title: Text(handleOf(ref, m), style: monoStyle(13, bold: true)),
                subtitle: Text(node.moderation.config.genesis.contains(m) ? 'genesis moderator' : 'vouched moderator',
                    style: monoStyle(11, color: JaalColors.xerox)),
                trailing: node.moderation.config.genesis.contains(m) || m == node.rootId
                    ? null
                    : TextButton(
                        onPressed: () => node.revokeModerator(m),
                        child: Text('revoke', style: monoStyle(11, color: JaalColors.stamp)),
                      ),
              ),
        ]),
      ),
    );
  }

  Future<void> _pickPerson(BuildContext context) async {
    final profiles = ref.read(profilesProvider).value ?? const {};
    final node = ref.read(nodeProvider);
    final mods = ref.read(moderatorsProvider).value ?? const {};
    final pick = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => ListView(padding: const EdgeInsets.all(16), children: [
        Text('who?', style: displayStyle(24, color: inkOf(ctx))),
        for (final p in profiles.values)
          if (p.rootId != node.rootId && !mods.contains(p.rootId))
            ListTile(
              title: Text('@${p.handle}·${fingerprintOf(p.rootId)}', style: monoStyle(13)),
              onTap: () => Navigator.pop(ctx, p.rootId),
            ),
      ]),
    );
    if (pick != null && context.mounted) await showRemoveSheet(context, ref, pick);
  }
}

class _CaseCard extends ConsumerWidget {
  const _CaseCard({required this.status, required this.index});
  final ModStatusRow status;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final node = ref.read(nodeProvider);
    final voters = node.moderation.votesAgainst(status.rootId);
    final myVote = voters.contains(node.rootId);
    return Padding(
      padding: const EdgeInsets.only(bottom: JaalSpace.s4),
      child: ZineBox(
        tilt: (index.isEven ? -1 : 1) * 0.01,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Polaroid(root: status.rootId, size: 44, caption: false),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(handleOf(ref, status.rootId), style: monoStyle(13, bold: true)),
                const SizedBox(height: 4),
                MonoChip(status.reason.isEmpty ? 'no reason given' : status.reason),
              ]),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            StampSlot(label: voters.isEmpty ? 'flagged' : nameOf(ref, voters.first), size: 70),
            const SizedBox(width: 10),
            const StampSlot(size: 70),
            const SizedBox(width: 12),
            Expanded(child: Text('2nd vote removes', style: monoStyle(11, color: JaalColors.xerox))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            ZineButton(
              small: true,
              color: JaalColors.stamp,
              label: myVote ? 'needs another mod' : 'remove ✕',
              onPressed: myVote ? null : () => showRemoveSheet(context, ref, status.rootId),
            ),
            const SizedBox(width: 8),
            ZineButton(
              small: true,
              color: JaalColors.paper,
              label: 'view',
              onPressed: () => context.push(Routes.profile(status.rootId)),
            ),
            const Spacer(),
            if (myVote)
              TextButton(
                onPressed: () => node.retractBanVote(status.rootId),
                child: Text('retract my vote', style: monoStyle(10, color: JaalColors.blue)),
              ),
          ]),
        ]),
      ),
    );
  }
}
