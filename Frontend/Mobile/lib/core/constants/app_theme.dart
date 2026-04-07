import 'package:flutter/material.dart';

class AppThemeColors {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color onSurface;
  final Color surfaceMuted;
  final Color border;
  final Color onSurfaceMuted;

  const AppThemeColors({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.onSurface,
    required this.surfaceMuted,
    required this.border,
    required this.onSurfaceMuted,
  });
}

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color primary;
  final Color surface;
  final Color surfaceMuted;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color danger;

  const AppPalette({
    required this.primary,
    required this.surface,
    required this.surfaceMuted,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.danger,
  });

  @override
  AppPalette copyWith({
    Color? primary,
    Color? surface,
    Color? surfaceMuted,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? danger,
  }) {
    return AppPalette(
      primary: primary ?? this.primary,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      danger: danger ?? this.danger,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t) ?? surfaceMuted,
      border: Color.lerp(border, other.border, t) ?? border,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      danger: Color.lerp(danger, other.danger, t) ?? danger,
    );
  }
}

extension AppPaletteX on BuildContext {
  AppPalette get appPalette => Theme.of(this).extension<AppPalette>()!;
}

class AppTheme {
  static const AppThemeColors lightColors = AppThemeColors(
    primary: Color(0xFFC9A227),
    secondary: Color(0xFFB8860B),
    background: Color(0xFFF5F5F5),
    surface: Colors.white,
    onSurface: Color(0xFF000000),
    surfaceMuted: Color(0xFFFDF6E9),
    border: Color(0xFFE0E0E0),
    onSurfaceMuted: Color(0xFF616161),
  );

  static const AppThemeColors darkColors = AppThemeColors(
    primary: Color(0xFFFFD54F),
    secondary: Color(0xFFE6B94A),
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    onSurface: Color(0xFFF5F5F5),
    surfaceMuted: Color(0xFF2A2415),
    border: Color(0xFF3A3A3A),
    onSurfaceMuted: Color(0xFFB0B0B0),
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
      dividerColor: lightColors.border,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightColors.border, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightColors.background,
        foregroundColor: lightColors.onSurface,
        elevation: 0,
      ),
      extensions: const [
        AppPalette(
          primary: Color(0xFFC9A227),
          surface: Colors.white,
          surfaceMuted: Color(0xFFFDF6E9),
          border: Color(0xFFE0E0E0),
          textPrimary: Color(0xFF000000),
          textSecondary: Color(0xFF616161),
          danger: Color(0xFFF44336),
        ),
      ],
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
      dividerColor: darkColors.border,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkColors.border, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkColors.background,
        foregroundColor: darkColors.onSurface,
        elevation: 0,
      ),
      extensions: const [
        AppPalette(
          primary: Color(0xFFFFD54F),
          surface: Color(0xFF1E1E1E),
          surfaceMuted: Color(0xFF2A2415),
          border: Color(0xFF3A3A3A),
          textPrimary: Color(0xFFF5F5F5),
          textSecondary: Color(0xFFB0B0B0),
          danger: Color(0xFFEF5350),
        ),
      ],
      textTheme: ThemeData.dark().textTheme.apply(
            bodyColor: darkColors.onSurface,
            displayColor: darkColors.onSurface,
          ),
    );
  }
}
