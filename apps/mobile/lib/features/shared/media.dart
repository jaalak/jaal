import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jaal_core/jaal_core.dart';

import '../../design/tokens.dart';
import '../../design/zine.dart';
import 'providers.dart';

/// Shows a photo by manifest. While chunks are still travelling it shows a
/// halftone placeholder with "chunks 3/9 · resuming" (designs 04/08/14).
class JaalPhoto extends ConsumerWidget {
  const JaalPhoto({super.key, required this.manifest, this.fit = BoxFit.cover, this.compact = false});

  final MediaManifest manifest;
  final BoxFit fit;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bytes = ref.watch(mediaBytesProvider(manifest.hash)).value;
    if (bytes != null) {
      return Image.memory(bytes, fit: fit, gaplessPlayback: true, filterQuality: FilterQuality.medium);
    }
    final p = ref.watch(mediaProgressProvider(manifest.hash)).value;
    final held = p?.held ?? 0, total = manifest.chunks.length;
    return Halftone(
      color: JaalColors.paperDeep,
      child: compact
          ? const SizedBox.expand()
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(JaalSpace.s4),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: JaalColors.ink,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text('chunks $held/$total · ${held == 0 ? 'waiting for a carrier' : 'resuming'}',
                          style: monoStyle(11, color: JaalColors.acid, bold: true)),
                      const SizedBox(height: 6),
                      ChunkBar(held: held, total: total),
                    ]),
                  ),
                  const SizedBox(height: 8),
                  Text('${(manifest.size / 1024).round()} kb · arrives as phones pass by',
                      style: monoStyle(10, color: JaalColors.xerox)),
                ]),
              ),
            ),
    );
  }
}

/// Segmented progress bar: lime = held, grey = missing.
class ChunkBar extends StatelessWidget {
  const ChunkBar({super.key, required this.held, required this.total, this.width = 200});
  final int held, total;
  final double width;

  @override
  Widget build(BuildContext context) {
    final n = total.clamp(1, 24);
    final filled = total == 0 ? n : (held / total * n).floor();
    return SizedBox(
      width: width,
      height: 12,
      child: Row(children: [
        for (var i = 0; i < n; i++)
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 2),
              color: i < filled ? JaalColors.acid : const Color(0xFF555555),
            ),
          ),
      ]),
    );
  }
}

/// Visual style of each built-in sticker (designs 04/05/06).
class StickerStyle {
  const StickerStyle(this.label, this.bg, this.fg, {this.icon});
  final String label;
  final Color bg, fg;
  final IconData? icon;

  static const _styles = {
    'heart': StickerStyle('', Color(0xFFFF3EA5), JaalColors.paper, icon: Icons.favorite_border),
    'fire': StickerStyle('fire!', Color(0xFFFF4A1C), JaalColors.paper),
    'lol': StickerStyle('lol', Color(0xFFFFD21F), JaalColors.ink),
    'real': StickerStyle('real', JaalColors.acid, JaalColors.ink),
    'slay': StickerStyle('slay', Color(0xFFFF1F4B), JaalColors.paper),
    'mid': StickerStyle('mid', Color(0xFF8A857A), JaalColors.paper),
    'cry': StickerStyle('cry', Color(0xFF2F7BFF), JaalColors.paper),
    'peak': StickerStyle('peak', JaalColors.acid, JaalColors.ink),
    'w': StickerStyle('w', JaalColors.blue, JaalColors.paper),
    'skull': StickerStyle('', Colors.white, JaalColors.ink, icon: Icons.sentiment_very_dissatisfied_outlined),
  };

  static StickerStyle of(String id) =>
      _styles[id] ?? StickerStyle(id, JaalColors.tape, JaalColors.ink);
}

/// A die-cut sticker: white bleed + ink border + colour pill.
class Sticker extends StatelessWidget {
  const Sticker(this.id, {super.key, this.scale = 1, this.rot = 0, this.square = false});
  final String id;
  final double scale;
  final double rot;
  final bool square;

  @override
  Widget build(BuildContext context) {
    final s = StickerStyle.of(id);
    return Transform.rotate(
      angle: rot * 3.14159 / 180,
      child: Container(
        padding: EdgeInsets.all(2.5 * scale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: square ? null : BorderRadius.circular(40),
          border: Border.all(color: JaalColors.ink, width: 2.5),
          boxShadow: [BoxShadow(color: JaalColors.ink, offset: Offset(3 * scale, 3 * scale))],
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 5 * scale),
          decoration: BoxDecoration(
            color: s.bg,
            borderRadius: square ? null : BorderRadius.circular(40),
          ),
          child: s.icon != null
              ? Icon(s.icon, color: s.fg, size: 20 * scale)
              : Text(s.label, style: displayStyle(15 * scale, color: s.fg).copyWith(fontStyle: FontStyle.italic, letterSpacing: 0)),
        ),
      ),
    );
  }
}
