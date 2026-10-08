import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../design/theme.dart';
import 'router.dart';

class JaalApp extends ConsumerWidget {
  const JaalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
        title: 'jaal',
        debugShowCheckedModeBanner: false,
        theme: jaalTheme(Brightness.light),
        darkTheme: jaalTheme(Brightness.dark),
        routerConfig: ref.watch(routerProvider),
      );
}
