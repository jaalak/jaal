import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import '../../app/session.dart';
import '../../design/tokens.dart';

/// Live log of lab events and sync-engine records, newest first.
class WireTab extends ConsumerStatefulWidget {
  const WireTab({super.key});

  @override
  ConsumerState<WireTab> createState() => _WireTabState();
}

class _WireTabState extends ConsumerState<WireTab> {
  bool _syncLogs = true;

  @override
  Widget build(BuildContext context) {
    ref.watch(labTickProvider);
    final lab = ref.watch(requireSessionProvider).lab;
    final logs = ref.watch(logBufferProvider);

    return Column(
      children: [
        SwitchListTile(
          value: _syncLogs,
          onChanged: (v) => setState(() => _syncLogs = v),
          title: const Text('include sync engine logs'),
        ),
        const Divider(height: 1),
        Expanded(
          child: StreamBuilder<LogRecord>(
            stream: logs.stream,
            builder: (context, _) {
              final lines = <(DateTime, String, Color)>[
                for (final e in lab.history)
                  (e.at, '[${e.kind}] ${e.message}', _kindColor(e.kind)),
                if (_syncLogs)
                  for (final r in logs.records)
                    (r.time, '${r.loggerName.replaceFirst('jaal.', '')}: ${r.message}',
                        r.level >= Level.WARNING ? JaalColors.stamp : JaalColors.xerox),
              ]..sort((a, b) => b.$1.compareTo(a.$1));
              return ListView.builder(
                padding: const EdgeInsets.all(JaalSpace.s3),
                itemCount: lines.length.clamp(0, 400),
                itemBuilder: (_, i) {
                  final (t, s, c) = lines[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      '${t.toIso8601String().substring(11, 19)} $s',
                      style: TextStyle(fontFamily: JaalFonts.mono, fontSize: JaalSize.micro, color: c),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Color _kindColor(String kind) => switch (kind) {
        'post' => JaalColors.blue,
        'dm' => JaalColors.pink,
        'link' => Theme.of(context).colorScheme.onSurface,
        'react' => JaalColors.pink,
        _ => JaalColors.xerox,
      };
}
