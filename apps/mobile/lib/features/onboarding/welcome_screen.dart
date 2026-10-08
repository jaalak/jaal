import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../design/tokens.dart';
import '../../design/zine.dart';

/// Placeholder layout in the zine system; the final design comes from
/// Google Stitch (docs/stitch/screens/01-welcome.md).
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Grain(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(JaalSpace.s5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                const TapeStrip(width: 90, label: 'v0.1 · offline'),
                const SizedBox(height: JaalSpace.s3),
                const Highlighted('jaal', size: 96),
                const SizedBox(height: JaalSpace.s3),
                Text('no wifi?\nno problem.',
                    style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: JaalSpace.s4),
                const HandNote('a social network that runs on people, not towers ↓'),
                const Spacer(),
                ZineButton(
                  label: 'make me a node',
                  icon: Icons.bolt,
                  expand: true,
                  onPressed: () => context.push(Routes.create),
                ),
                const SizedBox(height: JaalSpace.s3),
                ZineButton(
                  label: 'i have a recovery phrase',
                  color: Theme.of(context).colorScheme.surface,
                  expand: true,
                  onPressed: () => context.push(Routes.restore),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
