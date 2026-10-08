import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jaal_core/jaal_core.dart';

import '../../app/router.dart';
import '../../design/tokens.dart';
import '../../design/zine.dart';
import '../feed/post_card.dart';
import '../shared/people.dart';
import '../shared/providers.dart';
import '../shell/app_shell.dart';

/// Letters (design 11): every DM is a sealed envelope that may be travelling.
class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(inboxProvider).value ?? const [];
    final filters = <(String, bool Function(MessageRow))>[
      ('all', (_) => true),
      ('received', (m) => !m.outgoing),
      ('in transit', (m) => m.outgoing && !m.delivered),
      ('delivered', (m) => m.outgoing && m.delivered),
    ];
    final shown = all.where(filters[_filter].$2).toList();

    return Scaffold(
      appBar: const JaalTopBar(),
      body: Grain(
        child: ListView(padding: const EdgeInsets.all(JaalSpace.s4), children: [
          const InkLabel('secure store-and-forward · e2ee'),
          const SizedBox(height: 8),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Highlighted('letters', size: 48, color: JaalColors.pink),
                SizedBox(height: 6),
                HandNote('carried in pockets · zero cellular data ★', size: 20),
              ]),
            ),
            GestureDetector(
              onTap: () => _newLetter(context),
              child: ZineBox(
                padding: const EdgeInsets.all(12),
                child: Column(children: [
                  const Icon(Icons.mark_email_unread_outlined, size: 30),
                  Text('new\nletter', textAlign: TextAlign.center, style: monoStyle(11, bold: true)),
                ]),
              ),
            ),
          ]),
          const SizedBox(height: JaalSpace.s4),
          SizedBox(
            height: 44,
            child: ListView(scrollDirection: Axis.horizontal, children: [
              for (final (i, (l, f)) in filters.indexed)
                GestureDetector(
                  onTap: () => setState(() => _filter = i),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8, bottom: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _filter == i ? (i == 2 ? JaalColors.blue : JaalColors.ink) : Theme.of(context).scaffoldBackgroundColor,
                      border: Border.all(color: inkOf(context), width: 2.5),
                      boxShadow: [BoxShadow(color: inkOf(context), offset: JaalStroke.shadowSmall)],
                    ),
                    child: Text('$l (${all.where(f).length})',
                        style: monoStyle(12, bold: true, color: _filter == i ? JaalColors.paper : inkOf(context))),
                  ),
                ),
            ]),
          ),
          const SizedBox(height: JaalSpace.s4),
          if (shown.isEmpty)
            _EmptyMailbox(onNew: () => _newLetter(context))
          else
            for (final (i, m) in shown.indexed) _Envelope(m: m, index: i),
        ]),
      ),
    );
  }

  Future<void> _newLetter(BuildContext context) async {
    final profiles = ref.read(profilesProvider).value ?? const {};
    final me = ref.read(nodeProvider).rootId;
    final pick = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => ListView(padding: const EdgeInsets.all(16), children: [
        Text('seal a letter for…', style: displayStyle(24, color: inkOf(ctx))),
        const SizedBox(height: 8),
        Text('only people whose profile reached your phone (their key is in it)', style: monoStyle(11, color: JaalColors.xerox)),
        for (final p in profiles.values)
          if (p.rootId != me)
            ListTile(
              leading: Polaroid(root: p.rootId, size: 30, caption: false),
              title: Text('@${p.handle}·${fingerprintOf(p.rootId)}', style: monoStyle(13)),
              onTap: () => Navigator.pop(ctx, p.rootId),
            ),
      ]),
    );
    if (pick != null && context.mounted) context.push(Routes.chat(pick));
  }
}

class _Envelope extends ConsumerWidget {
  const _Envelope({required this.m, required this.index});
  final MessageRow m;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (stamp, color) = !m.outgoing
        ? ('new letter', JaalColors.pink)
        : m.delivered
            ? ('delivered ✓', JaalColors.stamp)
            : ('sealed · in transit', JaalColors.blue);
    return GestureDetector(
      onTap: () => context.push(Routes.chat(m.peerRoot)),
      child: Padding(
        padding: const EdgeInsets.only(bottom: JaalSpace.s4),
        child: ZineBox(
          tilt: (index.isEven ? -1 : 1) * 0.008,
          color: const Color(0xFFE9E3D3),
          padding: EdgeInsets.zero,
          child: Column(children: [
            CustomPaint(size: const Size(double.infinity, 16), painter: _Flap()),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Polaroid(root: m.peerRoot, size: 52),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    PersonLine(root: m.peerRoot),
                    const SizedBox(height: 4),
                    Text('${m.outgoing ? 'you: ' : ''}"${m.body}"',
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 4),
                    Text('ed25519 sealed · ${ago(m.sentAt)}', style: monoStyle(11, color: JaalColors.xerox)),
                  ]),
                ),
                Transform.rotate(
                  angle: -0.06,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(border: Border.all(color: color, width: 2)),
                    child: Text(stamp, style: monoStyle(10, color: color, bold: true)),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Flap extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = JaalColors.xerox
      ..strokeWidth = 2;
    for (var x = 0.0; x < s.width / 2; x += 12) {
      canvas.drawLine(Offset(x, x / (s.width / 2) * s.height), Offset(x + 6, (x + 6) / (s.width / 2) * s.height), p);
      canvas.drawLine(Offset(s.width - x, x / (s.width / 2) * s.height),
          Offset(s.width - x - 6, (x + 6) / (s.width / 2) * s.height), p);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _EmptyMailbox extends StatelessWidget {
  const _EmptyMailbox({required this.onNew});
  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) => ZineBox(
        padding: const EdgeInsets.all(JaalSpace.s5),
        child: Column(children: [
          const Icon(Icons.markunread_mailbox_outlined, size: 64),
          const SizedBox(height: 12),
          Text('no letters.', style: displayStyle(26, color: inkOf(context))),
          const Text('send one; it\'ll find a way.'),
          const SizedBox(height: 8),
          Text('when you pass other phones running jaal, encrypted envelopes jump silently across radios.',
              textAlign: TextAlign.center, style: monoStyle(11, color: JaalColors.xerox)),
          const SizedBox(height: 16),
          ZineButton(label: 'drop a letter ✎', onPressed: onNew),
          const SizedBox(height: 10),
          const HandNote('~ encrypted with recipient\'s public key only ~', size: 18),
        ]),
      );
}
