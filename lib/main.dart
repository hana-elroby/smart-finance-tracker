// الملف الرئيسي للتطبيق - نقطة البداية
// Main app entry point
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';           // ثيم التطبيق (الألوان والخطوط)
import 'core/constants/app_constants.dart';   // الثوابت (اسم التطبيق، المدد الزمنية)
import 'features/splash/presentation/pages/splash_page.dart'; // شاشة البداية

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashPage(),
    );
  }
}
