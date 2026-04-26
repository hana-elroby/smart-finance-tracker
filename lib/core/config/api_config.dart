// API Configuration
class ApiConfig {
  // Main Backend - Local Server
  // 10.0.2.2 = localhost from Android emulator
  static const String baseUrl = 'http://10.0.2.2:3001';

  // Voice Analysis Server
  static const String voiceApiBaseUrl = 'https://gradution-project-u39v.onrender.com';
  static const String voiceAnalyzeText = '/analyze';
  static const String voiceAnalyzeAudio = '/voice';

  // Auth
  static const String authSignup = '/auth/signup';
  static const String authConfirmOtp = '/auth/signup/configurationOTP';
  static const String authSignin = '/auth/signin';
  static const String authChangePassword = '/auth/changePassword';
  static const String authResendOtp = '/auth/resendOTP';
  static const String authForgetPassword = '/auth/forgetPassword';
  static const String authSetNewPassword = '/auth/setNewPassword';
  static const String authProfile = '/auth/profile';
  static const String authDeleteAccount = '/auth/account';

  // Transactions
  static const String transactions = '/transactions';
  static const String transactionsWithText = '/transactions/createWithText';
  static const String transactionsMy = '/transactions/my';
  static const String transactionsByCategory = '/transactions/category'; // + /:categoryId
  static const String transactionsByDateRange = '/transactions/date-range';

  // Categories
  static const String categories = '/category';

  // Items
  static const String items = '/items';
  static const String itemsAddToCategory = '/items/add-to-category';
  static const String itemsRemoveFromCategory = '/items/remove-from-category';

  // Analytics
  static const String analyticsSummary = '/analytics/summary';
  static const String analyticsByCategory = '/analytics/by-category';
  static const String analyticsByDate = '/analytics/by-date';
  static const String analyticsTopCategories = '/analytics/top-categories';
  static const String analyticsTrends = '/analytics/trends';

  // Offers (Amazon personalized)
  static const String offers = '/api/offers';
  static const String offersPreview = '/api/offers/preview';

  // Export
  static const String export = '/export';

  // Health Check
  static const String healthCheck = '/api';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 5);
  static const Duration receiveTimeout = Duration(seconds: 10);
}
