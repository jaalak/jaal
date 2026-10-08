import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/links.dart';
import '../../design/tokens.dart';
import '../../design/zine.dart';
import '../shell/app_shell.dart';

const _channel = MethodChannel('jaal/app');

/// "Pass it on": give Jaal to Android friends as an installer (offline:
/// Quick Share, Bluetooth, any app), or point iPhones at the web app.
class ShareScreen extends StatefulWidget {
  const ShareScreen({super.key});

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  bool _iphone = false;
  bool _busy = false;

  Future<void> _shareApk() async {
    setState(() => _busy = true);
    try {
      final src = await _channel.invokeMethod<String>('apkPath');
      if (src == null) throw StateError('installer not found');
      final dir = await getTemporaryDirectory();
      final out = File(p.join(dir.path, 'jaal.apk'));
      await File(src).copy(out.path);
      await SharePlus.instance.share(ShareParams(
        files: [XFile(out.path, mimeType: 'application/vnd.android.package-archive', name: 'jaal.apk')],
        text: 'jaal — social without towers. install this, then we can swap posts offline.',
      ));
    } on Object catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('couldn\'t share: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ink = inkOf(context);
    return Scaffold(
      appBar: const ZineAppBar(title: 'pass it on', subtitle: 'share jaal // no store needed'),
      body: Grain(
        child: ListView(padding: const EdgeInsets.all(JaalSpace.s4), children: [
          const Highlighted('spread the net.', size: JaalSize.h1),
          const SizedBox(height: JaalSpace.s3),
          const HandNote('jaal travels like a zine: hand to hand.', size: 20),
          const SizedBox(height: JaalSpace.s5),
          Row(children: [
            for (final (i, l) in ['android', 'iphone'].indexed)
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _iphone = i == 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: (_iphone ? 1 : 0) == i ? JaalColors.acid : null,
                      border: Border.all(color: ink, width: JaalStroke.thick),
                    ),
                    child: Text(l, style: displayStyle(18, color: (_iphone ? 1 : 0) == i ? JaalColors.ink : ink)),
                  ),
                ),
              ),
          ]),
          const SizedBox(height: JaalSpace.s5),
          if (!_iphone) ..._android() else ..._ios(),
        ]),
      ),
    );
  }

  List<Widget> _android() => [
        ZineBox(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('send the installer', style: displayStyle(22, color: inkOf(context))),
            const SizedBox(height: 8),
            const Text('works offline over quick share or bluetooth — or any app if you have signal.'),
            const SizedBox(height: JaalSpace.s4),
            ZineButton(
              icon: Icons.ios_share,
              label: _busy ? 'packing…' : 'share jaal.apk',
              expand: true,
              onPressed: _busy ? null : _shareApk,
            ),
          ]),
        ),
        const SizedBox(height: JaalSpace.s4),
        _Steps(steps: const [
          'they open the file you sent',
          'android asks to allow installs from that app → allow',
          'install → make a node → scan each other\'s qr',
        ]),
        const SizedBox(height: JaalSpace.s3),
        Text('android shows a warning for apps outside the play store — that\'s expected.',
            style: monoStyle(11, color: JaalColors.xerox)),
      ];

  List<Widget> _ios() => [
        Center(
          child: Stack(clipBehavior: Clip.none, children: [
            ZineBox(
              color: Colors.white,
              child: QrImageView(data: JaalLinks.webApp, size: 220, backgroundColor: Colors.white),
            ),
            const Positioned(left: 20, top: -10, child: TapeStrip(width: 64, angle: -0.1)),
          ]),
        ),
        const SizedBox(height: JaalSpace.s3),
        Center(child: SelectableText(JaalLinks.webApp, style: monoStyle(12, bold: true))),
        const SizedBox(height: JaalSpace.s4),
        _Steps(steps: const [
          'scan with the iphone camera (needs internet once)',
          'safari → share → add to home screen',
          'open jaal from the home screen — it works offline from then on',
          'to swap posts: same wi-fi or your hotspot, then scan each other in "meet"',
        ]),
        const SizedBox(height: JaalSpace.s3),
        Text('apple doesn\'t allow installing apps outside the app store, so iphones get the web version.',
            style: monoStyle(11, color: JaalColors.xerox)),
      ];
}

class _Steps extends StatelessWidget {
  const _Steps({required this.steps});
  final List<String> steps;

  @override
  Widget build(BuildContext context) => ZineBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        shadow: JaalStroke.shadowSmall,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (final (i, s) in steps.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                InkLabel('${i + 1}', color: JaalColors.acid, textColor: JaalColors.ink),
                const SizedBox(width: 10),
                Expanded(child: Text(s)),
              ]),
            ),
        ]),
      );
}
