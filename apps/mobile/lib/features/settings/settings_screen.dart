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

/// Settings (design 15): stacked zine sections.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final node = ref.watch(nodeProvider);
    final p = ref.watch(profileProvider(node.rootId));
    final blocked = ref.watch(_blockedProvider).value ?? const {};
    final isMod = (ref.watch(moderatorsProvider).value ?? const {}).contains(node.rootId);

    return Scaffold(
      appBar: const ZineAppBar(title: 'settings'),
      body: Grain(
        child: ListView(padding: const EdgeInsets.all(JaalSpace.s4), children: [
          _Section(title: 'you', children: [
            Row(children: [
              Polaroid(root: node.rootId, size: 54),
              const SizedBox(width: 12),
              Expanded(child: MonoChip('@${p?.handle ?? 'anon'}·${fingerprintOf(node.rootId)}', color: JaalColors.paperDeep)),
            ]),
            const SizedBox(height: 12),
            Text('root key: ${node.rootId.substring(0, 6)}…${node.rootId.substring(node.rootId.length - 4)}',
                style: monoStyle(11, color: JaalColors.xerox)),
            const SizedBox(height: 12),
            ZineButton(
              small: true,
              color: JaalColors.paper,
              icon: Icons.lock_outline,
              label: 'show recovery phrase',
              onPressed: () => _showPhrase(context, node),
            ),
          ]),
          _Section(title: 'devices', children: [
            _row(context, 'this phone', 'device ·${fingerprintOf(node.feedId)}', const MonoChip('this one', color: JaalColors.acid)),
            const SizedBox(height: 6),
            const HandNote('restore your 24 words on another phone to add it. revoking: soon.', size: 18),
          ]),
          _Section(title: 'carrying for strangers', children: [
            _row(context, 'carry letters for strangers', 'up to 20 mb · 14-day expiry', const Switch(value: true, onChanged: null)),
          ]),
          _Section(title: 'how far your feed reaches', children: [
            _row(context, 'friends of friends', 'up to 150 people · established 7+ days', const Switch(value: true, onChanged: null)),
          ]),
          _Section(title: 'radios', children: [
            _row(context, 'simulated radio', 'network lab peers', const MonoChip('ready', color: JaalColors.acid)),
            _row(context, 'bluetooth', 'ble discovery + gatt', const MonoChip('soon')),
            _row(context, 'wifi direct', 'bulk photo transfer', const MonoChip('soon')),
            _row(context, 'local wifi', 'same hotspot, no internet', const MonoChip('soon')),
          ]),
          _Section(title: 'blocked', children: [
            Text('${blocked.length} people · private, only you know', style: monoStyle(12)),
            for (final b in blocked)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(handleOf(ref, b), style: monoStyle(12)),
                trailing: TextButton(
                  onPressed: () => node.unblock(b),
                  child: Text('unblock', style: monoStyle(11, color: JaalColors.blue)),
                ),
              ),
          ]),
          _Section(title: 'pass it on', children: [
            ZineButton(
              small: true,
              color: JaalColors.pink,
              icon: Icons.ios_share,
              label: 'share jaal with android + iphone',
              onPressed: () => context.push(Routes.share),
            ),
          ]),
          _Section(title: 'moderation', children: [
            ZineButton(
              small: true,
              color: JaalColors.paper,
              icon: Icons.shield_outlined,
              label: isMod ? 'moderation desk' : 'become a moderator',
              onPressed: () => context.push(isMod ? Routes.modDesk : Routes.becomeMod),
            ),
          ]),
          const SizedBox(height: JaalSpace.s4),
          Center(
            child: Column(children: [
              Text('jaal v0.1 · protocol v1 · no servers were harmed', style: monoStyle(11, color: JaalColors.xerox)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => context.push(Routes.lab),
                child: Text('network lab (dev)',
                    style: monoStyle(12, color: JaalColors.blue, bold: true).copyWith(decoration: TextDecoration.underline)),
              ),
            ]),
          ),
          const SizedBox(height: JaalSpace.s6),
        ]),
      ),
    );
  }

  Widget _row(BuildContext context, String title, String sub, Widget trailing) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              Text(sub, style: monoStyle(11, color: JaalColors.xerox)),
            ]),
          ),
          trailing,
        ]),
      );

  Future<void> _showPhrase(BuildContext context, JaalNode node) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('make sure nobody\'s watching'),
        content: const Text('anyone with these 24 words becomes you.'),
        actions: [ZineButton(small: true, color: JaalColors.stamp, label: 'show', onPressed: () => Navigator.pop(ctx, true))],
      ),
    );
    if (ok != true || !context.mounted) return;
    final words = node.me.root.recoveryPhrase.split(' ');
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('your 24 words'),
        content: Wrap(spacing: 6, runSpacing: 6, children: [
          for (final (i, w) in words.indexed) MonoChip('${(i + 1).toString().padLeft(2, '0')} $w'),
        ]),
        actions: [ZineButton(small: true, label: 'done', onPressed: () => Navigator.pop(ctx))],
      ),
    );
  }
}

final _blockedProvider = StreamProvider<Set<String>>((ref) => ref.watch(nodeProvider).db.watchBlocked());

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: JaalSpace.s5),
        child: ZineBox(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Highlighted(title, size: JaalSize.h3),
            const SizedBox(height: JaalSpace.s3),
            ...children,
          ]),
        ),
      );
}
