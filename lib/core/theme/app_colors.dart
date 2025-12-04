import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF003566);
  static const Color secondary = Color(0xFF00CCFF);
  static const Color background = Color(0xFFD5D7DA);

  // Text colors
  static const Color textPrimary = Color(0xFF003566);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textLight = Color(0xFFFFFFFF);

  // Other colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF003566), Color(0xFF006BB3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
