import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/tokens.dart';
import '../../design/zine.dart';
import '../feed/post_card.dart';
import '../shared/providers.dart';
import '../shell/app_shell.dart';

/// Carry pouch (design 13): sealed letters you carry for strangers, and the
/// courier clout you earn when they're delivered.
class PouchScreen extends ConsumerWidget {
  const PouchScreen({super.key});

  static const _budget = 20 * 1024 * 1024;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pouch = ref.watch(carryPouchProvider).value ?? const [];
    final clout = ref.watch(courierCloutProvider).value ?? 0;
    final deliveries = ref.watch(deliveriesProvider).value ?? const [];
    final used = pouch.fold<int>(0, (a, e) => a + e.size);
    final now = DateTime.now().millisecondsSinceEpoch;
    final cells = (used / _budget * 20).ceil().clamp(pouch.isEmpty ? 0 : 1, 20);

    return Scaffold(
      appBar: const ZineAppBar(title: 'carry pouch', subtitle: 'jaal // mesh pocket'),
      body: Grain(
        child: ListView(padding: const EdgeInsets.all(JaalSpace.s4), children: [
          const Highlighted('carry pouch', size: 40, color: JaalColors.blue),
          const SizedBox(height: 8),
          Text('sealed stranger packets in transit // zero cloud', style: monoStyle(11, bold: true)),
          const SizedBox(height: JaalSpace.s3),
          ZineBox(
            shadow: JaalStroke.shadowSmall,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('your phone carries encrypted envelopes for passersby. you cannot read them, sender is hidden, recipient is hidden.'),
              const SizedBox(height: 6),
              const HandNote('★ zero liability by design! →', size: 20),
            ]),
          ),
          const SizedBox(height: JaalSpace.s5),
          Row(children: [
            Expanded(
              child: ZineBox(
                color: JaalColors.pink,
                child: Column(children: [
                  Text('$clout', style: displayStyle(56, color: JaalColors.paper)),
                  Text('deliveries', style: monoStyle(11, color: JaalColors.paper, bold: true)),
                  const SizedBox(height: 6),
                  Text('mesh carrier badge', style: monoStyle(10, color: JaalColors.paper)),
                ]),
              ),
            ),
            const SizedBox(width: JaalSpace.s3),
            Expanded(
              child: ZineBox(
                color: const Color(0xFF1C1C3A),
                child: Column(children: [
                  Text(clout >= 25 ? 'owl' : clout >= 5 ? 'fox' : 'sprout',
                      style: displayStyle(36, color: JaalColors.tape)),
                  Text('rank', style: monoStyle(11, color: JaalColors.paper, bold: true)),
                  const SizedBox(height: 6),
                  Text('${pouch.length} carried now', style: monoStyle(10, color: JaalColors.paper)),
                ]),
              ),
            ),
          ]),
          const SizedBox(height: JaalSpace.s5),
          Row(children: [
            Text('bag payload', style: displayStyle(22, color: inkOf(context))),
            const Spacer(),
            MonoChip('${pouch.length} envelopes carried', color: JaalColors.acid),
          ]),
          const SizedBox(height: JaalSpace.s3),
          Container(
            padding: const EdgeInsets.all(JaalSpace.s3),
            decoration: BoxDecoration(
              color: const Color(0xFFC9A877),
              border: Border.all(color: JaalColors.ink, width: JaalStroke.thick),
              boxShadow: const [BoxShadow(color: JaalColors.ink, offset: JaalStroke.shadow)],
            ),
            child: Column(children: [
              if (pouch.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('empty pouch. walk around — phones hand you mail for strangers.',
                      textAlign: TextAlign.center, style: monoStyle(12, color: JaalColors.ink)),
                ),
              for (final e in pouch)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: JaalColors.paper,
                    border: Border.all(color: JaalColors.ink, width: 2.5),
                    boxShadow: const [BoxShadow(color: JaalColors.ink, offset: JaalStroke.shadowSmall)],
                  ),
                  child: Row(children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: JaalColors.pink,
                        shape: BoxShape.circle,
                        border: Border.all(color: JaalColors.ink, width: 2),
                      ),
                      child: const Icon(Icons.lock_outline, color: JaalColors.paper, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('#${e.id.substring(0, 4)}  ${(e.size / 1024).toStringAsFixed(1)} kb · ${e.hops} hops',
                            style: monoStyle(12, color: JaalColors.ink, bold: true)),
                        Text('to: ? [hint: ${e.hint}] // from: ?', style: monoStyle(10, color: JaalColors.xerox)),
                      ]),
                    ),
                    MonoChip('${((e.exp - now) / 86400000).floor()}d left', color: JaalColors.acid),
                  ]),
                ),
            ]),
          ),
          const SizedBox(height: JaalSpace.s5),
          ZineBox(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('pouch storage quota', style: monoStyle(12, bold: true)),
              const SizedBox(height: 10),
              Wrap(spacing: 4, runSpacing: 4, children: [
                for (var i = 0; i < 20; i++)
                  Container(
                    width: 26,
                    height: 22,
                    decoration: BoxDecoration(
                      color: i < cells ? JaalColors.blue : null,
                      border: Border.all(color: inkOf(context), width: 2),
                    ),
                  ),
              ]),
              const SizedBox(height: 10),
              Text('using ${(used / 1048576).toStringAsFixed(2)} / 20 mb for strangers (${pouch.length} envelopes)',
                  style: monoStyle(12, bold: true)),
              Text('auto-evicts oldest · expires after 14 days', style: monoStyle(10, color: JaalColors.xerox)),
            ]),
          ),
          const SizedBox(height: JaalSpace.s5),
          Text('zine field guide', style: displayStyle(22, color: inkOf(context))),
          const SizedBox(height: JaalSpace.s3),
          Row(children: [
            for (final (t, i, d) in [
              ('1. seals a letter', Icons.mail_lock_outlined, 'encrypted to the recipient\'s key'),
              ('2. phone carries', Icons.directions_walk, 'can\'t read it. zero servers'),
              ('3. clout +1', Icons.military_tech_outlined, 'receipt proves delivery'),
            ])
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.all(8),
                  height: 150,
                  decoration: BoxDecoration(border: Border.all(color: inkOf(context), width: 2)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(t, style: monoStyle(11, bold: true)),
                    const Spacer(),
                    Center(child: Icon(i, color: JaalColors.pink, size: 30)),
                    const Spacer(),
                    Text(d, style: monoStyle(9, color: JaalColors.xerox)),
                  ]),
                ),
              ),
          ]),
          const SizedBox(height: JaalSpace.s5),
          Row(children: [
            Text('recent courier deliveries', style: displayStyle(20, color: inkOf(context))),
            const Spacer(),
            MonoChip('${deliveries.length}', color: JaalColors.acid),
          ]),
          const SizedBox(height: JaalSpace.s3),
          if (deliveries.isEmpty)
            const HandNote('none yet. carry one and it counts when it lands.', color: JaalColors.xerox, size: 19),
          for (final d in deliveries)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ZineBox(
                shadow: JaalStroke.shadowSmall,
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('letter #${d.id.substring(0, 4)} · ${ago(d.receivedAt)}', style: monoStyle(12, bold: true)),
                      Text('you were hop ${d.hops}. +1 courier clout ⚡', style: monoStyle(11, color: JaalColors.xerox)),
                    ]),
                  ),
                  Transform.rotate(
                    angle: -0.08,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(border: Border.all(color: const Color(0xFF4E6700), width: 2)),
                      child: Text('delivered ✓', style: monoStyle(10, color: const Color(0xFF4E6700), bold: true)),
                    ),
                  ),
                ]),
              ),
            ),
          const SizedBox(height: JaalSpace.s6),
        ]),
      ),
    );
  }
}
