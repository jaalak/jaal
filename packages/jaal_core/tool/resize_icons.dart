// Resizes the rendered app icon (apps/mobile/test_goldens/goldens/icon-512.png)
// for the web app. Run from packages/jaal_core.
import 'dart:io';

import 'package:image/image.dart' as img;

void main() {
  final src = img.decodePng(File('../../apps/mobile/test_goldens/goldens/icon-512.png').readAsBytesSync())!;
  Directory('../../apps/pwa/public/icons').createSync(recursive: true);
  for (final s in [512, 192, 180]) {
    final out = s == 512 ? src : img.copyResize(src, width: s, height: s, interpolation: img.Interpolation.average);
    File('../../apps/pwa/public/icons/icon-$s.png').writeAsBytesSync(img.encodePng(out));
    stdout.writeln('icon-$s.png');
  }
}
