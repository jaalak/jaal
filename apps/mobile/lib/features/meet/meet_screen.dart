import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jaal_core/jaal_core.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../app/router.dart';
import '../../design/tokens.dart';
import '../../design/zine.dart';
import '../shared/people.dart';
import '../shared/providers.dart';
import '../shell/app_shell.dart';

/// Meet in person (design 09): show your signed QR, or scan theirs to
/// verify + follow. With [moderatorConsent] the scanner vouches for a
/// moderator candidate instead.
class MeetScreen extends ConsumerStatefulWidget {
  const MeetScreen({super.key, this.moderatorConsent = false});
  final bool moderatorConsent;

  @override
  ConsumerState<MeetScreen> createState() => _MeetScreenState();
}

class _MeetScreenState extends ConsumerState<MeetScreen> {
  late bool _scan = widget.moderatorConsent;
  MeetCode? _mine;
  MeetCode? _scanned;
  String? _error;
  bool _handling = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadMine());
  }

  Future<void> _loadMine() async {
    final c = await ref.read(nodeProvider).meetCode();
    if (mounted) setState(() => _mine = c);
  }

  Future<void> _handle(String raw) async {
    if (_handling || _scanned != null) return;
    _handling = true;
    final node = ref.read(nodeProvider);
    try {
      final MeetCode code;
      if (widget.moderatorConsent) {
        await node.vouchModerator(raw);
        code = MeetCode.decode(raw);
      } else {
        code = await node.verifyInPerson(raw);
      }
      if (mounted) {
        setState(() {
          _scanned = code;
          _error = null;
        });
      }
    } on Object catch (e) {
      if (mounted) setState(() => _error = '$e'.replaceFirst('FormatException: ', ''));
    } finally {
      _handling = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ink = inkOf(context);
    return Scaffold(
      appBar: ZineAppBar(
        title: widget.moderatorConsent ? 'vouch (scan)' : 'meet',
        subtitle: widget.moderatorConsent ? 'moderator // in person only' : 'swap identities in person',
      ),
      body: Grain(
        child: ListView(padding: const EdgeInsets.all(JaalSpace.s4), children: [
          if (!widget.moderatorConsent)
            Row(children: [
              for (final (i, l) in ['my code', 'scan'].indexed)
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _scan = i == 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: (_scan ? 1 : 0) == i ? JaalColors.acid : null,
                        border: Border.all(color: ink, width: JaalStroke.thick),
                      ),
                      child: Text(l, style: displayStyle(18, color: (_scan ? 1 : 0) == i ? JaalColors.ink : ink)),
                    ),
                  ),
                ),
            ]),
          const SizedBox(height: JaalSpace.s5),
          if (!_scan) _MyCode(code: _mine, onRefresh: _loadMine) else _scanner(),
          if (!widget.moderatorConsent) ...[
            const SizedBox(height: JaalSpace.s5),
            ZineButton(
              color: JaalColors.blue,
              icon: Icons.phonelink,
              label: 'link an iphone (same wi-fi)',
              expand: true,
              onPressed: () => context.push(Routes.link),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: JaalSpace.s4),
            HazardTape(red: true, child: Text(_error!)),
          ],
          if (_scanned != null) ...[
            const SizedBox(height: JaalSpace.s5),
            _Result(code: _scanned!, vouched: widget.moderatorConsent),
          ],
        ]),
      ),
    );
  }

  Widget _scanner() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        AspectRatio(
          aspectRatio: 1,
          child: Stack(fit: StackFit.expand, children: [
            Container(
              color: JaalColors.ink,
              child: MobileScanner(
                onDetect: (c) {
                  final v = c.barcodes.firstOrNull?.rawValue;
                  if (v != null && v.startsWith(MeetCode.prefix)) _handle(v);
                },
                errorBuilder: (context, error) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('camera unavailable — paste their code below',
                        textAlign: TextAlign.center, style: monoStyle(12, color: JaalColors.paper)),
                  ),
                ),
              ),
            ),
            const IgnorePointer(child: CustomPaint(painter: _CropMarks())),
          ]),
        ),
        const SizedBox(height: JaalSpace.s3),
        _PasteField(onSubmit: _handle),
        const SizedBox(height: JaalSpace.s3),
        HandNote(
            widget.moderatorConsent
                ? 'only vouch for people you\'ve met and trust.'
                : 'compare the 4 letters after the dot out loud. that\'s how you know it\'s them.',
            color: widget.moderatorConsent ? JaalColors.stamp : JaalColors.blue,
            size: 19),
      ]);
}

class _MyCode extends StatelessWidget {
  const _MyCode({required this.code, required this.onRefresh});
  final MeetCode? code;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final c = code;
    return Column(children: [
      Text('scan me', style: displayStyle(JaalSize.h1, color: inkOf(context))),
      const SizedBox(height: JaalSpace.s4),
      Stack(clipBehavior: Clip.none, children: [
        ZineBox(
          color: Colors.white,
          child: c == null
              ? const SizedBox(width: 240, height: 240)
              : QrImageView(data: c.encode(), size: 240, backgroundColor: Colors.white),
        ),
        const Positioned(left: 20, top: -10, child: TapeStrip(width: 64, angle: -0.1)),
        const Positioned(right: 26, top: -10, child: TapeStrip(width: 64, angle: 0.1)),
      ]),
      const SizedBox(height: JaalSpace.s4),
      if (c != null) ...[
        Text('@${c.handle}·${c.fingerprint}', style: monoStyle(16, bold: true)),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (final ch in c.fingerprint.split(''))
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 44,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: JaalColors.acid,
                border: Border.all(color: JaalColors.ink, width: 3),
                boxShadow: const [BoxShadow(color: JaalColors.ink, offset: JaalStroke.shadowSmall)],
              ),
              child: Text(ch, style: monoStyle(24, bold: true, color: JaalColors.ink)),
            ),
        ]),
        const SizedBox(height: 12),
        Text('full fingerprint: ${longFingerprintOf(c.root)}', style: monoStyle(12, bold: true)),
        const SizedBox(height: 8),
        const HandNote('read the full fingerprint out loud. they should see the same.', size: 19),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ZineButton(
            small: true,
            color: JaalColors.paper,
            icon: Icons.copy,
            label: 'copy code',
            onPressed: () => Clipboard.setData(ClipboardData(text: c.encode())),
          ),
          const SizedBox(width: 8),
          ZineButton(small: true, color: JaalColors.paper, icon: Icons.refresh, label: 'refresh', onPressed: onRefresh),
        ]),
        const SizedBox(height: 6),
        Text('codes expire after 10 minutes', style: monoStyle(10, color: JaalColors.xerox)),
      ],
    ]);
  }
}

class _PasteField extends StatefulWidget {
  const _PasteField({required this.onSubmit});
  final Future<void> Function(String) onSubmit;

  @override
  State<_PasteField> createState() => _PasteFieldState();
}

class _PasteFieldState extends State<_PasteField> {
  final _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(
          child: TextField(
            controller: _c,
            style: monoStyle(12),
            decoration: const InputDecoration(hintText: 'or paste a jaal:1: code'),
          ),
        ),
        const SizedBox(width: 8),
        ZineIconButton(
          icon: Icons.content_paste_go,
          color: JaalColors.acid,
          tooltip: 'use code',
          onPressed: () async {
            if (_c.text.trim().isEmpty) {
              final clip = await Clipboard.getData(Clipboard.kTextPlain);
              _c.text = clip?.text ?? '';
            }
            await widget.onSubmit(_c.text.trim());
          },
        ),
      ]);
}

class _Result extends ConsumerWidget {
  const _Result({required this.code, required this.vouched});
  final MeetCode code;
  final bool vouched;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final node = ref.read(nodeProvider);
    final votes = node.moderation.vouchesFor(code.root).length;
    return ZineBox(
      tilt: 0.02,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Polaroid(root: code.root, size: 60),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('@${code.handle}·${code.fingerprint}', style: monoStyle(14, bold: true)),
              Text(longFingerprintOf(code.root), style: monoStyle(11, color: JaalColors.xerox)),
              const SizedBox(height: 6),
              Text(vouched ? '★ vouched · $votes/3' : 'met irl ✓ · following',
                  style: monoStyle(12, color: vouched ? JaalColors.blue : const Color(0xFF4E6700), bold: true)),
            ]),
          ),
        ]),
        const SizedBox(height: 12),
        Text(
          vouched
              ? 'your signed vouch spreads to every phone. at 3 vouches they become a moderator.'
              : 'their posts now reach you through anyone in between. their profile arrives when you\'re in range.',
          style: monoStyle(11),
        ),
        const SizedBox(height: 12),
        ZineButton(
          small: true,
          label: 'see their profile',
          onPressed: () => context.pushReplacement(Routes.profile(code.root)),
        ),
      ]),
    );
  }
}

/// Thick zine crop marks over the camera viewfinder.
class _CropMarks extends CustomPainter {
  const _CropMarks();

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = JaalColors.acid
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;
    const l = 36.0, m = 20.0;
    for (final (x, y, dx, dy) in [
      (m, m, 1.0, 1.0),
      (s.width - m, m, -1.0, 1.0),
      (m, s.height - m, 1.0, -1.0),
      (s.width - m, s.height - m, -1.0, -1.0),
    ]) {
      canvas.drawLine(Offset(x, y), Offset(x + dx * l, y), p);
      canvas.drawLine(Offset(x, y), Offset(x, y + dy * l), p);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
