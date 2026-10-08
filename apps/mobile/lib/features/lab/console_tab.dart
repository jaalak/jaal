import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jaal_core/jaal_core.dart';

import '../../app/session.dart';
import '../../design/tokens.dart';
import '../../design/zine.dart';
import 'lab_providers.dart';

/// Developer console for the local user: post, stick, follow, DM — wired to
/// the real local node so every action becomes a signed event. Raw on
/// purpose: the real social screens come from the Stitch designs.
class ConsoleTab extends ConsumerStatefulWidget {
  const ConsoleTab({super.key});

  @override
  ConsumerState<ConsoleTab> createState() => _ConsoleTabState();
}

class _ConsoleTabState extends ConsumerState<ConsoleTab> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _post(JaalNode node) async {
    final t = _text.text.trim();
    if (t.isEmpty) return;
    await node.post(t);
    _text.clear();
  }

  @override
  Widget build(BuildContext context) {
    final node = ref.watch(requireSessionProvider).node;
    final posts = ref.watch(allPostsProvider).value ?? const [];
    final profiles = ref.watch(profilesProvider).value ?? const [];
    final following = ref.watch(followingProvider).value ?? const {};
    final inbox = ref.watch(inboxProvider).value ?? const [];
    final pouch = ref.watch(carryPouchProvider).value ?? const [];
    final clout = ref.watch(courierCloutProvider).value ?? 0;
    final names = {for (final p in profiles) p.rootId: p.handle};

    return ListView(
      padding: const EdgeInsets.all(JaalSpace.s4),
      children: [
        Row(children: [
          Expanded(
            child: TextField(
              controller: _text,
              decoration: const InputDecoration(hintText: 'say something offline'),
              onSubmitted: (_) => _post(node),
            ),
          ),
          const SizedBox(width: JaalSpace.s2),
          ZineButton(small: true, label: 'post', onPressed: () => _post(node)),
        ]),
        const SizedBox(height: JaalSpace.s5),
        const Highlighted('people', size: JaalSize.h3),
        const SizedBox(height: JaalSpace.s2),
        for (final p in profiles)
          if (p.rootId != node.rootId)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('@${p.handle}·${fingerprintOf(p.rootId)}',
                  style: const TextStyle(fontFamily: JaalFonts.mono, fontSize: JaalSize.small)),
              subtitle: Text(p.bio, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: Wrap(spacing: 6, children: [
                ZineButton(
                  small: true,
                  color: following.contains(p.rootId) ? JaalColors.acid : JaalColors.paper,
                  label: following.contains(p.rootId) ? 'following' : 'follow',
                  onPressed: () => following.contains(p.rootId)
                      ? node.unfollow(p.rootId)
                      : node.follow(p.rootId),
                ),
                ZineButton(
                  small: true,
                  color: JaalColors.pink,
                  label: 'dm',
                  onPressed: () => _dm(context, node, p),
                ),
              ]),
            ),
        const SizedBox(height: JaalSpace.s5),
        Highlighted('inbox (${inbox.length})', size: JaalSize.h3, color: JaalColors.pink),
        for (final m in inbox)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(m.outgoing ? Icons.north_east : Icons.south_west, size: 18),
            title: Text(m.body),
            subtitle: Text(
                '@${names[m.peerRoot] ?? '?'} · ${m.outgoing ? (m.delivered ? 'delivered' : 'in a stranger\'s pocket') : 'received'}',
                style: Theme.of(context).textTheme.labelSmall),
          ),
        const SizedBox(height: JaalSpace.s5),
        Highlighted('carry pouch (${pouch.length}) · clout $clout',
            size: JaalSize.h3, color: JaalColors.blue),
        const SizedBox(height: JaalSpace.s2),
        if (pouch.isEmpty)
          const HandNote('not carrying anyone\'s mail right now', color: JaalColors.xerox)
        else
          Wrap(spacing: 6, runSpacing: 6, children: [
            for (final e in pouch)
              MonoChip('✉ ${e.id.substring(0, 6)} · ${e.size}b · ${e.hops}h'),
          ]),
        const SizedBox(height: JaalSpace.s5),
        Highlighted('everything you hold (${posts.length})', size: JaalSize.h3),
        const SizedBox(height: JaalSpace.s3),
        for (final p in posts)
          Padding(
            padding: const EdgeInsets.only(bottom: JaalSpace.s4),
            child: _DebugPost(post: p, author: names[p.rootId], node: node),
          ),
      ],
    );
  }

  Future<void> _dm(BuildContext context, JaalNode node, ProfileRow to) async {
    final c = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('seal a note for @${to.handle}'),
        content: TextField(controller: c, autofocus: true),
        actions: [
          ZineButton(
              small: true,
              color: JaalColors.pink,
              label: 'seal + send',
              onPressed: () => Navigator.pop(ctx, c.text)),
        ],
      ),
    );
    c.dispose();
    if (text != null && text.trim().isNotEmpty) {
      await node.sendDm(to.rootId, text.trim());
    }
  }
}

class _DebugPost extends ConsumerWidget {
  const _DebugPost({required this.post, required this.author, required this.node});
  final PostRow post;
  final String? author;
  final JaalNode node;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transit = Duration(milliseconds: (post.firstSeenAt - post.ts).clamp(0, 1 << 40));
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ZineBox(
          tilt: tiltFor(post.id, maxDeg: 1.2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('@${author ?? 'anon'}·${fingerprintOf(post.rootId)}',
                  style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: JaalSpace.s2),
              Padding(
                padding: const EdgeInsets.only(right: 56),
                child: Text(post.body, style: Theme.of(context).textTheme.bodyLarge),
              ),
              const SizedBox(height: JaalSpace.s3),
              StreamBuilder<List<ReactionRow>>(
                stream: node.db.watchReactions(post.id),
                builder: (context, snap) {
                  final rs = snap.data ?? const [];
                  return Wrap(spacing: 6, runSpacing: 6, children: [
                    for (final r in rs) MonoChip(r.sticker!, color: JaalColors.pink),
                    for (final s in const ['fire', 'real', 'skull'])
                      GestureDetector(
                        onTap: () => node.react(post.id,
                            sticker: s, rot: (s.hashCode % 21) - 10),
                        child: MonoChip('+$s'),
                      ),
                  ]);
                },
              ),
            ],
          ),
        ),
        Positioned(
          right: 4,
          top: -10,
          child: Postmark(hops: post.hops, transit: post.hops == 0 ? null : transit, size: 58),
        ),
      ],
    );
  }
}
