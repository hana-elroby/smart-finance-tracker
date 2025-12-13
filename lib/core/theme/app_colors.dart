// ألوان التطبيق - جميع الألوان المستخدمة في التطبيق
// App Colors - All colors used in the application
import 'package:flutter/material.dart';

class AppColors {
  // الألوان الأساسية - Primary colors
  static const Color primary = Color(0xFF003566);
  static const Color secondary = Color(0xFF00CCFF);
  static const Color background = Color(0xFFF5F7FA);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text colors
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textLight = Color(0xFFFFFFFF);

  // Success & Error
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFF25858);

  // Other colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color numPad = Color(0xFF4A4A4A);
  static const Color inputBackground = Color(
    0xFFE1E5F2,
  ); // Input field background
  static const Color saveButton = Color(
    0xFF00CCFF,
  ); // Save button (Accents Blue)

  // ========== Categories Gradients (Home Page) ==========
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

  static const LinearGradient transportGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF9C27B0), Color(0xFF192148)],
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

  // Card Gradient (for Progress Bar)
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF003566), Color(0xFF00CCFF)],
  );

  // Accent color
  static const Color accent = Color(0xFF00CCFF);

  // ========== Chart/Spending Colors ==========
  static const Color chartBar1 = Color(0xFFC5C9D0); // Light gray bar
  static const Color chartBar2 = Color(0xFF003566); // Dark blue bar
  static const Color chartBackground = Color(0xFFF4F3F3); // Chart background

  // ========== Categories Page Gradients (أفتح للعين) ==========
  static const LinearGradient shoppingGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5DD3F3), Color(0xFF4A90E2)],
  );

  static const LinearGradient billsGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF78A8A), Color(0xFF8B6BA8)],
  );

  static const LinearGradient healthGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7AE5A0), Color(0xFF5A8F9F)],
  );

  static const LinearGradient activitiesGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE857D8), Color(0xFF8B7BA8)],
  );

  static const LinearGradient foodGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6BA5F4), Color(0xFF6B7BA8)],
  );

  static const LinearGradient educationGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5EFFD5), Color(0xFF6B7BA8)],
  );

  static const LinearGradient entertainmentGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFC176), Color(0xFFF58FB5)],
  );
}
