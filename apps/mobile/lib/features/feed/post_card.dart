import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jaal_core/jaal_core.dart';

import '../../app/router.dart';
import '../../design/tokens.dart';
import '../../design/zine.dart';
import '../post/sticker_sheet.dart';
import '../shared/media.dart';
import '../shared/people.dart';
import '../shared/providers.dart';

String ago(int ms) {
  final d = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(ms));
  if (d.inDays > 0) return '${d.inDays}d ago';
  if (d.inHours > 0) return '${d.inHours}h ago';
  if (d.inMinutes > 0) return '${d.inMinutes}m ago';
  return 'just now';
}

/// A post as a pasted zine card (design 04): polaroid header, photo with
/// slapped stickers and a postmark, caption, hand-note, action row.
class PostCard extends ConsumerWidget {
  const PostCard({super.key, required this.post, this.index = 0, this.detail = false});

  final PostRow post;
  final int index;
  final bool detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final media = JaalNode.mediaOf(post);
    final reactions = ref.watch(reactionsProvider(post.id)).value ?? const [];
    final comments = ref.watch(commentCountProvider(post.id));
    final warn = ref.watch(lookalikesProvider(post.rootId)).value ?? const [];
    final me = ref.watch(nodeProvider).rootId;
    final transit = Duration(milliseconds: (post.firstSeenAt - post.ts).clamp(0, 1 << 40));
    final edited = post.editLamport > 0;
    final textOnly = media.isEmpty;
    final tilt = detail ? 0.0 : (index.isEven ? -1.0 : 1.0) * 0.012;

    final header = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Polaroid(root: post.rootId, size: 40, caption: false),
        const SizedBox(width: JaalSpace.s3),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            PersonLine(root: post.rootId),
            const SizedBox(height: 2),
            Row(children: [
              Icon(post.hops == 0 ? Icons.edit_outlined : Icons.alt_route, size: 14, color: JaalColors.xerox),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  post.hops == 0
                      ? 'posted ${ago(post.ts)}'
                      : 'relayed ${ago(post.ts)} · ${post.hops} hop${post.hops == 1 ? '' : 's'}',
                  style: monoStyle(11, color: JaalColors.xerox),
                ),
              ),
            ]),
          ]),
        ),
        _PostMenu(post: post, mine: post.rootId == me),
      ],
    );

    final card = ZineBox(
      tilt: tilt,
      color: textOnly ? Theme.of(context).colorScheme.surfaceContainerHighest : null,
      padding: const EdgeInsets.all(JaalSpace.s3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (warn.isNotEmpty) ...[
            HazardTape(red: true, child: Text('⚠ ${warn.first.message}')),
            const SizedBox(height: JaalSpace.s3),
          ],
          header,
          const SizedBox(height: JaalSpace.s3),
          if (!textOnly)
            _PhotoWithStickers(post: post, manifest: media.first, reactions: reactions, transit: transit)
          else
            Stack(clipBehavior: Clip.none, children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(JaalSpace.s4, JaalSpace.s4, 72, JaalSpace.s4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: JaalColors.ink, width: 2),
                ),
                child: Text('"${post.body}"',
                    style: const TextStyle(
                        fontFamily: JaalFonts.ui, fontSize: 20, height: 1.3, fontWeight: FontWeight.w500, color: JaalColors.ink)),
              ),
              Positioned(
                right: -6,
                top: -14,
                child: Postmark(hops: post.hops, transit: post.hops == 0 ? null : transit, size: 60),
              ),
            ]),
          if (!textOnly && post.body.isNotEmpty) ...[
            const SizedBox(height: JaalSpace.s3),
            Text(post.body, style: Theme.of(context).textTheme.bodyLarge),
          ],
          if (edited) ...[
            const SizedBox(height: JaalSpace.s2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(border: Border.all(color: JaalColors.stamp, width: 1.5)),
              child: Text('[ edited ]', style: monoStyle(11, color: JaalColors.stamp, bold: true)),
            ),
          ],
          if (post.hops > 1) ...[
            const SizedBox(height: JaalSpace.s2),
            HandNote('↗ passed through ${post.hops - 1} pocket${post.hops == 2 ? '' : 's'} to reach you', size: 20),
          ],
          if (textOnly && reactions.isNotEmpty) ...[
            const SizedBox(height: JaalSpace.s3),
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final r in reactions.take(8)) Sticker(r.sticker!, scale: 0.7, rot: r.rot.toDouble()),
            ]),
          ],
          const SizedBox(height: JaalSpace.s3),
          Row(children: [
            ZineButton(
              small: true,
              color: Theme.of(context).scaffoldBackgroundColor,
              icon: Icons.add_reaction_outlined,
              label: reactions.isEmpty ? 'slap sticker' : 'stick (${reactions.length})',
              onPressed: () => showStickerSheet(context, ref, post.id),
            ),
            const SizedBox(width: JaalSpace.s2),
            ZineButton(
              small: true,
              color: Theme.of(context).scaffoldBackgroundColor,
              icon: Icons.chat_bubble_outline,
              label: '$comments',
              onPressed: detail ? null : () => context.push(Routes.post(post.id)),
            ),
            const Spacer(),
            Flexible(
              child: Text(post.hops == 0 ? 'from your pocket' : 'via the mesh',
                  textAlign: TextAlign.right, style: monoStyle(11, color: JaalColors.xerox)),
            ),
          ]),
        ],
      ),
    );
    return detail ? card : GestureDetector(onTap: () => context.push(Routes.post(post.id)), child: card);
  }
}

class _PhotoWithStickers extends StatelessWidget {
  const _PhotoWithStickers({
    required this.post,
    required this.manifest,
    required this.reactions,
    required this.transit,
  });

  final PostRow post;
  final MediaManifest manifest;
  final List<ReactionRow> reactions;
  final Duration transit;

  @override
  Widget build(BuildContext context) {
    final ratio = (manifest.width != null && manifest.height != null && manifest.height! > 0)
        ? (manifest.width! / manifest.height!).clamp(0.6, 1.6)
        : 1.0;
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth, h = w / ratio;
      return SizedBox(
        width: w,
        height: h,
        child: Stack(clipBehavior: Clip.none, children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(border: Border.all(color: JaalColors.ink, width: JaalStroke.thick)),
              child: ClipRect(child: JaalPhoto(manifest: manifest)),
            ),
          ),
          for (final r in reactions.take(14))
            Positioned(
              left: (r.x / 1000 * w - 36).clamp(-8, w - 64),
              top: (r.y / 1000 * h - 18).clamp(-8, h - 36),
              child: Sticker(r.sticker!, scale: 0.85, rot: r.rot.toDouble()),
            ),
          if (reactions.length > 14)
            Positioned(right: 8, bottom: 8, child: MonoChip('+${reactions.length - 14}', color: JaalColors.paper)),
          Positioned(
            right: -10,
            top: -12,
            child: Postmark(hops: post.hops, transit: post.hops == 0 ? null : transit, size: 70),
          ),
        ]),
      );
    });
  }
}

class _PostMenu extends ConsumerWidget {
  const _PostMenu({required this.post, required this.mine});
  final PostRow post;
  final bool mine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final node = ref.read(nodeProvider);
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      shape: RoundedRectangleBorder(side: BorderSide(color: inkOf(context), width: 2)),
      onSelected: (v) async {
        switch (v) {
          case 'delete':
            await node.delete(post.id);
          case 'block':
            await node.block(post.rootId);
          case 'profile':
            if (context.mounted) context.push(Routes.profile(post.rootId));
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'profile', child: Text('view profile')),
        if (mine) const PopupMenuItem(value: 'delete', child: Text('delete (erases on every phone that syncs)')),
        if (!mine) const PopupMenuItem(value: 'block', child: Text('block (private)')),
      ],
    );
  }
}
