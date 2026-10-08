import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the real Jaal fonts (and Material icons) so widget tests lay out
/// text like a phone does — the default "Ahem" test font is much wider and
/// hides or invents overflows.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> asset(String family, List<String> paths) async {
    final loader = FontLoader(family);
    for (final p in paths) {
      loader.addFont(rootBundle.load(p));
    }
    await loader.load();
  }

  await asset('SpaceGrotesk', ['assets/fonts/SpaceGrotesk-Variable.ttf']);
  await asset('SpaceMono', ['assets/fonts/SpaceMono-Regular.ttf', 'assets/fonts/SpaceMono-Bold.ttf']);
  await asset('Caveat', ['assets/fonts/Caveat-Variable.ttf']);
  await asset('ArchivoBlack', ['assets/fonts/ArchivoBlack-Regular.ttf']);

  final root = Platform.environment['FLUTTER_ROOT'];
  final icons = File('${root ?? 'C:/flutter'}/bin/cache/artifacts/material_fonts/materialicons-regular.otf');
  if (icons.existsSync()) {
    final loader = FontLoader('MaterialIcons')
      ..addFont(Future.value(ByteData.sublistView(Uint8List.fromList(icons.readAsBytesSync()))));
    await loader.load();
  }

  await testMain();
}
