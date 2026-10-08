import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jaal_core/jaal_core.dart';
import 'package:jaal_sim/jaal_sim.dart';

import '../../app/router.dart';
import '../../app/session.dart';
import '../../design/tokens.dart';
import '../../design/zine.dart';
import 'console_tab.dart';
import 'lab_providers.dart';
import 'wire_tab.dart';

/// Network Lab: spawn virtual peers, move them in and out of range, and
/// watch decentralized sync happen — before any real radio exists.
class LabScreen extends ConsumerWidget {
  const LabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('network lab'),
          bottom: const TabBar(tabs: [
            Tab(text: 'peers'),
            Tab(text: 'you'),
            Tab(text: 'wire'),
          ]),
        ),
        body: const Grain(
          child: TabBarView(children: [_PeersTab(), ConsoleTab(), WireTab()]),
        ),
      ),
    );
  }
}

class _PeersTab extends ConsumerWidget {
  const _PeersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(requireSessionProvider);
    final lab = session.lab;
    ref.watch(labTickProvider);
    final snaps = ref.watch(labSnapshotsProvider).value ?? const [];
    final you = lab.peers.firstWhere((p) => !p.virtual);

    return ListView(
      padding: const EdgeInsets.all(JaalSpace.s4),
      children: [
        GestureDetector(
          onTap: () => context.push(Routes.peer(lab.peers.indexOf(you))),
          child: _YouCard(you: you, snap: snaps.where((s) => !s.peer.virtual).firstOrNull),
        ),
        const SizedBox(height: JaalSpace.s4),
        _Controls(lab: lab),
        const SizedBox(height: JaalSpace.s4),
        if (lab.peers.length == 1)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: JaalSpace.s6),
            child: Center(
              child: HandNote('nobody around yet.\nspawn a peer ↑', color: JaalColors.xerox),
            ),
          ),
        for (final (i, p) in lab.peers.indexed)
          if (p.virtual)
            Padding(
              padding: const EdgeInsets.only(bottom: JaalSpace.s3),
              child: _PeerCard(
                lab: lab,
                you: you,
                peer: p,
                snap: snaps.where((s) => s.peer == p).firstOrNull,
                onOpen: () => context.push(Routes.peer(i)),
              ),
            ),
      ],
    );
  }
}

class _YouCard extends StatelessWidget {
  const _YouCard({required this.you, required this.snap});
  final LabPeer you;
  final PeerSnapshot? snap;

  @override
  Widget build(BuildContext context) {
    final root = you.node.rootId;
    return ZineBox(
      color: JaalColors.acid,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('you',
                  style: TextStyle(
                      fontFamily: JaalFonts.display,
                      fontSize: JaalSize.h2,
                      color: JaalColors.ink)),
              const SizedBox(width: JaalSpace.s2),
              MonoChip(fingerprintOf(root), color: JaalColors.paper),
              const Spacer(),
              const TapeStrip(width: 56, label: 'sim'),
            ],
          ),
          const SizedBox(height: JaalSpace.s2),
          Wrap(spacing: 6, runSpacing: 6, children: [
            MonoChip('${snap?.sessions ?? 0} live links', color: JaalColors.paper),
            MonoChip('${snap?.feeds ?? 0} feeds', color: JaalColors.paper),
            MonoChip('${snap?.events ?? 0} events', color: JaalColors.paper),
            MonoChip('carrying ${snap?.carrying ?? 0}', color: JaalColors.paper),
            MonoChip('clout ${snap?.delivered ?? 0}', color: JaalColors.pink),
            if (snap?.moderator ?? false)
              const MonoChip('★ moderator', color: JaalColors.blue, textColor: JaalColors.paper),
            if (snap?.banned ?? false)
              const MonoChip('removed by moderators', color: JaalColors.stamp, textColor: JaalColors.paper),
          ]),
        ],
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.lab});
  final NetworkLab lab;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: JaalSpace.s2,
        runSpacing: JaalSpace.s2,
        children: [
          ZineButton(
              small: true,
              icon: Icons.person_add_alt,
              label: 'spawn',
              onPressed: () => lab.addPeer()),
          ZineButton(
              small: true,
              color: JaalColors.paper,
              label: 'mesh',
              onPressed: lab.fullMesh),
          ZineButton(
              small: true,
              color: JaalColors.paper,
              label: 'chain',
              onPressed: lab.chain),
          ZineButton(
              small: true,
              color: JaalColors.paper,
              label: 'shuffle',
              onPressed: () => lab.shuffleProximity()),
          ZineButton(
              small: true,
              color: JaalColors.paper,
              label: 'apart',
              onPressed: lab.isolateAll),
          ZineButton(
              small: true,
              color: JaalColors.paper,
              label: 'follow-web',
              onPressed: () => lab.seedFollowGraph()),
          ZineButton(
              small: true,
              color: JaalColors.blue,
              icon: Icons.shield_outlined,
              label: 'mods',
              onPressed: () => lab.spawnGenesisModerators()),
          ZineButton(
              small: true,
              color: lab.chattering ? JaalColors.pink : JaalColors.paper,
              icon: lab.chattering ? Icons.pause : Icons.play_arrow,
              label: lab.chattering ? 'chatter on' : 'chatter',
              onPressed: () =>
                  lab.chattering ? lab.stopChatter() : lab.startChatter()),
        ],
      );
}

class _PeerCard extends StatelessWidget {
  const _PeerCard({
    required this.lab,
    required this.you,
    required this.peer,
    required this.snap,
    required this.onOpen,
  });

  final NetworkLab lab;
  final LabPeer you;
  final LabPeer peer;
  final PeerSnapshot? snap;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final inRange = lab.link(you, peer).up;
    final live = you.node.engine.connectedRoots.contains(peer.node.rootId);
    return GestureDetector(
      onTap: onOpen,
      child: ZineBox(
        tilt: tiltFor(peer.node.rootId, maxDeg: 1),
        padding: const EdgeInsets.all(JaalSpace.s3),
        child: Row(
          children: [
            _Polaroid(name: peer.name, live: live),
            const SizedBox(width: JaalSpace.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(peer.name.toLowerCase(),
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 2),
                  Text('·${fingerprintOf(peer.node.rootId)}  ${snap?.posts ?? 0} posts  ${snap?.carrying ?? 0} carried',
                      style: Theme.of(context).textTheme.labelSmall),
                  _ModBadges(you: you.node, root: peer.node.rootId),
                  const SizedBox(height: 4),
                  Text(
                    live
                        ? 'syncing with you'
                        : inRange
                            ? 'in range — handshaking'
                            : 'out of range',
                    style: TextStyle(
                        fontFamily: JaalFonts.hand,
                        fontSize: 18,
                        color: live ? JaalColors.blue : JaalColors.xerox),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Switch(
                  value: inRange,
                  onChanged: (_) => lab.toggleLink(you, peer),
                ),
                Text('near you', style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Polaroid cut-out avatar (placeholder: initial on a colour block).
class _Polaroid extends StatelessWidget {
  const _Polaroid({required this.name, required this.live});
  final String name;
  final bool live;

  @override
  Widget build(BuildContext context) {
    const colors = [JaalColors.pink, JaalColors.blue, JaalColors.acid, JaalColors.tape];
    final c = colors[name.codeUnitAt(0) % colors.length];
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
      decoration: BoxDecoration(
        color: JaalColors.paper,
        border: Border.all(color: inkOf(context), width: JaalStroke.hairline),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44,
            height: 44,
            color: c,
            alignment: Alignment.center,
            child: Text(name[0].toLowerCase(),
                style: TextStyle(
                    fontFamily: JaalFonts.display,
                    fontSize: 24,
                    color: c == JaalColors.blue ? JaalColors.paper : JaalColors.ink)),
          ),
          if (live)
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: JaalColors.acid,
                  shape: BoxShape.circle,
                  border: Border.all(color: JaalColors.ink, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Moderator / flagged / banned / lookalike badges, as *you* see them.
class _ModBadges extends StatelessWidget {
  const _ModBadges({required this.you, required this.root});
  final JaalNode you;
  final String root;

  @override
  Widget build(BuildContext context) {
    final m = you.moderation;
    return FutureBuilder<List<LookalikeWarning>>(
      future: you.lookalikesOf(root),
      builder: (context, snap) {
        final chips = <Widget>[
          if (m.isModerator(root))
            const MonoChip('★ mod', color: JaalColors.blue, textColor: JaalColors.paper),
          if (m.isFlagged(root)) const MonoChip('flagged', color: JaalColors.tape),
          if (m.isBanned(root))
            const MonoChip('removed', color: JaalColors.stamp, textColor: JaalColors.paper),
          for (final w in snap.data ?? const <LookalikeWarning>[])
            MonoChip('⚠ ${w.message}', color: JaalColors.stamp, textColor: JaalColors.paper),
        ];
        if (chips.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Wrap(spacing: 4, runSpacing: 4, children: chips),
        );
      },
    );
  }
}
