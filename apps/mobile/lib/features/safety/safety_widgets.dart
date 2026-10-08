import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jaal_core/jaal_core.dart';

import '../../design/tokens.dart';
import '../../design/zine.dart';
import '../shared/people.dart';
import '../shared/providers.dart';

/// Red hazard-tape lookalike warning + fingerprint comparison (design 19.1).
class LookalikeBanner extends ConsumerWidget {
  const LookalikeBanner({super.key, required this.warning});
  final LookalikeWarning warning;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HazardTape(red: true, child: Text('⚠ ${warning.message}')),
          const SizedBox(height: JaalSpace.s3),
          Row(children: [
            Expanded(child: _Tag(label: 'real', fp: longFingerprintOf(warning.lookalikeOf), ok: true)),
            const SizedBox(width: JaalSpace.s3),
            Expanded(child: _Tag(label: 'this one', fp: longFingerprintOf(warning.root), ok: false)),
          ]),
          const SizedBox(height: JaalSpace.s3),
          Row(children: [
            ZineButton(
              small: true,
              color: JaalColors.stamp,
              label: 'block',
              onPressed: () => ref.read(nodeProvider).block(warning.root),
            ),
            const SizedBox(width: JaalSpace.s2),
            Expanded(
              child: Text('nobody can post as someone else — impostors can only look similar.',
                  style: monoStyle(10, color: JaalColors.xerox)),
            ),
          ]),
        ],
      );
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.fp, required this.ok});
  final String label, fp;
  final bool ok;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: JaalColors.paper,
          border: Border.all(color: JaalColors.ink, width: 2),
        ),
        child: Row(children: [
          Container(width: 8, height: 8, decoration: const BoxDecoration(color: JaalColors.ink, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Expanded(
            child: Text('$label: ·$fp',
                style: monoStyle(12, bold: true, color: ok ? JaalColors.ink : JaalColors.stamp).copyWith(
                    decoration: ok ? null : TextDecoration.lineThrough, decorationColor: JaalColors.stamp)),
          ),
          Icon(ok ? Icons.check : Icons.close, size: 16, color: ok ? const Color(0xFF4E6700) : JaalColors.stamp),
        ]),
      );
}

/// Someone else's profile after removal: a torn flyer (design 19.6a).
class RemovedFlyer extends ConsumerWidget {
  const RemovedFlyer({super.key, required this.root, required this.reason});
  final String root;
  final String reason;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Center(
        child: Padding(
          padding: const EdgeInsets.all(JaalSpace.s5),
          child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
            Opacity(
              opacity: 0.45,
              child: ZineBox(
                tilt: -0.04,
                color: JaalColors.paperDeep,
                child: SizedBox(
                  width: 260,
                  height: 220,
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(handleOf(ref, root), style: monoStyle(14, bold: true)),
                    const SizedBox(height: 8),
                    Text('their posts no longer travel the mesh', style: monoStyle(11)),
                  ]),
                ),
              ),
            ),
            Transform.rotate(
              angle: -0.2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(border: Border.all(color: JaalColors.stamp, width: 4)),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('removed by moderators', style: monoStyle(16, color: JaalColors.stamp, bold: true)),
                  if (reason.isNotEmpty) Text('reason: $reason', style: monoStyle(11, color: JaalColors.stamp)),
                ]),
              ),
            ),
          ]),
        ),
      );
}
