import 'dart:io';

// API Configuration — auto-detects environment
class ApiConfig {
  // ── Backend base URL ────────────────────────────────────────────────────────
  // 10.0.2.2  = Android emulator → host machine localhost
  // localhost  = iOS simulator   → host machine localhost
  // Change to your LAN IP (e.g. 192.168.1.x) for real device on same WiFi
  static String get baseUrl {
    return 'http://192.168.1.13:3001'; // Real device on WiFi
  }

  // ── Voice Analysis Server ───────────────────────────────────────────────────
  static const String voiceApiBaseUrl =
      'https://gradution-project-u39v.onrender.com';
  static const String voiceAnalyzeText  = '/analyze';
  static const String voiceAnalyzeAudio = '/voice';

  // ── Auth ────────────────────────────────────────────────────────────────────
  static const String authSignup          = '/auth/signup';
  static const String authConfirmOtp      = '/auth/signup/configurationOTP';
  static const String authSignin          = '/auth/signin';
  static const String authChangePassword  = '/auth/changePassword';
  static const String authResendOtp       = '/auth/resendOTP';
  static const String authForgetPassword  = '/auth/forgetPassword';
  static const String authSetNewPassword  = '/auth/setNewPassword';
  static const String authProfile         = '/auth/profile';
  static const String authDeleteAccount   = '/auth/account';

  // ── Transactions ────────────────────────────────────────────────────────────
  static const String transactions            = '/transactions';
  static const String transactionsWithText    = '/transactions/createWithText';
  static const String transactionsMy         = '/transactions/my';
  static const String transactionsByCategory = '/transactions/category';
  static const String transactionsByDateRange = '/transactions/date-range';

  // ── Categories ──────────────────────────────────────────────────────────────
  static const String categories = '/category';

  // ── Items ───────────────────────────────────────────────────────────────────
  static const String items                   = '/items';
  static const String itemsAddToCategory      = '/items/add-to-category';
  static const String itemsRemoveFromCategory = '/items/remove-from-category';

  // ── Analytics ───────────────────────────────────────────────────────────────
  static const String analyticsSummary      = '/analytics/summary';
  static const String analyticsByCategory   = '/analytics/by-category';
  static const String analyticsByDate       = '/analytics/by-date';
  static const String analyticsTopCategories = '/analytics/top-categories';
  static const String analyticsTrends       = '/analytics/trends';

  // ── Offers ──────────────────────────────────────────────────────────────────
  static const String offers        = '/api/offers';
  static const String offersPreview = '/api/offers/preview';

  // ── Export ──────────────────────────────────────────────────────────────────
  static const String export = '/export';

  // ── Health ──────────────────────────────────────────────────────────────────
  static const String healthCheck = '/api';

  // ── Timeouts ────────────────────────────────────────────────────────────────
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout    = Duration(seconds: 15);
}
