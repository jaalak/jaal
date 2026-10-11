import 'dart:io';

import 'package:flutter/material.dart';

import '../../app/updater.dart';
import '../../design/tokens.dart';
import '../../design/zine.dart';

/// Settings → updates: compare the installed version with the latest GitHub
/// release and, if it's newer, download it and open the system installer.
class UpdateSection extends StatefulWidget {
  const UpdateSection({super.key});

  @override
  State<UpdateSection> createState() => _UpdateSectionState();
}

enum _Stage { idle, checking, upToDate, available, downloading, ready, failed }

class _UpdateSectionState extends State<UpdateSection> {
  _Stage _stage = _Stage.idle;
  String? _installed;
  AppRelease? _release;
  File? _apk;
  double _progress = 0;
  String _error = '';

  @override
  void initState() {
    super.initState();
    Updater.installedVersion().then((v) => mounted ? setState(() => _installed = v) : null, onError: (_) {});
  }

  Future<void> _check() async {
    setState(() => _stage = _Stage.checking);
    try {
      final installed = _installed ?? await Updater.installedVersion();
      final r = await Updater.latest();
      if (!mounted) return;
      setState(() {
        _installed = installed;
        _release = r;
        _stage = r != null && Updater.compare(r.version, installed) > 0 ? _Stage.available : _Stage.upToDate;
      });
    } catch (e) {
      _fail('couldn\'t reach github. updates need internet, the mesh doesn\'t.');
    }
  }

  Future<void> _download() async {
    setState(() {
      _stage = _Stage.downloading;
      _progress = 0;
    });
    try {
      final apk = await Updater.download(_release!, (p) => mounted ? setState(() => _progress = p) : null);
      if (!mounted) return;
      setState(() {
        _apk = apk;
        _stage = _Stage.ready;
      });
      await _install();
    } catch (e) {
      _fail('download broke off. try again on steadier internet.');
    }
  }

  Future<void> _install() async {
    try {
      await Updater.install(_apk!);
    } catch (e) {
      _fail('couldn\'t open the installer: $e');
    }
  }

  void _fail(String msg) {
    if (!mounted) return;
    setState(() {
      _error = msg;
      _stage = _Stage.failed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = _release;
    final mb = r == null ? '' : '${(r.size / 1048576).toStringAsFixed(1)} mb';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text('installed', style: Theme.of(context).textTheme.titleMedium)),
        MonoChip('v${_installed ?? '…'}', color: JaalColors.paperDeep),
      ]),
      const SizedBox(height: 12),
      switch (_stage) {
        _Stage.idle => ZineButton(small: true, color: JaalColors.paper, icon: Icons.refresh, label: 'check for updates', onPressed: _check),
        _Stage.checking => Text('asking github…', style: monoStyle(12, color: JaalColors.xerox)),
        _Stage.upToDate => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const HandNote('you\'re on the latest. nothing to do.', size: 19),
            const SizedBox(height: 8),
            ZineButton(small: true, color: JaalColors.paper, icon: Icons.refresh, label: 'check again', onPressed: _check),
          ]),
        _Stage.available => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const MonoChip('new', color: JaalColors.pink, textColor: JaalColors.paper),
              const SizedBox(width: 8),
              Expanded(child: Text('v${r!.version} is out · $mb', style: monoStyle(12, bold: true))),
            ]),
            if (r.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(r.notes, style: monoStyle(11, color: JaalColors.xerox), maxLines: 8, overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 12),
            ZineButton(small: true, icon: Icons.download, label: 'download + update', onPressed: _download),
            const SizedBox(height: 6),
            const HandNote('your keys, posts and letters stay put.', size: 18),
          ]),
        _Stage.downloading => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('downloading v${r!.version}… ${(_progress * 100).round()}%', style: monoStyle(12, bold: true)),
            const SizedBox(height: 8),
            Container(
              height: 18,
              decoration: BoxDecoration(border: Border.all(color: inkOf(context), width: JaalStroke.thick)),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(widthFactor: _progress.clamp(0, 1), child: Container(color: JaalColors.acid)),
            ),
          ]),
        _Stage.ready => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const HandNote('downloaded. tap install on the next screen.', size: 19),
            const SizedBox(height: 6),
            Text('first time? android asks you to allow installs from jaal. allow it, then come back.',
                style: monoStyle(11, color: JaalColors.xerox)),
            const SizedBox(height: 8),
            ZineButton(small: true, icon: Icons.system_update, label: 'open installer', onPressed: _install),
          ]),
        _Stage.failed => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_error, style: monoStyle(11, color: JaalColors.stamp)),
            const SizedBox(height: 8),
            ZineButton(
              small: true,
              color: JaalColors.paper,
              icon: Icons.refresh,
              label: 'try again',
              onPressed: _release != null && Updater.compare(_release!.version, _installed ?? '0') > 0 ? _download : _check,
            ),
          ]),
      },
    ]);
  }
}
