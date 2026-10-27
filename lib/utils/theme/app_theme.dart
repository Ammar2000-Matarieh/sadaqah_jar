import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_palette.dart';

class AppTheme {
  static ThemeData get light => _build(AppPalette.light, Brightness.light);
  static ThemeData get dark => _build(AppPalette.dark, Brightness.dark);

  static ThemeData _build(AppPalette p, Brightness b) {
    final isDark = b == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: b,
      fontFamily: 'Cairo',
      scaffoldBackgroundColor: p.background,
      canvasColor: p.bottomBar,
      dividerColor: p.border,
      colorScheme: ColorScheme(
        brightness: b,
        primary: p.accent,
        onPrimary: Colors.white,
        secondary: p.counterCircle,
        onSecondary: Colors.white,
        error: p.resetIcon,
        onError: Colors.white,
        surface: p.card,
        onSurface: p.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: p.topBar,
        foregroundColor: p.topBarTitle,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: p.topBarTitle),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        color: p.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: p.bottomBar,
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.bottomBar,
        surfaceTintColor: Colors.transparent,
        indicatorColor: isDark ? Colors.transparent : p.surahCircle,
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            color: s.contains(WidgetState.selected)
                ? p.accent
                : p.textSecondary,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            color: s.contains(WidgetState.selected)
                ? p.accent
                : p.textSecondary,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(color: p.border, thickness: 1),
      iconTheme: IconThemeData(color: p.textSecondary),
      textTheme: ThemeData(brightness: b).textTheme.apply(
        fontFamily: 'Cairo',
        bodyColor: p.textPrimary,
        displayColor: p.textPrimary,
      ),
      extensions: [p],
    );
  }
}
