import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Output of [PhotoCompressor.compress].
class CompressedPhoto {
  const CompressedPhoto(this.bytes, this.width, this.height, this.originalBytes);
  final Uint8List bytes;
  final int width, height;
  final int originalBytes;
  String get mime => 'image/jpeg';
}

enum PhotoFilter {
  /// As shot.
  raw,

  /// Photocopied zine look: grayscale, punchy contrast, toner grain.
  xerox,
}

/// Shrinks photos so they can travel phone to phone (protocol/SPEC.md §8).
///
/// Pure Dart (package:image) so it runs in tests and in a background
/// isolate on the phone. Resizes the long edge to [maxEdge], then lowers
/// JPEG quality until the result fits [targetBytes] — about 7 chunks of
/// 64 KB by default.
abstract final class PhotoCompressor {
  static CompressedPhoto compress(
    Uint8List input, {
    int maxEdge = 1440,
    int targetBytes = 450 * 1024,
    PhotoFilter filter = PhotoFilter.raw,
  }) {
    var image = img.decodeImage(input);
    if (image == null) throw const FormatException('not an image we can read');
    image = img.bakeOrientation(image);
    final long = image.width > image.height ? image.width : image.height;
    if (long > maxEdge) {
      image = image.width >= image.height
          ? img.copyResize(image, width: maxEdge, interpolation: img.Interpolation.average)
          : img.copyResize(image, height: maxEdge, interpolation: img.Interpolation.average);
    }
    if (filter == PhotoFilter.xerox) image = xerox(image);

    Uint8List out = img.encodeJpg(image, quality: 80);
    for (var q = 72; out.length > targetBytes && q >= 30; q -= 8) {
      out = img.encodeJpg(image, quality: q);
    }
    // Still too big (huge detailed photo): shrink further.
    while (out.length > targetBytes && image!.width > 480) {
      image = img.copyResize(image, width: (image.width * 0.8).round());
      out = img.encodeJpg(image, quality: 60);
    }
    return CompressedPhoto(out, image!.width, image.height, input.length);
  }

  /// Photocopy filter: grayscale, crushed contrast, toner speckle.
  static img.Image xerox(img.Image src) {
    var i = img.grayscale(src);
    i = img.adjustColor(i, contrast: 1.6, brightness: 1.05);
    i = img.noise(i, 18, type: img.NoiseType.gaussian);
    return img.grayscale(i);
  }
}
