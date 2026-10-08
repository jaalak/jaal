import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jaal_core/jaal_core.dart';
import 'package:jaal_sim/jaal_sim.dart';

import '../../app/session.dart';
import '../../design/tokens.dart';
import '../../design/zine.dart';
import 'lab_providers.dart';

/// One virtual peer up close: its links to everyone (range, latency,
/// flakiness), what it holds, and what it's carrying.
class PeerInspectorScreen extends ConsumerWidget {
  const PeerInspectorScreen({super.key, required this.index});
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lab = ref.watch(requireSessionProvider).lab;
    ref.watch(labTickProvider);
    if (index >= lab.peers.length) {
      return const Scaffold(body: Center(child: Text('peer left')));
    }
    final peer = lab.peers[index];
    final snap = (ref.watch(labSnapshotsProvider).value ?? const [])
        .where((s) => s.peer == peer)
        .firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(peer.name.toLowerCase()),
        actions: [
          if (peer.virtual)
            IconButton(
              tooltip: 'remove peer',
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                Navigator.pop(context);
                await lab.removePeer(peer);
              },
            ),
        ],
      ),
      body: Grain(
        child: ListView(
          padding: const EdgeInsets.all(JaalSpace.s4),
          children: [
            Wrap(spacing: 6, runSpacing: 6, children: [
              MonoChip('·${fingerprintOf(peer.node.rootId)}'),
              MonoChip('${snap?.events ?? 0} events'),
              MonoChip('${snap?.feeds ?? 0} feeds'),
              MonoChip('${snap?.messages ?? 0} dms'),
              MonoChip('carrying ${snap?.carrying ?? 0}', color: JaalColors.blue, textColor: JaalColors.paper),
              MonoChip('clout ${snap?.delivered ?? 0}', color: JaalColors.pink),
            ]),
            const SizedBox(height: JaalSpace.s5),
            _ModerationPanel(lab: lab, target: peer),
            const SizedBox(height: JaalSpace.s5),
            const Highlighted('links', size: JaalSize.h3),
            const SizedBox(height: JaalSpace.s2),
            for (final other in lab.peers)
              if (other != peer) _LinkEditor(lab: lab, a: peer, b: other),
            const SizedBox(height: JaalSpace.s5),
            const Highlighted('holds', size: JaalSize.h3, color: JaalColors.pink),
            const SizedBox(height: JaalSpace.s2),
            StreamBuilder<List<PostRow>>(
              stream: peer.node.db.watchAllPosts(limit: 30),
              builder: (context, s) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final p in s.data ?? const <PostRow>[])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('${p.hops}h  ·${fingerprintOf(p.rootId)}  ${p.body}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontFamily: JaalFonts.mono, fontSize: JaalSize.small)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkEditor extends StatelessWidget {
  const _LinkEditor({required this.lab, required this.a, required this.b});
  final NetworkLab lab;
  final LabPeer a, b;

  @override
  Widget build(BuildContext context) {
    final cfg = lab.link(a, b);
    return Padding(
      padding: const EdgeInsets.only(bottom: JaalSpace.s3),
      child: ZineBox(
        shadow: JaalStroke.shadowSmall,
        padding: const EdgeInsets.symmetric(horizontal: JaalSpace.s3, vertical: JaalSpace.s2),
        child: Column(
          children: [
            Row(children: [
              Expanded(
                child: Text('⇄ ${b.name.toLowerCase()}',
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              Switch(value: cfg.up, onChanged: (_) => lab.toggleLink(a, b)),
            ]),
            if (cfg.up) ...[
              Row(children: [
                const SizedBox(width: 70, child: Text('latency')),
                Expanded(
                  child: Slider(
                    value: cfg.latency.inMilliseconds.toDouble().clamp(0, 2000),
                    max: 2000,
                    divisions: 20,
                    onChanged: (v) => lab.setLink(
                        a, b, cfg.copyWith(latency: Duration(milliseconds: v.round()))),
                  ),
                ),
                SizedBox(width: 56, child: Text('${cfg.latency.inMilliseconds}ms',
                    style: Theme.of(context).textTheme.labelSmall)),
              ]),
              Row(children: [
                const SizedBox(width: 70, child: Text('flaky')),
                Expanded(
                  child: Slider(
                    value: cfg.dropChance.clamp(0, 0.5),
                    max: 0.5,
                    divisions: 10,
                    onChanged: (v) => lab.setLink(a, b, cfg.copyWith(dropChance: v)),
                  ),
                ),
                SizedBox(width: 56, child: Text('${(cfg.dropChance * 100).round()}%',
                    style: Theme.of(context).textTheme.labelSmall)),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}

/// Act as any moderator in the lab on this peer: vouch (simulates scanning
/// their consent QR in person), vote to remove, or revoke.
class _ModerationPanel extends StatelessWidget {
  const _ModerationPanel({required this.lab, required this.target});
  final NetworkLab lab;
  final LabPeer target;

  Future<void> _run(BuildContext context, Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final root = target.node.rootId;
    final mods = lab.peers
        .where((p) => p != target && p.node.isModerator)
        .toList();
    final view = lab.peers.first.node.moderation; // any honest peer's view
    final isMod = view.isModerator(root);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Highlighted('moderation', size: JaalSize.h3, color: JaalColors.blue),
        const SizedBox(height: JaalSpace.s2),
        Text(
          isMod
              ? 'moderator'
              : view.isBanned(root)
                  ? 'removed by moderators'
                  : view.isFlagged(root)
                      ? 'flagged (1 vote) — hidden, not yet removed'
                      : 'regular user',
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: JaalSpace.s2),
        if (mods.isEmpty)
          const HandNote('no moderators in the lab yet — tap "mods" on the peers tab',
              color: JaalColors.xerox)
        else
          for (final m in mods)
            Padding(
              padding: const EdgeInsets.only(bottom: JaalSpace.s2),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                      width: 64,
                      child: Text('as ${m.name.toLowerCase()}',
                          style: Theme.of(context).textTheme.labelSmall)),
                  if (!isMod)
                    ZineButton(
                        small: true,
                        color: JaalColors.paper,
                        label: 'vouch (qr)',
                        onPressed: () => _run(context, () => lab.vouch(m, target))),
                  if (!isMod)
                    ZineButton(
                        small: true,
                        color: JaalColors.stamp,
                        label: 'remove',
                        onPressed: () => _run(context, () => lab.banVote(m, target))),
                  if (isMod && !lab.genesis.any((g) => g.id == root))
                    ZineButton(
                        small: true,
                        color: JaalColors.stamp,
                        label: 'revoke',
                        onPressed: () => _run(context, () => lab.revokeModerator(m, target))),
                ],
              ),
            ),
        const SizedBox(height: JaalSpace.s2),
        ZineButton(
            small: true,
            color: JaalColors.paper,
            icon: Icons.theater_comedy_outlined,
            label: 'spawn an impostor of ${target.name.toLowerCase()}',
            onPressed: () => _run(context, () async {
                  await lab.spawnImpostor(target);
                })),
      ],
    );
  }
}
