import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jaal_core/jaal_core.dart';

import '../../design/tokens.dart';
import '../../design/zine.dart';
import '../shared/media.dart';
import '../shared/people.dart';
import '../shared/providers.dart';
import '../shell/app_shell.dart';

/// Nearby (design 10): corkboard of everyone in range + a live tap of what
/// you're swapping with them.
class NearbyScreen extends ConsumerStatefulWidget {
  const NearbyScreen({super.key});

  @override
  ConsumerState<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends ConsumerState<NearbyScreen> {
  bool _list = false;

  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(sessionsProvider).value ?? const [];
    final visible = ref.watch(nodeProvider).engine.visiblePeers.length;
    final ink = inkOf(context);
    return Scaffold(
      appBar: const JaalTopBar(),
      body: Grain(
        child: ListView(padding: const EdgeInsets.all(JaalSpace.s4), children: [
          Row(children: [
            const Highlighted('nearby', size: 44),
            const Spacer(),
            for (final (i, l) in ['corkboard', 'peer list (${sessions.length})'].indexed)
              GestureDetector(
                onTap: () => setState(() => _list = i == 1),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: (_list ? 1 : 0) == i ? JaalColors.acid : null,
                    border: Border.all(color: ink, width: 2),
                  ),
                  child: Text(l, style: monoStyle(11, color: (_list ? 1 : 0) == i ? JaalColors.ink : ink)),
                ),
              ),
          ]),
          const SizedBox(height: JaalSpace.s3),
          TapeStrip(
            width: 340,
            angle: 0,
            label: '● $visible in range · ${sessions.length} syncing · simulated radio (network lab)',
          ),
          const SizedBox(height: JaalSpace.s4),
          if (_list)
            for (final s in sessions)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Polaroid(root: s.peerRoot!, size: 40, caption: false),
                title: Text(handleOf(ref, s.peerRoot!), style: monoStyle(13, bold: true)),
                subtitle: Text('↓${s.stats.eventsIn} ↑${s.stats.eventsOut} · chunks ↓${s.stats.chunksIn}',
                    style: monoStyle(11, color: JaalColors.xerox)),
              )
          else
            _Corkboard(roots: [for (final s in sessions) ?s.peerRoot]),
          const SizedBox(height: JaalSpace.s5),
          if (sessions.isNotEmpty) _LiveTap(session: sessions.first),
          const SizedBox(height: JaalSpace.s4),
          ZineBox(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('be discoverable: on', style: displayStyle(18, color: ink)),
                  const SizedBox(height: 4),
                  Text('real radios will advertise a rotating id, never your name', style: monoStyle(11)),
                ]),
              ),
              const Switch(value: true, onChanged: null),
            ]),
          ),
          const SizedBox(height: JaalSpace.s6),
        ]),
      ),
    );
  }
}

class _Corkboard extends StatelessWidget {
  const _Corkboard({required this.roots});
  final List<String> roots;

  @override
  Widget build(BuildContext context) => Container(
        height: 420,
        decoration: BoxDecoration(
          border: Border.all(color: JaalColors.ink, width: JaalStroke.thick),
          boxShadow: const [BoxShadow(color: JaalColors.ink, offset: JaalStroke.shadow)],
        ),
        margin: const EdgeInsets.only(right: 6, bottom: 6),
        child: Halftone(
          color: const Color(0xFFDDD3B8),
          child: LayoutBuilder(builder: (context, c) {
            final center = Offset(c.maxWidth / 2, c.maxHeight / 2);
            final spots = <Offset>[
              for (var i = 0; i < roots.length; i++)
                center +
                    Offset(cos(i * 2 * pi / max(roots.length, 1) - pi / 2),
                            sin(i * 2 * pi / max(roots.length, 1) - pi / 2)) *
                        (min(c.maxWidth, c.maxHeight) * 0.34),
            ];
            return Stack(children: [
              Positioned.fill(child: CustomPaint(painter: _Strings(center, spots))),
              Positioned(
                left: center.dx - 40,
                top: center.dy - 52,
                child: Container(
                  width: 80,
                  height: 96,
                  decoration: BoxDecoration(
                    color: JaalColors.acid,
                    border: Border.all(color: JaalColors.ink, width: 3),
                  ),
                  alignment: Alignment.center,
                  child: Text('you', style: displayStyle(26, color: JaalColors.ink)),
                ),
              ),
              for (final (i, r) in roots.indexed)
                Positioned(
                  left: spots[i].dx - 42,
                  top: spots[i].dy - 56,
                  child: Polaroid(root: r, size: 66, tilt: (i.isEven ? -1 : 1) * 0.06),
                ),
              if (roots.isEmpty)
                const Positioned(
                  left: 16,
                  right: 16,
                  bottom: 24,
                  child: HandNote('nobody around. go touch grass (and people).', size: 20),
                ),
              const Positioned(
                right: 12,
                top: 12,
                child: TapeStrip(width: 110, angle: 0.08, label: 'carrier mesh'),
              ),
            ]);
          }),
        ),
      );
}

class _Strings extends CustomPainter {
  _Strings(this.c, this.spots);
  final Offset c;
  final List<Offset> spots;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = JaalColors.blue
      ..strokeWidth = 2;
    for (final s in spots) {
      canvas.drawLine(c, s, p);
    }
  }

  @override
  bool shouldRepaint(_Strings old) => old.spots.length != spots.length;
}

class _LiveTap extends ConsumerWidget {
  const _LiveTap({required this.session});
  final SyncSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = session.stats;
    final total = s.eventsIn + s.eventsOut + s.chunksIn + s.chunksOut + s.envelopesIn + s.envelopesOut;
    return Stack(clipBehavior: Clip.none, children: [
      ZineBox(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('active relay', style: monoStyle(12, color: JaalColors.pink, bold: true)),
            const SizedBox(width: 6),
            Container(width: 10, height: 10, decoration: const BoxDecoration(color: JaalColors.acid, shape: BoxShape.circle)),
            const Spacer(),
            MonoChip('${(s.bytesIn + s.bytesOut) ~/ 1024} kb', color: JaalColors.acid),
          ]),
          const SizedBox(height: 8),
          Text('swapping with ${nameOf(ref, session.peerRoot!)}', style: displayStyle(28, color: inkOf(context))),
          const SizedBox(height: 12),
          ChunkBar(held: total == 0 ? 0 : 1, total: 1, width: 300),
          const SizedBox(height: 12),
          _row(Icons.south, 'posts & events ↓ ${s.eventsIn}  ↑ ${s.eventsOut}', 'signed ✓'),
          _row(Icons.image_outlined, 'photo chunks ↓ ${s.chunksIn}  ↑ ${s.chunksOut}', 'verified'),
          _row(Icons.mail_outline, 'sealed letters ↓ ${s.envelopesIn}  ↑ ${s.envelopesOut}', 'in transit'),
          _row(Icons.verified_outlined, 'receipts ↓ ${s.acksIn}', 'anonymous'),
        ]),
      ),
      const Positioned(top: -12, left: 120, child: TapeStrip(width: 110, angle: 0, label: '=== live tap ===')),
    ]);
  }

  Widget _row(IconData i, String a, String b) => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(children: [
          Icon(i, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(a, style: monoStyle(12))),
          Text(b, style: monoStyle(11, bold: true)),
        ]),
      );
}
