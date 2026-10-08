import 'package:flutter/material.dart';

class AppMotion {
  AppMotion._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration standard = Duration(milliseconds: 220);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration busInterpolation = Duration(milliseconds: 2800);
  static const Duration pulse = Duration(milliseconds: 1200);

  static const Curve standardCurve = Curves.easeOutCubic;
  static const Curve enterCurve = Curves.easeOutQuad;
  static const Curve exitCurve = Curves.easeInQuad;
}
