import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF9B8FFF),
      brightness: Brightness.light,
      primary: const Color(0xFF7C6FFF),
      onPrimary: Colors.white,
      secondary: const Color(0xFF3DD9A4),
      tertiary: const Color(0xFFFF6BBD),
      surface: const Color(0xFFFAF9FF),
      surfaceContainerHighest: const Color(0xFFF0EEFF),
      outline: const Color(0xFFD4D0F0),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFFAF9FF),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFFAF9FF),
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A1A3E),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFEEEBFF), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF7C6FFF),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF7C6FFF),
          minimumSize: const Size(double.infinity, 56),
          side: const BorderSide(color: Color(0xFFD4D0F0), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return const Color(0xFFB0AAD0);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return const Color(0xFF7C6FFF);
          return const Color(0xFFEEEBFF);
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFEEEBFF),
        thickness: 1,
        space: 0,
      ),
      textTheme: _textTheme(const Color(0xFF1A1A3E), const Color(0xFF6B6990)),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF9B8FFF),
      brightness: Brightness.dark,
      primary: const Color(0xFF9B8FFF),
      onPrimary: Colors.white,
      secondary: const Color(0xFF3DD9A4),
      tertiary: const Color(0xFFFF6BBD),
      surface: const Color(0xFF0F0F1E),
      surfaceContainerHighest: const Color(0xFF1A1A2E),
      outline: const Color(0xFF2A2A46),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF0A0A12),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF0A0A12),
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Color(0xFFF0F0FF),
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF16162A),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF2A2A46), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF9B8FFF),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF9B8FFF),
          minimumSize: const Size(double.infinity, 56),
          side: const BorderSide(color: Color(0xFF2A2A46), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return const Color(0xFF4A4A6A);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return const Color(0xFF9B8FFF);
          return const Color(0xFF2A2A46);
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2A2A46),
        thickness: 1,
        space: 0,
      ),
      textTheme: _textTheme(const Color(0xFFF0F0FF), const Color(0xFFA8A8C8)),
    );
  }

  static TextTheme _textTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: primary),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: primary),
      displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: primary),
      headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: primary),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: primary),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: primary),
      titleLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: primary),
      titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: primary),
      titleSmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: primary),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: primary),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: secondary),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: secondary),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primary),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: secondary),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: secondary),
    );
  }
}
