import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jaal_core/jaal_core.dart';

import '../../app/router.dart';
import '../../design/tokens.dart';
import '../../design/zine.dart';
import 'media.dart';
import 'providers.dart';

/// `@handle·fp` (or petname) for a root.
String handleOf(WidgetRef ref, String root) {
  final p = ref.watch(profileProvider(root));
  return '@${p?.handle ?? 'anon'}·${fingerprintOf(root)}';
}

String nameOf(WidgetRef ref, String root) {
  final pet = ref.watch(petnamesProvider).value?[root];
  if (pet != null) return pet;
  return ref.watch(profileProvider(root))?.name.toLowerCase() ?? 'someone';
}

MediaManifest? avatarOf(ProfileRow? p) {
  if (p?.avatar == null) return null;
  try {
    return MediaManifest.fromJson((CanonicalJson.decode(p!.avatar!)! as Map).cast());
  } on Object {
    return null;
  }
}

/// Polaroid avatar: square photo in an off-white frame with a thick bottom
/// lip, Caveat caption, lime dot when nearby (DESIGN.md "Polaroid Avatar").
class Polaroid extends ConsumerWidget {
  const Polaroid({
    super.key,
    required this.root,
    this.size = 56,
    this.caption = true,
    this.tilt = 0,
    this.onTap,
  });

  final String root;
  final double size;
  final bool caption;
  final double tilt;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(profileProvider(root));
    final nearby = ref.watch(nearbyRootsProvider).contains(root);
    final pad = size * 0.09;
    final lip = caption ? size * 0.38 : pad;
    final av = avatarOf(p);
    Widget photo = av != null
        ? JaalPhoto(manifest: av, fit: BoxFit.cover, compact: true)
        : _Initial(name: p?.name ?? '?', size: size, root: root);
    final frame = Container(
      padding: EdgeInsets.fromLTRB(pad, pad, pad, lip),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: JaalColors.ink, width: size > 80 ? JaalStroke.thick : 2),
        boxShadow: size > 80 ? const [BoxShadow(color: JaalColors.ink, offset: JaalStroke.shadow)] : null,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: DecoratedBox(
              decoration: BoxDecoration(border: Border.all(color: JaalColors.ink, width: 1.5)),
              child: ClipRect(child: photo),
            ),
          ),
          if (nearby)
            Positioned(
              right: -pad - 2,
              top: -pad - 2,
              child: Container(
                width: 12 + size * 0.06,
                height: 12 + size * 0.06,
                decoration: BoxDecoration(
                  color: JaalColors.acid,
                  shape: BoxShape.circle,
                  border: Border.all(color: JaalColors.ink, width: 2),
                ),
              ),
            ),
          if (caption)
            Positioned(
              left: 0,
              right: 0,
              bottom: -lip + 2,
              height: lip - 2,
              child: Center(
                child: Text(nameOf(ref, root),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: handStyle(size: (size * 0.26).clamp(12, 30))),
              ),
            ),
        ],
      ),
    );
    return GestureDetector(
      onTap: onTap ?? () => context.push(Routes.profile(root)),
      child: Transform.rotate(angle: tilt, child: frame),
    );
  }
}

class _Initial extends StatelessWidget {
  const _Initial({required this.name, required this.size, required this.root});
  final String name;
  final double size;
  final String root;

  @override
  Widget build(BuildContext context) {
    const colors = [JaalColors.ink, JaalColors.blue, JaalColors.pink, JaalColors.acid];
    final c = colors[root.codeUnitAt(3) % colors.length];
    final fg = c == JaalColors.acid ? JaalColors.ink : (c == JaalColors.ink ? JaalColors.acid : JaalColors.paper);
    return Container(
      color: c,
      alignment: Alignment.center,
      child: Text(name.isEmpty ? '?' : name.toLowerCase().substring(0, math.min(name.length, size > 70 ? 4 : 1)),
          style: displayStyle(size * (size > 70 ? 0.26 : 0.5), color: fg)),
    );
  }
}


/// Name + handle + safety badges in one line (post headers, lists).
class PersonLine extends ConsumerWidget {
  const PersonLine({super.key, required this.root, this.trailing, this.big = false});
  final String root;
  final Widget? trailing;
  final bool big;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mods = ref.watch(moderatorsProvider).value ?? const {};
    final verified = ref.watch(verifiedProvider).value?.contains(root) ?? false;
    final warn = ref.watch(lookalikesProvider(root)).value ?? const [];
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      runSpacing: 2,
      children: [
        Text(nameOf(ref, root), style: displayStyle(big ? JaalSize.h3 : 17, color: inkOf(context))),
        Text(handleOf(ref, root), style: monoStyle(JaalSize.micro, color: JaalColors.xerox)),
        if (mods.contains(root)) const ModBadge(),
        if (verified) const MetIrlStamp(),
        if (warn.isNotEmpty) const MonoChip('⚠ lookalike', color: JaalColors.stamp, textColor: JaalColors.paper),
        ?trailing,
      ],
    );
  }
}

class ModBadge extends StatelessWidget {
  const ModBadge({super.key, this.genesis = false});
  final bool genesis;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: JaalColors.blue,
          border: Border.all(color: JaalColors.ink, width: 2),
        ),
        child: Text(genesis ? '★ og mod' : '★ mod', style: monoStyle(10, color: JaalColors.paper, bold: true)),
      );
}

class MetIrlStamp extends StatelessWidget {
  const MetIrlStamp({super.key});

  @override
  Widget build(BuildContext context) => Transform.rotate(
        angle: -0.05,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
            color: JaalColors.acid.withValues(alpha: 0.5),
            border: Border.all(color: const Color(0xFF4E6700), width: 1.5),
          ),
          child: Text('met irl ✓', style: monoStyle(10, color: const Color(0xFF3A4D00), bold: true)),
        ),
      );
}
