// ألوان التطبيق - جميع الألوان المستخدمة في التطبيق
// App Colors - All colors used in the application
import 'package:flutter/material.dart';

class AppColors {
  // الألوان الأساسية - Primary colors
  static const Color primary = Color(0xFF003566);
  static const Color secondary = Color(0xFF00CCFF);
  static const Color background = Color(0xFFE1E5F2);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text colors
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textLight = Color(0xFFFFFFFF);

  // Success & Error
  static const Color success = Color(0xFF45F36B);
  static const Color error = Color(0xFFF25858);

  // Other colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color numPad = Color(0xFF4A4A4A);

  // ========== Categories Gradients ==========
  static const LinearGradient shoppingGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00CCFF), Color(0xFF003566)],
  );

  static const LinearGradient billsGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF25858), Color(0xFF192148)],
  );

  static const LinearGradient healthGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF45F36B), Color(0xFF141744)],
  );

  static const LinearGradient activitiesGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFCF0FB6), Color(0xFF212C55)],
  );

  static const LinearGradient foodGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4285F4), Color(0xFF192148)],
  );

  static const LinearGradient educationGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF02FFD5), Color(0xFF192148)],
  );

  static const LinearGradient entertainmentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFA726), Color(0xFFEC407A)],
  );

  // Notification Icon Gradient
  static const LinearGradient notificationGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF9333EA), Color(0xFFC084FC)],
  );
}
