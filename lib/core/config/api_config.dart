// API Configuration - إعدادات الـ API
// Configure your backend server URL here

class ApiConfig {
  // Change this to your actual server URL
  // For local development: 'http://localhost:3001' or 'http://10.0.2.2:3001' (Android emulator)
  // For production: 'https://your-api-domain.com'
  static const String baseUrl = 'https://graduation-project-21p3.onrender.com';

  // Voice API Configuration
  static const String voiceApiBaseUrl = 'https://voice-finance-analyzer-production.up.railway.app';
  static const String voiceAnalyzeText = '/analyze-text';
  static const String voiceAnalyzeAudio = '/analyze-audio';

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
