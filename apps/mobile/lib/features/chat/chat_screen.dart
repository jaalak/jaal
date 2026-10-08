import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/tokens.dart';
import '../../design/zine.dart';
import '../shared/people.dart';
import '../shared/providers.dart';
import '../shell/app_shell.dart';

/// 1:1 chat (design 12): instant when nearby, letters carried by strangers
/// when not. Every message is a sealed envelope.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.peer});
  final String peer;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _text = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _text.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _seal() async {
    final t = _text.text.trim();
    if (t.isEmpty) return;
    try {
      await ref.read(nodeProvider).sendDm(widget.peer, t);
      _text.clear();
    } on Object catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  String _hm(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final msgs = ref.watch(conversationProvider(widget.peer)).value ?? const [];
    final nearby = ref.watch(nearbyRootsProvider).contains(widget.peer);
    final reachable = ref.watch(sessionsProvider).value?.length ?? 0;

    return Scaffold(
      appBar: ZineAppBar(
        title: handleOf(ref, widget.peer),
        subtitle: nearby ? '● nearby — instant' : '○ far — letters travel by people',
        actions: [Polaroid(root: widget.peer, size: 34, caption: false)],
      ),
      body: Halftone(
        color: Theme.of(context).scaffoldBackgroundColor,
        spacing: 14,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(JaalSpace.s3),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: JaalColors.tape.withValues(alpha: 0.85),
              child: Row(children: [
                const Icon(Icons.lock_outline, size: 18, color: JaalColors.ink),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('end-to-end sealed. carriers see an envelope, not you.',
                      style: monoStyle(11, color: JaalColors.ink, bold: true)),
                ),
              ]),
            ),
          ),
          Expanded(
            child: msgs.isEmpty
                ? const Center(child: HandNote('write the first letter ↓'))
                : ListView.builder(
                    controller: _scroll,
                    reverse: true,
                    padding: const EdgeInsets.all(JaalSpace.s4),
                    itemCount: msgs.length,
                    itemBuilder: (_, i) {
                      final m = msgs[msgs.length - 1 - i];
                      final transit = (m.receivedAt ?? m.sentAt) - m.sentAt;
                      return Align(
                        alignment: m.outgoing ? Alignment.centerRight : Alignment.centerLeft,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.8),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: JaalSpace.s4),
                            child: Column(
                              crossAxisAlignment: m.outgoing ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                if (!m.outgoing && transit > const Duration(hours: 1).inMilliseconds)
                                  HandNote('this one took ${_dur(transit)}. worth it.', size: 18),
                                ZineBox(
                                  tilt: m.outgoing ? 0.01 : -0.01,
                                  shadow: JaalStroke.shadowSmall,
                                  color: m.outgoing ? JaalColors.acid : JaalColors.paper,
                                  padding: const EdgeInsets.all(12),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(m.body,
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: JaalColors.ink)),
                                    const SizedBox(height: 8),
                                    Row(mainAxisSize: MainAxisSize.min, children: [
                                      Text(_hm(m.sentAt), style: monoStyle(11, color: JaalColors.xerox)),
                                      if (m.outgoing) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          color: JaalColors.paper,
                                          child: Text(
                                            m.delivered ? 'delivered ✓✓' : (nearby ? 'sealed ✉ · handing over' : 'sealed ✉ · waiting for a passerby'),
                                            style: monoStyle(10, color: JaalColors.ink, bold: true),
                                          ),
                                        ),
                                      ],
                                    ]),
                                  ]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(12, 10, 12, 10 + MediaQuery.paddingOf(context).bottom),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border(top: BorderSide(color: inkOf(context), width: JaalStroke.thick)),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _text,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(hintText: 'write a letter…'),
                  ),
                ),
                const SizedBox(width: 8),
                ZineButton(color: JaalColors.pink, icon: Icons.verified_outlined, label: 'seal', onPressed: _seal),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: reachable > 0 ? JaalColors.acid : JaalColors.xerox, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text('mesh radio: $reachable peer${reachable == 1 ? '' : 's'} reachable', style: monoStyle(10)),
                const Spacer(),
                Text('xchacha20-poly1305', style: monoStyle(10, color: JaalColors.xerox)),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  static String _dur(int ms) {
    final d = Duration(milliseconds: ms);
    if (d.inDays > 0) return '${d.inDays} day${d.inDays == 1 ? '' : 's'}';
    return '${d.inHours}h';
  }
}
