import 'package:flutter/material.dart';

class AppThemeColors {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color onSurface;

  const AppThemeColors({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.onSurface,
  });
}

class AppTheme {
  static const AppThemeColors lightColors = AppThemeColors(
    primary: Color(0xFFC9A227),
    secondary: Color(0xFFB8860B),
    background: Color(0xFFF5F5F5),
    surface: Colors.white,
    onSurface: Color(0xFF000000),
  );

  static const AppThemeColors darkColors = AppThemeColors(
    primary: Color(0xFFFFD54F),
    secondary: Color(0xFFE6B94A),
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    onSurface: Color(0xFFF5F5F5),
  );

  static ThemeData get lightTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: lightColors.primary,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: lightColors.background,
      cardColor: lightColors.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: lightColors.background,
        foregroundColor: lightColors.onSurface,
        elevation: 0,
      ),
      textTheme: ThemeData.light().textTheme.apply(
            bodyColor: lightColors.onSurface,
            displayColor: lightColors.onSurface,
          ),
    );
  }

  static ThemeData get darkTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: darkColors.primary,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: darkColors.background,
      cardColor: darkColors.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: darkColors.background,
        foregroundColor: darkColors.onSurface,
        elevation: 0,
      ),
      textTheme: ThemeData.dark().textTheme.apply(
            bodyColor: darkColors.onSurface,
            displayColor: darkColors.onSurface,
          ),
    );
  }
}
