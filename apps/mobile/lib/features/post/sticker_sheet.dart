import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jaal_core/jaal_core.dart';

import '../../design/tokens.dart';
import '../../design/zine.dart';
import '../shared/media.dart';
import '../shared/providers.dart';

/// "stick something" die-cut tray (design 06). Picking a sticker slaps it
/// onto the post at a hand-placed angle; it spreads as phones meet.
Future<void> showStickerSheet(BuildContext context, WidgetRef ref, String postId) async {
  final node = ref.read(nodeProvider);
  final mine = (await node.db.watchReactions(postId).first)
      .where((r) => r.rootId == node.rootId)
      .firstOrNull;
  if (!context.mounted) return;
  final picked = await showModalBottomSheet<String?>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _StickerTray(current: mine?.sticker),
  );
  if (picked == null) return;
  final rng = Random(postId.hashCode ^ picked.hashCode ^ DateTime.now().millisecond);
  try {
    if (picked == '__peel') {
      await node.react(postId, sticker: null);
    } else {
      await node.react(postId,
          sticker: picked,
          x: 120 + rng.nextInt(760),
          y: 120 + rng.nextInt(760),
          rot: rng.nextInt(31) - 15);
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(picked == '__peel' ? 'peeled off.' : 'stuck. it\'ll spread as phones meet.')));
    }
  } on BannedException catch (e) {
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
  }
}

class _StickerTray extends StatelessWidget {
  const _StickerTray({required this.current});
  final String? current;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(JaalSpace.s4, JaalSpace.s3, JaalSpace.s4, JaalSpace.s5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: TapeStrip(width: 110, angle: 0)),
            const SizedBox(height: JaalSpace.s3),
            Row(children: [
              Text('stick something', style: displayStyle(JaalSize.h2, color: inkOf(context))),
              const Spacer(),
              Text('die-cut tray', style: monoStyle(12, color: JaalColors.xerox)),
            ]),
            const SizedBox(height: JaalSpace.s4),
            GridView.count(
              crossAxisCount: 5,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 10,
              childAspectRatio: 1.15,
              children: [
                for (final (i, id) in Bodies.stickers.indexed)
                  _TrayTile(id: id, selected: id == current, tilt: (i % 3 - 1) * 0.03),
              ],
            ),
            const SizedBox(height: JaalSpace.s3),
            Row(children: [
              Text('drag-to-place + make your own: soon', style: monoStyle(11, color: JaalColors.xerox)),
              const Spacer(),
              if (current != null)
                ZineButton(
                  small: true,
                  color: JaalColors.paper,
                  label: 'peel mine off',
                  onPressed: () => Navigator.pop(context, '__peel'),
                ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _TrayTile extends StatelessWidget {
  const _TrayTile({required this.id, required this.selected, required this.tilt});
  final String id;
  final bool selected;
  final double tilt;

  @override
  Widget build(BuildContext context) {
    final s = StickerStyle.of(id);
    return Semantics(
      button: true,
      label: '$id sticker',
      child: GestureDetector(
        onTap: () => Navigator.pop(context, id),
        child: Transform.rotate(
          angle: tilt,
          child: Container(
            margin: const EdgeInsets.only(right: 3, bottom: 3),
            decoration: BoxDecoration(
              color: s.bg,
              border: Border.all(color: JaalColors.ink, width: selected ? 4 : 2.5),
              boxShadow: const [BoxShadow(color: JaalColors.ink, offset: Offset(4, 4))],
            ),
            alignment: Alignment.center,
            child: s.icon != null
                ? Icon(s.icon, color: s.fg, size: 26)
                : Text(id, style: displayStyle(17, color: s.fg).copyWith(letterSpacing: 0)),
          ),
        ),
      ),
    );
  }
}
