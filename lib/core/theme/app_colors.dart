import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Dark Theme (Default)
  static const Color darkBgBase = Color(0xFF0E1A24);
  static const Color darkBgGradientEnd = Color(0xFF12303A);
  static const Color darkSurface1 = Color(0xFF1A2B38);
  static const Color darkSurface2 = Color(0xFF223645);
  static const Color darkSurfaceRail = Color(0xFF0A131B);
  static const Color darkBorder = Color(0xFF2A3F4E);
  static const Color darkPrimary = Color(0xFFFFB300); // Bus Amber
  static const Color darkOnPrimary = Color(0xFF1A1200);
  static const Color darkSecondary = Color(0xFF2EC4B6); // River Teal
  static const Color darkOnSecondary = Color(0xFF003731);
  static const Color darkTextPrimary = Color(0xFFF2F5F7);
  static const Color darkTextMuted = Color(0xFF9FB3C0);

  // Semantics (Shared)
  static const Color success = Color(0xFF3DDC97);
  static const Color warning = Color(0xFFFFB020);
  static const Color danger = Color(0xFFFF5A5F);
  static const Color info = Color(0xFF4DA3FF);
  static const Color adminBadge = Color(0xFF7C5CFF);
  static const Color driverBadge = Color(0xFF2EC4B6);
  static const Color studentBadge = Color(0xFF4DA3FF);

  // Light Theme
  static const Color lightBgBase = Color(0xFFF4F8FA);
  static const Color lightSurface1 = Color(0xFFFFFFFF);
  static const Color lightSurface2 = Color(0xFFEAF1F5);
  static const Color lightBorder = Color(0xFFD5E1E8);
  static const Color lightTextPrimary = Color(0xFF10202B);
  static const Color lightTextMuted = Color(0xFF5B7080);
  static const Color lightPrimary = Color(0xFFF5A300);
  static const Color lightSecondary = Color(0xFF11998E);

  // Surface Tint Helpers
  static Color dangerSurface(bool isDark) =>
      danger.withValues(alpha: isDark ? 0.15 : 0.12);
  static Color warningSurface(bool isDark) =>
      warning.withValues(alpha: isDark ? 0.15 : 0.12);
  static Color successSurface(bool isDark) =>
      success.withValues(alpha: isDark ? 0.15 : 0.12);
  static Color secondarySurface(bool isDark) =>
      darkSecondary.withValues(alpha: isDark ? 0.15 : 0.12);
  static Color adminSurface(bool isDark) =>
      adminBadge.withValues(alpha: isDark ? 0.18 : 0.12);
}
