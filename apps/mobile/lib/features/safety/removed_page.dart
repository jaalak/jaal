import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/tokens.dart';
import '../../design/zine.dart';
import '../shared/providers.dart';

/// Your own app after two moderators removed you (design 19.6b).
class RemovedPage extends ConsumerWidget {
  const RemovedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final node = ref.watch(nodeProvider);
    final reason = ref.watch(modStatusProvider).value?[node.rootId]?.reason ?? '';
    return ColoredBox(
      color: const Color(0xFFD9D6CE),
      child: Grain(
        opacity: 0.12,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(JaalSpace.s5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('you\'ve been\nremoved.', style: displayStyle(44, color: JaalColors.ink)),
                const SizedBox(height: JaalSpace.s4),
                Text(
                  '2 moderators removed this identity. you can\'t post, comment, stick or send letters, '
                  'and phones stop sharing the mesh with you.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: JaalColors.ink),
                ),
                const SizedBox(height: JaalSpace.s4),
                if (reason.isNotEmpty) MonoChip('reason: $reason', color: JaalColors.paper),
                const SizedBox(height: JaalSpace.s5),
                Text('moderators can retract their votes. the network keeps no other record of you.',
                    style: monoStyle(11, color: JaalColors.ink)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
