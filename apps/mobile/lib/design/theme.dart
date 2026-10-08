import 'package:flutter/material.dart';

import 'tokens.dart';

/// Material theme dressed as a photocopied zine: square corners, 3px ink
/// borders, no elevation blur, lowercase grotesk type.
ThemeData jaalTheme(Brightness b) {
  final dark = b == Brightness.dark;
  final bg = dark ? JaalColors.voidBlack : JaalColors.paper;
  final ink = dark ? JaalColors.inkOnVoid : JaalColors.ink;
  final surface = dark ? JaalColors.voidSoft : JaalColors.paper;
  final sunken = dark ? JaalColors.voidSoft : JaalColors.paperDeep;

  final scheme = ColorScheme(
    brightness: b,
    primary: JaalColors.acid,
    onPrimary: JaalColors.ink,
    secondary: JaalColors.pink,
    onSecondary: JaalColors.ink,
    tertiary: JaalColors.blue,
    onTertiary: JaalColors.paper,
    error: JaalColors.stamp,
    onError: JaalColors.paper,
    surface: surface,
    onSurface: ink,
    surfaceContainerHighest: sunken,
    outline: ink,
  );

  TextStyle ui(double size, {FontWeight w = FontWeight.w500}) => TextStyle(
      fontFamily: JaalFonts.ui, fontSize: size, fontWeight: w, color: ink, height: 1.35);
  TextStyle display(double size) => TextStyle(
      fontFamily: JaalFonts.display,
      fontWeight: FontWeight.w700,
      fontSize: size,
      color: ink,
      height: 1.0,
      letterSpacing: -0.04 * size);

  final square = RoundedRectangleBorder(
      side: BorderSide(color: ink, width: JaalStroke.thick),
      borderRadius: BorderRadius.zero);

  return ThemeData(
    useMaterial3: true,
    brightness: b,
    colorScheme: scheme,
    scaffoldBackgroundColor: bg,
    fontFamily: JaalFonts.ui,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    textTheme: TextTheme(
      displayLarge: display(JaalSize.mega),
      displayMedium: display(JaalSize.h1),
      displaySmall: display(JaalSize.h2),
      headlineMedium: display(JaalSize.h2),
      headlineSmall: display(JaalSize.h3),
      titleLarge: ui(JaalSize.h3, w: FontWeight.w700),
      titleMedium: ui(JaalSize.body, w: FontWeight.w700),
      bodyLarge: ui(JaalSize.body),
      bodyMedium: ui(JaalSize.small + 1),
      bodySmall: ui(JaalSize.small),
      labelLarge: ui(JaalSize.body, w: FontWeight.w700),
      labelSmall: TextStyle(
          fontFamily: JaalFonts.mono,
          fontSize: JaalSize.micro,
          letterSpacing: 0.5,
          color: ink),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      foregroundColor: ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: display(JaalSize.h2),
      shape: Border(bottom: BorderSide(color: ink, width: JaalStroke.thick)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: sunken,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: ink, width: JaalStroke.thick)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: ink, width: JaalStroke.thick)),
      focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: JaalColors.blue, width: JaalStroke.thick)),
      errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: JaalColors.stamp, width: JaalStroke.thick)),
      labelStyle: ui(JaalSize.small, w: FontWeight.w700),
      hintStyle: TextStyle(
          fontFamily: JaalFonts.mono, fontSize: JaalSize.small, color: JaalColors.xerox),
    ),
    dividerTheme: DividerThemeData(color: ink, thickness: JaalStroke.hairline),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStatePropertyAll(ink),
      trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? JaalColors.acid : sunken),
      trackOutlineColor: WidgetStatePropertyAll(ink),
      trackOutlineWidth: const WidgetStatePropertyAll(2),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: ink,
      inactiveTrackColor: sunken,
      thumbColor: JaalColors.pink,
      overlayShape: SliderComponentShape.noOverlay,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: JaalColors.acid,
      contentTextStyle: ui(JaalSize.small, w: FontWeight.w700).copyWith(color: JaalColors.ink),
      shape: const RoundedRectangleBorder(
          side: BorderSide(color: JaalColors.ink, width: JaalStroke.thick)),
      behavior: SnackBarBehavior.floating,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      shape: square,
      elevation: 0,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surface,
      shape: Border(top: BorderSide(color: ink, width: JaalStroke.thick)),
      elevation: 0,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: ink,
      unselectedLabelColor: JaalColors.xerox,
      labelStyle: display(JaalSize.body),
      unselectedLabelStyle: display(JaalSize.body),
      indicator: const BoxDecoration(color: JaalColors.acid),
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: ink,
    ),
  );
}
