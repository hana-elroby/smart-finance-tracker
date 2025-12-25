// Auth State - حالات المصادقة
// States for authentication with backend API

import 'package:equatable/equatable.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  otpRequired,  // New: waiting for OTP verification
  error,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final String email;
  final String password;
  final String confirmPassword;
  final String fullName;
  final String phone;
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;
  final String? errorMessage;
  final String? successMessage;
  final bool isFormValid;

  const AuthState({
    this.status = AuthStatus.initial,
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.fullName = '',
    this.phone = '',
    this.isPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
    this.errorMessage,
    this.successMessage,
    this.isFormValid = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? email,
    String? password,
    String? confirmPassword,
    String? fullName,
    String? phone,
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
    String? emailError,
    String? passwordError,
    String? confirmPasswordError,
    String? errorMessage,
    String? successMessage,
    bool? isFormValid,
  }) {
    return AuthState(
      status: status ?? this.status,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible:
          isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
      emailError: emailError,
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isFormValid: isFormValid ?? this.isFormValid,
    );
  }

  // Helper getters
  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isOtpRequired => status == AuthStatus.otpRequired;
  bool get hasError => status == AuthStatus.error;

  @override
  List<Object?> get props => [
        status,
        email,
        password,
        confirmPassword,
        fullName,
        phone,
        isPasswordVisible,
        isConfirmPasswordVisible,
        emailError,
        passwordError,
        confirmPasswordError,
        errorMessage,
        successMessage,
        isFormValid,
      ];
}
