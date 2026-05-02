import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  const AppTheme._();

  static const _seedColor = Color(0xFF2868C7);
  static const _background = Color(0xFFF2F6FC);
  static const _surface = Color(0xFFF7F9FD);
  static const _surfaceContainer = Color(0xFFEAF0F8);
  static const _surfaceContainerLow = Color(0xFFF5F8FC);
  static const _outline = Color(0xFFC5D0E0);

  static ThemeData get light {
    final generatedScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    );

    final colorScheme = generatedScheme.copyWith(
      primary: _seedColor,
      onPrimary: Colors.white,
      secondary: const Color(0xFF4A7C8C),
      tertiary: const Color(0xFF8A6F2A),
      surface: _surface,
      onSurface: const Color(0xFF18212F),
      onSurfaceVariant: const Color(0xFF4E5B6D),
      outline: _outline,
      outlineVariant: const Color(0xFFD8E0EC),
    );

    final baseTheme = ThemeData(useMaterial3: true, colorScheme: colorScheme);

    return baseTheme.copyWith(
      scaffoldBackgroundColor: _background,
      textTheme: GoogleFonts.robotoTextTheme(baseTheme.textTheme),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: _background,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        color: _surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shadowColor: const Color(0x1A18324A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceContainer,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
