// Local Storage Service - خدمة التخزين المحلي
// Handles secure local storage for tokens and user data

import 'dart:convert';
import '../storage/secure_storage.dart';

class LocalStorageService {
  static final LocalStorageService instance = LocalStorageService._internal();
  LocalStorageService._internal();
  factory LocalStorageService() => instance;

  final SecureStorage _storage = SecureStorage();

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _pendingEmailKey = 'pending_email';
  static const String _onboardingKey = 'onboarding_complete';

  // Token operations
  Future<void> saveToken(String token) async {
    await _storage.saveTokens(accessToken: token, refreshToken: '');
  }

  Future<String?> getToken() async {
    return await _storage.getAccessToken();
  }

  Future<void> clearToken() async {
    await _storage.clearTokens();
  }

  // User data operations
  Future<void> saveUser(Map<String, dynamic> userData) async {
    await _storage.saveUser(userData);
  }

  Future<Map<String, dynamic>?> getUser() async {
    return await _storage.getUser();
  }

  Future<void> clearUser() async {
    await _storage.clearUser();
  }

  // Pending email for OTP verification
  Future<void> savePendingEmail(String email) async {
    await _storage.savePendingEmail(email);
  }

  Future<String?> getPendingEmail() async {
    return await _storage.getPendingEmail();
  }

  Future<void> clearPendingEmail() async {
    await _storage.clearPendingEmail();
  }

  // Onboarding status - using simple key-value storage
  Future<void> setOnboardingComplete() async {
    await _storage.saveUser({'onboarding_complete': true});
  }

  Future<bool> isOnboardingComplete() async {
    final userData = await _storage.getUser();
    return userData?['onboarding_complete'] == true;
  }

  // Clear all data
  Future<void> clearAll() async {
    await _storage.clearAll();
  }
}
