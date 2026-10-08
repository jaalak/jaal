import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/session.dart';
import '../../design/tokens.dart';
import '../../design/zine.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(sessionProvider);
    return Scaffold(
      body: Grain(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Highlighted('jaal', size: JaalSize.mega),
              const SizedBox(height: JaalSpace.s4),
              if (s.hasError)
                Padding(
                  padding: const EdgeInsets.all(JaalSpace.s4),
                  child: Text('couldn\'t start your node:\n${s.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: JaalColors.stamp)),
                )
              else
                const HandNote('waking up your node…'),
            ],
          ),
        ),
      ),
    );
  }
}
