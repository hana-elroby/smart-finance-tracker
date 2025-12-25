// Auth API Service - خدمة المصادقة
// Handles all authentication API calls

import 'api_service.dart';
import '../models/user_model.dart';
import 'local_storage_service.dart';

class AuthApiService {
  static final AuthApiService instance = AuthApiService._internal();
  AuthApiService._internal();
  factory AuthApiService() => instance;

  final ApiService _api = ApiService();
  final LocalStorageService _storage = LocalStorageService();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _api.isAuthenticated && _currentUser != null;

  // Initialize - load saved token and user
  Future<void> initialize() async {
    final token = await _storage.getToken();
    final userData = await _storage.getUser();

    if (token != null && userData != null) {
      _api.setToken(token);
      _currentUser = UserModel.fromMap(userData);
    }
  }

  // Signup - Register new user
  Future<AuthApiResult> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
    String countryCode = '+20',
    String country = 'Egypt',
  }) async {
    final response = await _api.post('/auth/signup', body: {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'phone': phone ?? '',
      'countryCode': countryCode,
      'country': country,
    });

    if (response.isSuccess) {
      // Store email for OTP verification
      await _storage.savePendingEmail(email);
      return AuthApiResult.success(message: response.message ?? 'OTP sent to email');
    } else {
      return AuthApiResult.failure(
        message: response.message ?? 'Signup failed',
        isEmailTaken: response.data?['flag'] == true,
      );
    }
  }

  // Confirm OTP - Verify email with OTP
  Future<AuthApiResult> confirmOtp(String otp) async {
    final response = await _api.post('/auth/signup/configurationOTP', body: {
      'otp': otp,
    });

    if (response.isSuccess) {
      final token = response.getData<String>('token');
      final userData = response.getData<Map<String, dynamic>>('user');

      if (token != null) {
        _api.setToken(token);
        await _storage.saveToken(token);

        if (userData != null) {
          _currentUser = UserModel.fromMap(_convertUserData(userData));
          await _storage.saveUser(_currentUser!.toMap());
        }

        return AuthApiResult.success(user: _currentUser, token: token);
      }
    }

    return AuthApiResult.failure(message: response.message ?? 'OTP verification failed');
  }

  // Signin - Login with email and password
  Future<AuthApiResult> signin({
    required String email,
    required String password,
  }) async {
    final response = await _api.post('/auth/signin', body: {
      'email': email,
      'password': password,
    });

    if (response.isSuccess) {
      final token = response.getData<String>('token');
      final userData = response.getData<Map<String, dynamic>>('user');

      if (token != null) {
        _api.setToken(token);
        await _storage.saveToken(token);

        if (userData != null) {
          _currentUser = UserModel.fromMap(_convertUserData(userData));
          await _storage.saveUser(_currentUser!.toMap());
        }

        return AuthApiResult.success(user: _currentUser, token: token);
      }
    }

    return AuthApiResult.failure(message: response.message ?? 'Login failed');
  }

  // Change Password
  Future<AuthApiResult> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final response = await _api.post('/auth/changePassword', body: {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    });

    if (response.isSuccess) {
      final token = response.getData<String>('token');
      if (token != null) {
        _api.setToken(token);
        await _storage.saveToken(token);
      }
      return AuthApiResult.success(message: 'Password changed successfully');
    }

    return AuthApiResult.failure(message: response.message ?? 'Failed to change password');
  }

  // Resend OTP
  Future<AuthApiResult> resendOtp(String email) async {
    final response = await _api.post('/auth/resendOTP', body: {
      'email': email,
    });

    if (response.isSuccess) {
      return AuthApiResult.success(message: response.message ?? 'OTP sent');
    }

    return AuthApiResult.failure(message: response.message ?? 'Failed to resend OTP');
  }

  // Get Profile
  Future<AuthApiResult> getProfile() async {
    final response = await _api.get('/auth/profile');

    if (response.isSuccess) {
      final userData = response.getData<Map<String, dynamic>>('user') ?? response.data;
      if (userData != null) {
        _currentUser = UserModel.fromMap(_convertUserData(userData));
        await _storage.saveUser(_currentUser!.toMap());
        return AuthApiResult.success(user: _currentUser);
      }
    }

    return AuthApiResult.failure(message: response.message ?? 'Failed to get profile');
  }

  // Update Profile
  Future<AuthApiResult> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    final body = <String, dynamic>{};
    if (firstName != null) body['firstName'] = firstName;
    if (lastName != null) body['lastName'] = lastName;
    if (phone != null) body['phone'] = phone;

    final response = await _api.put('/auth/profile', body: body);

    if (response.isSuccess) {
      final userData = response.getData<Map<String, dynamic>>('user') ?? response.data;
      if (userData != null) {
        _currentUser = UserModel.fromMap(_convertUserData(userData));
        await _storage.saveUser(_currentUser!.toMap());
      }
      return AuthApiResult.success(user: _currentUser, message: 'Profile updated');
    }

    return AuthApiResult.failure(message: response.message ?? 'Failed to update profile');
  }

  // Forget Password - Request reset email
  Future<AuthApiResult> forgetPassword(String email) async {
    final response = await _api.post('/auth/forgetPassword', body: {
      'email': email,
    });

    if (response.isSuccess) {
      return AuthApiResult.success(message: response.message ?? 'Reset email sent');
    }

    return AuthApiResult.failure(message: response.message ?? 'Failed to send reset email');
  }

  // Set New Password - After reset
  Future<AuthApiResult> setNewPassword({
    required String token,
    required String newPassword,
  }) async {
    final response = await _api.post('/auth/setNewPassword?token=$token', body: {
      'newPassword': newPassword,
    });

    if (response.isSuccess) {
      return AuthApiResult.success(message: 'Password reset successfully');
    }

    return AuthApiResult.failure(message: response.message ?? 'Failed to reset password');
  }

  // Delete Account
  Future<AuthApiResult> deleteAccount(String password) async {
    final response = await _api.delete('/auth/account', body: {
      'password': password,
    });

    if (response.isSuccess) {
      await logout();
      return AuthApiResult.success(message: 'Account deleted');
    }

    return AuthApiResult.failure(message: response.message ?? 'Failed to delete account');
  }

  // Logout
  Future<void> logout() async {
    _api.clearToken();
    _currentUser = null;
    await _storage.clearAll();
  }

  // Convert API user data to our model format
  Map<String, dynamic> _convertUserData(Map<String, dynamic> apiData) {
    return {
      'uid': apiData['_id'] ?? '',
      'email': apiData['email'] ?? '',
      'displayName': apiData['fullname'] ?? apiData['firstName'] ?? '',
      'phoneNumber': apiData['phone'],
      'createdAt': apiData['createdAt'] ?? DateTime.now().toIso8601String(),
    };
  }
}

// Auth API Result
class AuthApiResult {
  final bool isSuccess;
  final UserModel? user;
  final String? token;
  final String? message;
  final bool isEmailTaken;

  AuthApiResult._({
    required this.isSuccess,
    this.user,
    this.token,
    this.message,
    this.isEmailTaken = false,
  });

  factory AuthApiResult.success({
    UserModel? user,
    String? token,
    String? message,
  }) {
    return AuthApiResult._(
      isSuccess: true,
      user: user,
      token: token,
      message: message,
    );
  }

  factory AuthApiResult.failure({
    required String message,
    bool isEmailTaken = false,
  }) {
    return AuthApiResult._(
      isSuccess: false,
      message: message,
      isEmailTaken: isEmailTaken,
    );
  }
}
