import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jaal_core/jaal_core.dart';

import '../../design/tokens.dart';
import '../../design/zine.dart';
import '../feed/post_card.dart';
import '../shared/media.dart';
import '../shared/people.dart';
import '../shared/providers.dart';
import '../shell/app_shell.dart';
import 'sticker_sheet.dart';

/// Post detail (design 05): the post, a travel-log ticket, the sticker
/// tray, threaded replies and a composer that travels with the post.
class PostDetailScreen extends ConsumerStatefulWidget {
  const PostDetailScreen({super.key, required this.id});
  final String id;

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final _text = TextEditingController();
  String? _replyTo;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final t = _text.text.trim();
    if (t.isEmpty) return;
    try {
      await ref.read(nodeProvider).comment(widget.id, t, parent: _replyTo);
      _text.clear();
      setState(() => _replyTo = null);
    } on Object catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = ref.watch(postProvider(widget.id)).value;
    final comments = ref.watch(commentsProvider(widget.id)).value ?? const [];
    final reactions = ref.watch(reactionsProvider(widget.id)).value ?? const [];
    final me = ref.watch(nodeProvider).rootId;

    return Scaffold(
      appBar: const ZineAppBar(title: 'post', subtitle: 'dispatch // signed + chained'),
      body: Grain(
        child: post == null
            ? const Center(child: HandNote('this post isn\'t on your phone (anymore).'))
            : post.deleted
                ? const Padding(padding: EdgeInsets.all(JaalSpace.s4), child: _Tombstone(what: 'post'))
                : ListView(
                    padding: const EdgeInsets.all(JaalSpace.s4),
                    children: [
                      PostCard(post: post, detail: true),
                      const SizedBox(height: JaalSpace.s5),
                      _TravelLog(post: post),
                      const SizedBox(height: JaalSpace.s5),
                      SectionHeader('sticker tray (slap one)',
                          icon: Icons.sell_outlined, meta: '${reactions.length} active'),
                      _StickerTray(reactions: reactions, me: me, postId: post.id),
                      const SizedBox(height: JaalSpace.s5),
                      SectionHeader('replies // ${comments.length} hopping', icon: Icons.forum_outlined),
                      if (comments.isEmpty)
                        const HandNote('no replies yet. yours will travel with the post.', size: 19),
                      for (final c in comments.where((c) => c.parent == null)) ...[
                        _CommentTile(c: c, onReply: () => setState(() => _replyTo = c.id)),
                        for (final r in comments.where((x) => x.parent == c.id))
                          Padding(
                            padding: const EdgeInsets.only(left: 28),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const HandNote('↳ reply relayed', size: 18),
                              _CommentTile(c: r),
                            ]),
                          ),
                        const SizedBox(height: JaalSpace.s3),
                      ],
                      const SizedBox(height: 90),
                    ],
                  ),
      ),
      bottomSheet: post == null || post.deleted
          ? null
          : Container(
              padding: EdgeInsets.fromLTRB(
                  JaalSpace.s4, JaalSpace.s3, JaalSpace.s4, JaalSpace.s3 + MediaQuery.paddingOf(context).bottom),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: Border(top: BorderSide(color: inkOf(context), width: JaalStroke.thick)),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                if (_replyTo != null)
                  Row(children: [
                    Text('replying in thread', style: monoStyle(11, color: JaalColors.blue)),
                    const Spacer(),
                    GestureDetector(
                        onTap: () => setState(() => _replyTo = null),
                        child: Text('cancel', style: monoStyle(11, color: JaalColors.stamp))),
                  ]),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _text,
                      maxLength: Bodies.maxCommentText,
                      buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                      decoration: const InputDecoration(hintText: 'add a comment (it\'ll travel with the post)'),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: JaalSpace.s2),
                  ZineIconButton(icon: Icons.arrow_upward, color: JaalColors.acid, onPressed: _send, tooltip: 'send'),
                ]),
              ]),
            ),
    );
  }
}

class _TravelLog extends ConsumerWidget {
  const _TravelLog({required this.post});
  final PostRow post;

  String _t(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final author = nameOf(ref, post.rootId);
    final carriers = (post.hops - 1).clamp(0, 99);
    return TicketStub(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.confirmation_number_outlined, size: 18),
          const SizedBox(width: 6),
          Expanded(child: Text('transit log // ticket #${post.id.substring(0, 6)}', style: monoStyle(12, bold: true))),
          const MonoChip('0 towers', color: JaalColors.acid),
        ]),
        const Divider(height: 20),
        Text(
          post.hops == 0
              ? 'written here · ${_t(post.ts)} · waiting for someone to walk by'
              : 'left $author (${_t(post.ts)})  →  $carriers phone${carriers == 1 ? '' : 's'}  →  you (${_t(post.firstSeenAt)})',
          style: monoStyle(12),
        ),
        const SizedBox(height: 10),
        Row(children: [
          for (var i = 0; i <= post.hops; i++) ...[
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i == post.hops ? JaalColors.acid : (i == 0 ? JaalColors.ink : JaalColors.blue),
                border: Border.all(color: JaalColors.ink, width: 2),
              ),
            ),
            if (i < post.hops) Expanded(child: Container(height: 2.5, color: JaalColors.blue)),
          ],
        ]),
        const SizedBox(height: 10),
        Text('${post.hops} hop${post.hops == 1 ? '' : 's'} · 0 towers', style: monoStyle(11, bold: true)),
        const SizedBox(height: 4),
        Text('carriers stay anonymous. no trace left behind.',
            style: monoStyle(11, color: JaalColors.xerox).copyWith(fontStyle: FontStyle.italic)),
      ]),
    );
  }
}

class _StickerTray extends ConsumerWidget {
  const _StickerTray({required this.reactions, required this.me, required this.postId});
  final List<ReactionRow> reactions;
  final String me;
  final String postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counts = <String, int>{};
    for (final r in reactions) {
      counts[r.sticker!] = (counts[r.sticker!] ?? 0) + 1;
    }
    final mine = reactions.where((r) => r.rootId == me).firstOrNull?.sticker;
    final ordered = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return SizedBox(
      height: 64,
      child: ListView(scrollDirection: Axis.horizontal, children: [
        for (final e in ordered)
          Padding(
            padding: const EdgeInsets.only(right: 10, top: 8),
            child: Stack(clipBehavior: Clip.none, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: e.key == mine ? JaalColors.acid : Color.lerp(JaalColors.paper, StickerStyle.of(e.key).bg, 0.3),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: JaalColors.ink, width: e.key == mine ? 3 : 2),
                  boxShadow: const [BoxShadow(color: JaalColors.ink, offset: JaalStroke.shadowSmall)],
                ),
                child: Text('${e.key}  ${e.value}', style: monoStyle(13, color: JaalColors.ink, bold: true)),
              ),
              if (e.key == mine)
                const Positioned(top: -8, right: 6, child: InkLabel('yours', color: JaalColors.acid, textColor: JaalColors.ink)),
            ]),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: ZineButton(
            small: true,
            color: JaalColors.paper,
            icon: Icons.add,
            label: mine == null ? 'slap one' : 'swap',
            onPressed: () => showStickerSheet(context, ref, postId),
          ),
        ),
      ]),
    );
  }
}

class _CommentTile extends ConsumerWidget {
  const _CommentTile({required this.c, this.onReply});
  final CommentRow c;
  final VoidCallback? onReply;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (c.deleted) return const _Tombstone(what: 'reply');
    final mine = c.rootId == ref.watch(nodeProvider).rootId;
    return ZineBox(
      shadow: JaalStroke.shadowSmall,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.all(JaalSpace.s3),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Polaroid(root: c.rootId, size: 30, caption: false),
        const SizedBox(width: JaalSpace.s3),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            PersonLine(root: c.rootId, trailing: Text(ago(c.ts), style: monoStyle(11, color: JaalColors.xerox))),
            const SizedBox(height: 4),
            Text(c.body, style: Theme.of(context).textTheme.bodyLarge),
            Row(children: [
              if (onReply != null)
                TextButton(onPressed: onReply, child: Text('reply', style: monoStyle(11, color: JaalColors.blue))),
              if (mine)
                TextButton(
                  onPressed: () => ref.read(nodeProvider).delete(c.id),
                  child: Text('delete', style: monoStyle(11, color: JaalColors.stamp)),
                ),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _Tombstone extends StatelessWidget {
  const _Tombstone({required this.what});
  final String what;

  @override
  Widget build(BuildContext context) => ZineBox(
        dashed: true,
        shadow: Offset.zero,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Row(children: [
          const Icon(Icons.content_cut, color: JaalColors.xerox),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('[ $what tombstone // deleted by author ]', style: monoStyle(12, color: JaalColors.xerox, bold: true)),
              Text('erased from every phone that syncs', style: monoStyle(11, color: JaalColors.xerox)),
            ]),
          ),
        ]),
      );
}
