// Renders the app icon (used by the web app + docs).
//   flutter test test_goldens/icon_test.dart --update-goldens
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaal_mobile/design/tokens.dart';

void main() {
  testWidgets('icon', (tester) async {
    tester.view.physicalSize = const Size(512, 512);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        color: JaalColors.acid,
        alignment: Alignment.center,
        child: Container(
          width: 400,
          height: 400,
          decoration: BoxDecoration(
            color: JaalColors.paper,
            border: Border.all(color: JaalColors.ink, width: 22),
            boxShadow: const [BoxShadow(color: JaalColors.ink, offset: Offset(22, 22))],
          ),
          alignment: Alignment.center,
          child: const Text('j', style: TextStyle(fontFamily: JaalFonts.wordmark, fontSize: 300, height: 1, color: JaalColors.ink)),
        ),
      ),
    ));
    await expectLater(find.byType(Directionality), matchesGoldenFile('goldens/icon-512.png'));
  });
}
