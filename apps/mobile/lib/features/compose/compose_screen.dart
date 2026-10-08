import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jaal_core/jaal_core.dart';

import '../../design/tokens.dart';
import '../../design/zine.dart';
import '../shared/providers.dart';

/// New drop (design 07): one photo, crunched + chunked so it can travel
/// phone to phone, plus a caption.
class ComposeScreen extends ConsumerStatefulWidget {
  const ComposeScreen({super.key});

  @override
  ConsumerState<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends ConsumerState<ComposeScreen> {
  final _text = TextEditingController();
  Uint8List? _original;
  CompressedPhoto? _photo;
  bool _crunch = false;
  bool _xerox = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _text.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final f = await ImagePicker().pickImage(source: source, requestFullMetadata: false);
    if (f == null) return;
    _original = await f.readAsBytes();
    await _recompress();
  }

  Future<void> _recompress() async {
    final src = _original;
    if (src == null) return;
    setState(() => _busy = true);
    final crunch = _crunch, xerox = _xerox;
    try {
      final out = await Isolate.run(() => PhotoCompressor.compress(
            src,
            maxEdge: crunch ? 1080 : 1440,
            targetBytes: crunch ? 220 * 1024 : 450 * 1024,
            filter: xerox ? PhotoFilter.xerox : PhotoFilter.raw,
          ));
      if (mounted) setState(() => _photo = out);
    } on Object catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('couldn\'t read that photo: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _drop() async {
    final text = _text.text.trim();
    if (text.isEmpty && _photo == null) return;
    setState(() => _busy = true);
    try {
      final node = ref.read(nodeProvider);
      if (_photo != null) {
        await node.postPhotos(text, [_photo!]);
      } else {
        await node.post(text);
      }
      if (mounted) context.pop();
    } on Object catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ink = inkOf(context);
    final p = _photo;
    final chunks = p == null ? 0 : (p.bytes.length / defaultChunkSize).ceil();
    return Scaffold(
      body: Grain(
        child: SafeArea(
          child: Column(children: [
            Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: JaalSpace.s4),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: ink, width: JaalStroke.thick))),
              child: Row(children: [
                IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.close), tooltip: 'close'),
                const SizedBox(width: 8),
                Text('new drop', style: displayStyle(JaalSize.h2, color: ink)),
                const Spacer(),
                ZineButton(
                  label: _busy ? '…' : 'drop',
                  onPressed: _busy || (_text.text.trim().isEmpty && p == null) ? null : _drop,
                ),
              ]),
            ),
            Expanded(
              child: ListView(padding: const EdgeInsets.all(JaalSpace.s4), children: [
                _PhotoFrame(photo: p, busy: _busy, onPick: _pick),
                const SizedBox(height: JaalSpace.s4),
                Row(children: [
                  Expanded(
                    child: ZineButton(
                        small: true,
                        color: JaalColors.paper,
                        icon: Icons.photo_library_outlined,
                        label: 'gallery',
                        onPressed: () => _pick(ImageSource.gallery)),
                  ),
                  const SizedBox(width: JaalSpace.s2),
                  Expanded(
                    child: ZineButton(
                        small: true,
                        color: JaalColors.paper,
                        icon: Icons.photo_camera_outlined,
                        label: 'camera',
                        onPressed: () => _pick(ImageSource.camera)),
                  ),
                  if (p != null) ...[
                    const SizedBox(width: JaalSpace.s2),
                    ZineIconButton(
                        icon: Icons.delete_outline,
                        onPressed: () => setState(() {
                              _photo = null;
                              _original = null;
                            })),
                  ],
                ]),
                if (p != null) ...[
                  const SizedBox(height: JaalSpace.s5),
                  ZineBox(
                    padding: const EdgeInsets.all(JaalSpace.s3),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Container(width: 10, height: 10, decoration: const BoxDecoration(color: JaalColors.acid, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text('telemetry // packet chunking', style: monoStyle(12, bold: true)),
                      ]),
                      const SizedBox(height: 10),
                      Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 6, runSpacing: 6, children: [
                        Text('photo · ${_kb(p.originalBytes)} →', style: monoStyle(12)),
                        MonoChip(_kb(p.bytes.length), color: JaalColors.acid),
                        MonoChip('$chunks chunks', color: JaalColors.ink, textColor: JaalColors.paper),
                        Text('${p.width}×${p.height}', style: monoStyle(11, color: JaalColors.xerox)),
                      ]),
                      const SizedBox(height: 10),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _crunch,
                        onChanged: (v) {
                          setState(() => _crunch = v);
                          _recompress();
                        },
                        title: Text('crunch more (travels faster)', style: handStyle(size: 21)),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _xerox,
                        onChanged: (v) {
                          setState(() => _xerox = v);
                          _recompress();
                        },
                        title: Text('xerox it (b&w + toner grain)', style: handStyle(size: 21)),
                      ),
                      Wrap(spacing: 6, runSpacing: 6, children: [
                        for (var i = 0; i < chunks; i++)
                          Container(
                            width: 40,
                            height: 34,
                            decoration: BoxDecoration(
                              color: JaalColors.acid,
                              border: Border.all(color: JaalColors.ink, width: 2),
                            ),
                            alignment: Alignment.center,
                            child: Text('#${i + 1}', style: monoStyle(10, bold: true, color: JaalColors.ink)),
                          ),
                      ]),
                      const SizedBox(height: 6),
                      Text('cut into $chunks pocket-sized packets · each verified on arrival',
                          style: monoStyle(10, color: JaalColors.xerox)),
                    ]),
                  ),
                ],
                const SizedBox(height: JaalSpace.s5),
                Row(children: [
                  Text('// write dispatch', style: monoStyle(12, color: JaalColors.xerox)),
                  const Spacer(),
                  const HandNote('ink doesn\'t wash off', size: 19),
                ]),
                const SizedBox(height: JaalSpace.s2),
                TextField(
                  controller: _text,
                  minLines: 4,
                  maxLines: 8,
                  maxLength: Bodies.maxPostText,
                  decoration: const InputDecoration(hintText: 'say something offline… (lyrics, trail note, zine distro address)'),
                ),
                const SizedBox(height: JaalSpace.s4),
                ZineBox(
                  tilt: 0.01,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text('who gets it?', style: displayStyle(JaalSize.h3, color: ink)),
                      const SizedBox(width: 8),
                      Text('(mesh radius)', style: handStyle(color: JaalColors.pink, size: 20)),
                    ]),
                    const SizedBox(height: JaalSpace.s3),
                    _Choice(
                        on: true,
                        title: 'followers (travels through the mesh)',
                        sub: 'relays across passing phones over bluetooth & wi-fi direct'),
                    const SizedBox(height: JaalSpace.s2),
                    _Choice(on: false, title: 'close friends (sealed) — soon', sub: 'encrypted to their keys only'),
                    const SizedBox(height: JaalSpace.s3),
                    const HandNote('"it leaves your phone when someone walks by. could be 1 minute, could be 2 days."',
                        size: 19),
                  ]),
                ),
                const SizedBox(height: JaalSpace.s5),
                const Center(child: Postmark(hops: 0, top: '0 hops', bottom: 'not sent yet', size: 110)),
                const SizedBox(height: JaalSpace.s6),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  static String _kb(int b) => b > 1024 * 1024 ? '${(b / 1048576).toStringAsFixed(1)} mb' : '${(b / 1024).round()} kb';
}

class _PhotoFrame extends StatelessWidget {
  const _PhotoFrame({required this.photo, required this.busy, required this.onPick});
  final CompressedPhoto? photo;
  final bool busy;
  final Future<void> Function(ImageSource) onPick;

  @override
  Widget build(BuildContext context) => Stack(clipBehavior: Clip.none, children: [
        ZineBox(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 40),
          child: AspectRatio(
            aspectRatio: photo == null ? 1 : (photo!.width / photo!.height).clamp(0.6, 1.6),
            child: GestureDetector(
              onTap: photo == null ? () => onPick(ImageSource.gallery) : null,
              child: DecoratedBox(
                decoration: BoxDecoration(border: Border.all(color: JaalColors.ink, width: 2)),
                child: photo != null
                    ? Image.memory(photo!.bytes, fit: BoxFit.cover, gaplessPlayback: true)
                    : Halftone(
                        child: Center(
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.add_a_photo_outlined, size: 40, color: JaalColors.ink),
                            const SizedBox(height: 8),
                            Text(busy ? 'crunching…' : '+ add a frame', style: handStyle(size: 22)),
                          ]),
                        ),
                      ),
              ),
            ),
          ),
        ),
        const Positioned(left: 24, top: -10, child: TapeStrip(width: 70, angle: -0.05)),
        const Positioned(right: 30, top: -10, child: TapeStrip(width: 70, angle: 0.05)),
        if (photo != null)
          Positioned(
            left: 18,
            bottom: 14,
            child: MonoChip('⚡ ${(photo!.bytes.length / 1024).round()} kb ready', color: JaalColors.acid),
          ),
        if (busy)
          const Positioned.fill(child: Center(child: CircularProgressIndicator(color: JaalColors.ink))),
      ]);
}

class _Choice extends StatelessWidget {
  const _Choice({required this.on, required this.title, required this.sub});
  final bool on;
  final String title, sub;

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: on ? 1 : 0.5,
        child: Container(
          padding: const EdgeInsets.all(JaalSpace.s3),
          decoration: BoxDecoration(border: Border.all(color: inkOf(context), width: on ? 3 : 1.5)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: on ? JaalColors.acid : null,
                border: Border.all(color: inkOf(context), width: 3),
              ),
              child: on ? const Icon(Icons.check, size: 14, color: JaalColors.ink) : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Text(sub, style: Theme.of(context).textTheme.bodySmall),
              ]),
            ),
          ]),
        ),
      );
}
