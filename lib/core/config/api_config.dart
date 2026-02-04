// API Configuration - إعدادات الـ API
// Configure your backend server URLs here

class ApiConfig {
  // Main Backend API (your graduation project backend)
  static const String baseUrl = 'https://graduation-project-21p3.onrender.com';

  // Voice Analysis API (separate voice server)
  static const String voiceApiBaseUrl = 'https://gradution-project-u39v.onrender.com';
  static const String voiceAnalyzeText = '/analyze';
  static const String voiceAnalyzeAudio = '/voice';

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
