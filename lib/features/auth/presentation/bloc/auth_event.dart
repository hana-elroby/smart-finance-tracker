// Auth Events - أحداث المصادقة
// Events for authentication with backend API

import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// Check auth status on app start
class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

// Reset form state
class ResetFormState extends AuthEvent {
  const ResetFormState();
}

// Email changed
class EmailChanged extends AuthEvent {
  final String email;
  const EmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

// Password changed
class PasswordChanged extends AuthEvent {
  final String password;
  const PasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

// Confirm password changed
class ConfirmPasswordChanged extends AuthEvent {
  final String confirmPassword;
  const ConfirmPasswordChanged(this.confirmPassword);

  @override
  List<Object?> get props => [confirmPassword];
}

// Full name changed
class FullNameChanged extends AuthEvent {
  final String fullName;
  const FullNameChanged(this.fullName);

  @override
  List<Object?> get props => [fullName];
}

// Phone changed
class PhoneChanged extends AuthEvent {
  final String phone;
  const PhoneChanged(this.phone);

  @override
  List<Object?> get props => [phone];
}

// Toggle password visibility
class PasswordVisibilityToggled extends AuthEvent {
  const PasswordVisibilityToggled();
}

// Toggle confirm password visibility
class ConfirmPasswordVisibilityToggled extends AuthEvent {
  const ConfirmPasswordVisibilityToggled();
}

// Login submitted
class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmitted({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

// Sign up submitted
class SignUpSubmitted extends AuthEvent {
  final String email;
  final String password;
  final String confirmPassword;
  final String? fullName;
  final String? phone;

  const SignUpSubmitted({
    required this.email,
    required this.password,
    required this.confirmPassword,
    this.fullName,
    this.phone,
  });

  @override
  List<Object?> get props => [email, password, confirmPassword, fullName, phone];
}

// OTP submitted for verification
class OtpSubmitted extends AuthEvent {
  final String otp;

  const OtpSubmitted(this.otp);

  @override
  List<Object?> get props => [otp];
}

// Resend OTP
class ResendOtpRequested extends AuthEvent {
  const ResendOtpRequested();
}

// Logout
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

// Change password
class ChangePasswordRequested extends AuthEvent {
  final String oldPassword;
  final String newPassword;

  const ChangePasswordRequested({
    required this.oldPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [oldPassword, newPassword];
}

// Google Sign In (if supported by backend)
class GoogleSignInRequested extends AuthEvent {
  const GoogleSignInRequested();
}

// Facebook Sign In (if supported by backend)
class FacebookSignInRequested extends AuthEvent {
  const FacebookSignInRequested();
}

// Forgot password (if supported by backend)
class ForgotPasswordRequested extends AuthEvent {
  final String email;
  const ForgotPasswordRequested(this.email);

  @override
  List<Object?> get props => [email];
}
