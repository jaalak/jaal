import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// A published Android build: a GitHub release tagged `v<version>` with a `jaal.apk` asset.
class AppRelease {
  const AppRelease({required this.version, required this.notes, required this.apk, required this.size});
  final String version;
  final String notes;
  final Uri apk;
  final int size;
}

/// Settings → updates. Releases are signed with the same key, so the system
/// installer upgrades in place and keeps the node's keys and data.
abstract final class Updater {
  static const repo = 'jaalak/jaal';
  static const _channel = MethodChannel('jaal/app');

  static Future<String> installedVersion() async => await _channel.invokeMethod<String>('version') ?? '0.0.0';

  /// The latest release, or null if none has a `jaal.apk` attached.
  static Future<AppRelease?> latest() async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
    try {
      final req = await client.getUrl(Uri.parse('https://api.github.com/repos/$repo/releases/latest'));
      req.headers.set(HttpHeaders.acceptHeader, 'application/vnd.github+json');
      final res = await req.close();
      if (res.statusCode == HttpStatus.notFound) return null;
      if (res.statusCode != HttpStatus.ok) throw HttpException('github said ${res.statusCode}');
      final json = jsonDecode(await res.transform(utf8.decoder).join()) as Map<String, dynamic>;
      final asset = (json['assets'] as List).cast<Map<String, dynamic>>().where((a) => a['name'] == 'jaal.apk').firstOrNull;
      if (asset == null) return null;
      return AppRelease(
        version: (json['tag_name'] as String).replaceFirst(RegExp('^v'), ''),
        notes: (json['body'] as String?)?.trim() ?? '',
        apk: Uri.parse(asset['browser_download_url'] as String),
        size: asset['size'] as int,
      );
    } finally {
      client.close();
    }
  }

  /// Compares dotted versions numerically (`0.10.0` > `0.9.2`); build suffixes are ignored.
  static int compare(String a, String b) {
    List<int> parts(String v) => v.split(RegExp(r'[+-]')).first.split('.').map((x) => int.tryParse(x) ?? 0).toList();
    final x = parts(a), y = parts(b);
    for (var i = 0; i < 3; i++) {
      final d = (i < x.length ? x[i] : 0) - (i < y.length ? y[i] : 0);
      if (d != 0) return d.sign;
    }
    return 0;
  }

  /// Downloads into cache/updates/ (the only folder the installer is allowed to read).
  static Future<File> download(AppRelease r, void Function(double progress) onProgress) async {
    final dir = Directory(p.join((await getTemporaryDirectory()).path, 'updates'));
    if (dir.existsSync()) dir.deleteSync(recursive: true);
    dir.createSync(recursive: true);
    final file = File(p.join(dir.path, 'jaal-${r.version}.apk'));
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
    try {
      final res = await (await client.getUrl(r.apk)).close();
      if (res.statusCode != HttpStatus.ok) throw HttpException('download failed (${res.statusCode})');
      final total = res.contentLength > 0 ? res.contentLength : r.size;
      final sink = file.openWrite();
      var got = 0;
      await for (final chunk in res) {
        sink.add(chunk);
        got += chunk.length;
        if (total > 0) onProgress(got / total);
      }
      await sink.close();
      return file;
    } finally {
      client.close();
    }
  }

  static Future<void> install(File apk) => _channel.invokeMethod<void>('installApk', {'path': apk.path});
}
