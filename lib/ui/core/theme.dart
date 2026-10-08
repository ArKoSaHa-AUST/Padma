import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PadmaTheme {
  // Brand Colors
  static const Color background = Color(0xFF121316);
  static const Color surface = Color(0xFF1F1F23);
  static const Color surfaceElevated = Color(0xFF292A2D);
  static const Color surfaceHighest = Color(0xFF343538);
  static const Color surfaceLowest = Color(0xFF0D0E11);
  static const Color borderLine = Color(0xFF3F4147);

  // Accents
  static const Color primaryTeal = Color(0xFF14B8A6);
  static const Color primaryTealContainer = Color(0xFF00423B);
  static const Color onPrimary = Color(0xFF003731);
  static const Color busAmber = Color(0xFFEE9800);
  static const Color busAmberContainer = Color(0xFF472A00);
  static const Color urgentRed = Color(0xFFEF4444);
  static const Color urgentRedContainer = Color(0xFF93000A);
  static const Color successGreen = Color(0xFF22C55E);

  // Text Colors
  static const Color textPrimary = Color(0xFFF2F3F5);
  static const Color textSecondary = Color(0xFFB5BAC1);
  static const Color textMuted = Color(0xFF80848E);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primaryTeal,
      colorScheme: const ColorScheme.dark(
        primary: primaryTeal,
        secondary: busAmber,
        surface: surface,
        error: urgentRed,
        onPrimary: onPrimary,
        onSecondary: textPrimary,
        onSurface: textPrimary,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme.copyWith(
          headlineMedium: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
          titleLarge: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          titleMedium: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          bodyLarge: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textPrimary,
          ),
          bodyMedium: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: textSecondary,
          ),
          labelSmall: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: textMuted,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderLine,
        thickness: 1,
      ),
      cardTheme: CardThemeData(
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderLine, width: 0.8),
        ),
        elevation: 0,
      ),
    );
  }
}
