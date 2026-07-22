import 'package:flutter/painting.dart';

/// Semantic colors for Fyqen's default Dark Purple theme.
abstract final class AppColors {
  const AppColors._();

  static const Color background = Color(0xFF0D0B14);
  static const Color surface = Color(0xFF171321);
  static const Color surfaceElevated = Color(0xFF211A2E);
  static const Color surfaceMuted = Color(0xFF2A2238);

  static const Color primary = Color(0xFF9B6DFF);
  static const Color primaryStrong = Color(0xFF7C3AED);
  static const Color primaryContainer = Color(0xFF35205E);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFEADDFF);

  static const Color textPrimary = Color(0xFFF7F2FF);
  static const Color textSecondary = Color(0xFFCAC2D6);
  static const Color textMuted = Color(0xFF958CA2);

  static const Color border = Color(0xFF3A3147);
  static const Color divider = Color(0xFF30283B);

  static const Color success = Color(0xFF62D9A1);
  static const Color warning = Color(0xFFFFC857);
  static const Color error = Color(0xFFFF6B7A);
  static const Color info = Color(0xFF79B8FF);

  static const Color shadow = Color(0x66000000);
}
