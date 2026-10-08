import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // cryptography_flutter (a dependency) registers native Ed25519 / X25519 /
  // AEAD automatically; pure Dart crypto is ~100x slower on phones.
  runApp(const ProviderScope(child: JaalApp()));
}
