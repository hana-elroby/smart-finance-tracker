// API Configuration - إعدادات الـ API
// Configure your backend server URL here

class ApiConfig {
  // Change this to your actual server URL
  // For local development: 'http://localhost:3001' or 'http://10.0.2.2:3001' (Android emulator)
  // For production: 'https://your-api-domain.com'
  static const String baseUrl = 'http://10.141.103.179:3001';

  // API Endpoints
  static const String authSignup = '/auth/signup';
  static const String authConfirmOtp = '/auth/signup/configurationOTP';
  static const String authSignin = '/auth/signin';
  static const String authChangePassword = '/auth/changePassword';
  static const String authResendOtp = '/auth/resendOTP';

  static const String transactions = '/transactions';
  static const String transactionsWithText = '/transactions/createWithText';
  static const String transactionsWithVoice = '/transactions/createWithVoice';
  static const String transactionsWithOcr = '/transactions/createWithOCR';

  static const String categories = '/category';

  static const String aiAnalyze = '/ai/analyze';
  static const String aiVoice = '/ai/voice';

  static const String healthCheck = '/api';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
