import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;

  // Corner Radii
  static const double radiusInput = 16.0;
  static const double radiusButton = 16.0;
  static const double radiusCard = 20.0;
  static const double radiusChip = 999.0;
  static const double radiusSheet = 28.0;
  static const double radiusServerIcon = 14.0;
  static const double radiusAvatar = 999.0;

  // Touch Target
  static const double minTouchTarget = 48.0;
  static const BoxConstraints touchTargetConstraints = BoxConstraints(
    minWidth: minTouchTarget,
    minHeight: minTouchTarget,
  );
}
