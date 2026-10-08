import 'package:flutter/widgets.dart';

/// Off-Grid Zine design tokens. Mirrors docs/stitch/tokens.json — keep the
/// two in sync; Stitch designs and Flutter code share these values.
abstract final class JaalColors {
  static const paper = Color(0xFFF4F1E8);
  static const paperDeep = Color(0xFFE9E3D3);
  static const voidBlack = Color(0xFF0A0A0A);
  static const voidSoft = Color(0xFF1A1A1A);
  static const ink = Color(0xFF0A0A0A);
  static const inkOnVoid = Color(0xFFF4F1E8);
  static const acid = Color(0xFFC6FF00);
  static const pink = Color(0xFFFF3EA5);
  static const blue = Color(0xFF3D5AFE);
  static const tape = Color(0xFFF9E27A);
  static const stamp = Color(0xFFD7263D);
  static const xerox = Color(0xFF8A857A);
}

abstract final class JaalFonts {
  /// Stitch DESIGN.md: headlines are Space Grotesk 700, tight, negative
  /// tracking. Archivo Black is kept for the wordmark only.
  static const display = 'SpaceGrotesk';
  static const wordmark = 'ArchivoBlack';
  static const ui = 'SpaceGrotesk';
  static const mono = 'SpaceMono';
  static const hand = 'Caveat';
}

abstract final class JaalSize {
  static const mega = 56.0;
  static const h1 = 36.0;
  static const h2 = 26.0;
  static const h3 = 20.0;
  static const body = 16.0;
  static const small = 13.0;
  static const micro = 11.0;
  static const hand = 22.0;
}

abstract final class JaalSpace {
  static const s1 = 4.0;
  static const s2 = 8.0;
  static const s3 = 12.0;
  static const s4 = 16.0;
  static const s5 = 24.0;
  static const s6 = 32.0;
  static const s7 = 48.0;
}

abstract final class JaalStroke {
  static const thick = 3.0;
  static const hairline = 1.5;
  static const shadow = Offset(6, 6);
  static const shadowSmall = Offset(3, 3);
}

abstract final class JaalMotion {
  static const press = Duration(milliseconds: 80);
  static const enter = Duration(milliseconds: 160);
  static const sticker = Duration(milliseconds: 220);
}

/// Deterministic tilt (radians) for an item, from its id: hand-pasted, but
/// stable across rebuilds.
double tiltFor(String id, {double maxDeg = 2}) {
  var h = 0;
  for (final c in id.codeUnits) {
    h = (h * 31 + c) & 0x7fffffff;
  }
  final deg = (h % 5 - 2) * (maxDeg / 2);
  return deg * 3.141592653589793 / 180;
}
