// ثوابت التطبيق - معلومات ثابتة تستخدم في كل التطبيق
// App Constants - Fixed values used throughout the app
class AppConstants {
  // معلومات التطبيق - App info
  static const String appName = 'SaveIt';        // اسم التطبيق
  static const String appVersion = '1.0.0';      // رقم الإصدار

  // Animation durations
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 1000);

  // Asset paths
  static const String moneyLottie = 'assets/Money.json';
  static const String microphoneLottie = 'assets/microphone.json';
  static const String scanReceiptLottie = 'assets/Scan a receipt.json';
}
