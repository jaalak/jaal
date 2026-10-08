import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../design/tokens.dart';
import '../../design/zine.dart';
import '../../transport/webrtc_link.dart';
import '../shared/providers.dart';
import '../shell/app_shell.dart';

/// Link with an iPhone (web app) or another phone over WebRTC on the same
/// Wi-Fi / hotspot by swapping two QR codes. No internet needed.
class ConnectIphoneScreen extends ConsumerStatefulWidget {
  const ConnectIphoneScreen({super.key});

  @override
  ConsumerState<ConnectIphoneScreen> createState() => _State();
}

enum _Step { start, showOffer, scanAnswer, scanOffer, showAnswer, linked }

class _State extends ConsumerState<ConnectIphoneScreen> {
  _Step _step = _Step.start;
  RtcOffer? _offer;
  String? _answerCode;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    if (_step != _Step.linked) unawaited(_offer?.cancel());
    super.dispose();
  }

  Future<void> _run(Future<void> Function() f) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await f();
    } on Object catch (e) {
      if (mounted) setState(() => _error = '$e'.replaceFirst('FormatException: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _adopt(dynamic conn) {
    ref.read(nodeProvider).engine.adopt(conn);
    if (mounted) setState(() => _step = _Step.linked);
  }

  Future<void> _onScanned(String code) async {
    if (_busy) return;
    if (_step == _Step.scanAnswer) {
      await _run(() async => _adopt(await _offer!.accept(code)));
    } else if (_step == _Step.scanOffer) {
      await _run(() async {
        final a = await JaalRtc.answer(code);
        setState(() {
          _answerCode = a.code;
          _step = _Step.showAnswer;
        });
        _adopt(await a.connection.timeout(const Duration(minutes: 3)));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ZineAppBar(title: 'link a phone', subtitle: 'webrtc // same wi-fi or hotspot'),
      body: Grain(
        child: ListView(padding: const EdgeInsets.all(JaalSpace.s4), children: [
          if (_error != null) ...[HazardTape(red: true, child: Text(_error!)), const SizedBox(height: JaalSpace.s4)],
          ...switch (_step) {
            _Step.start => _start(),
            _Step.showOffer => _qr('1. let them scan this', _offer?.code, next: 'they show a reply code → scan it',
                onNext: () => setState(() => _step = _Step.scanAnswer)),
            _Step.scanAnswer => _scanner('2. scan their reply code'),
            _Step.scanOffer => _scanner('scan the code on their screen'),
            _Step.showAnswer => _qr('now let them scan this', _answerCode, next: 'waiting for them to connect…'),
            _Step.linked => _linked(),
          },
        ]),
      ),
    );
  }

  List<Widget> _start() => [
        const Highlighted('link an iphone.', size: JaalSize.h1),
        const SizedBox(height: JaalSpace.s3),
        const Text('both phones on the same wi-fi — or the iphone joins your hotspot. no internet needed.'),
        const SizedBox(height: JaalSpace.s5),
        ZineButton(
          icon: Icons.qr_code_2,
          label: _busy ? 'preparing…' : 'show my code first',
          expand: true,
          onPressed: _busy
              ? null
              : () => _run(() async {
                    _offer = await JaalRtc.createOffer();
                    setState(() => _step = _Step.showOffer);
                  }),
        ),
        const SizedBox(height: JaalSpace.s3),
        ZineButton(
          color: JaalColors.paper,
          icon: Icons.qr_code_scanner,
          label: 'scan their code first',
          expand: true,
          onPressed: () => setState(() => _step = _Step.scanOffer),
        ),
        const SizedBox(height: JaalSpace.s4),
        const HandNote('on the iphone: open jaal → meet → link a phone.', size: 19),
      ];

  List<Widget> _qr(String title, String? code, {required String next, VoidCallback? onNext}) => [
        Text(title, style: displayStyle(JaalSize.h2, color: inkOf(context))),
        const SizedBox(height: JaalSpace.s4),
        Center(
          child: ZineBox(
            color: Colors.white,
            child: code == null
                ? const SizedBox(width: 280, height: 280)
                : QrImageView(data: code, size: 280, backgroundColor: Colors.white),
          ),
        ),
        const SizedBox(height: JaalSpace.s3),
        if (code != null)
          Center(
            child: TextButton.icon(
              onPressed: () => Clipboard.setData(ClipboardData(text: code)),
              icon: const Icon(Icons.copy, size: 16),
              label: Text('copy code', style: monoStyle(12)),
            ),
          ),
        const SizedBox(height: JaalSpace.s3),
        if (onNext != null)
          ZineButton(icon: Icons.qr_code_scanner, label: next, expand: true, onPressed: onNext)
        else
          Center(child: HandNote(next, size: 19)),
      ];

  List<Widget> _scanner(String title) => [
        Text(title, style: displayStyle(JaalSize.h2, color: inkOf(context))),
        const SizedBox(height: JaalSpace.s4),
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            color: JaalColors.ink,
            child: MobileScanner(
              onDetect: (c) {
                final v = c.barcodes.firstOrNull?.rawValue;
                if (v != null && v.startsWith('jaal:rtc:')) _onScanned(v);
              },
              errorBuilder: (_, _) => Center(
                child: Text('camera unavailable — paste the code below', style: monoStyle(12, color: JaalColors.paper)),
              ),
            ),
          ),
        ),
        const SizedBox(height: JaalSpace.s3),
        _Paste(onSubmit: _onScanned),
        if (_busy) const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
      ];

  List<Widget> _linked() => [
        const Highlighted('linked ✓', size: JaalSize.h1),
        const SizedBox(height: JaalSpace.s3),
        const Text('you\'re swapping posts, photos and sealed letters directly. keep both apps open until it settles.'),
        const SizedBox(height: JaalSpace.s5),
        ZineButton(label: 'done', expand: true, onPressed: () => Navigator.of(context).maybePop()),
      ];
}

class _Paste extends StatefulWidget {
  const _Paste({required this.onSubmit});
  final Future<void> Function(String) onSubmit;

  @override
  State<_Paste> createState() => _PasteState();
}

class _PasteState extends State<_Paste> {
  final _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(child: TextField(controller: _c, style: monoStyle(11), decoration: const InputDecoration(hintText: 'or paste a jaal:rtc: code'))),
        const SizedBox(width: 8),
        ZineIconButton(
          icon: Icons.content_paste_go,
          color: JaalColors.acid,
          onPressed: () async {
            if (_c.text.trim().isEmpty) _c.text = (await Clipboard.getData(Clipboard.kTextPlain))?.text ?? '';
            await widget.onSubmit(_c.text.trim());
          },
        ),
      ]);
}
