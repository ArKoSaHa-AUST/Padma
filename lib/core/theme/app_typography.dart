import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static TextTheme textTheme(bool isDark, {bool isBangla = false}) {
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    TextStyle baseStyle(double size, FontWeight weight, Color color, [double height = 1.4]) {
      if (isBangla) {
        return GoogleFonts.hindSiliguri(
          fontSize: size,
          fontWeight: weight,
          color: color,
          height: height,
        );
      }
      return GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
      );
    }

    return TextTheme(
      displayLarge: baseStyle(32, FontWeight.w700, textPrimary, 1.2),
      headlineLarge: baseStyle(24, FontWeight.w700, textPrimary, 1.3),
      headlineMedium: baseStyle(20, FontWeight.w600, textPrimary, 1.35),
      bodyLarge: baseStyle(16, FontWeight.w400, textPrimary, 1.45),
      bodyMedium: baseStyle(14, FontWeight.w400, textPrimary, 1.4),
      labelLarge: baseStyle(13, FontWeight.w600, textPrimary, 1.3),
      bodySmall: baseStyle(12, FontWeight.w400, textMuted, 1.35),
    );
  }
}
