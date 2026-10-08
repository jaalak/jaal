// Compresses the Stitch sample photos into small JPEGs that Network Lab
// peers post (apps/mobile/assets/lab). Run from packages/jaal_core.
import 'dart:io';

import 'package:jaal_core/jaal_core.dart';

Future<void> main() async {
  final src = Directory('../../docs/stitch/exports/assets');
  final out = Directory('../../apps/mobile/assets/lab')..createSync(recursive: true);
  var i = 0;
  for (final f in src.listSync().whereType<File>().where((f) => f.path.endsWith('.png'))) {
    final c = PhotoCompressor.compress(await f.readAsBytes(),
        maxEdge: 900, targetBytes: 140 * 1024, filter: PhotoFilter.xerox);
    final o = File('${out.path}/photo-${++i}.jpg');
    await o.writeAsBytes(c.bytes);
    stdout.writeln('${o.path}  ${c.width}x${c.height}  ${c.bytes.length ~/ 1024} kb');
  }
}
