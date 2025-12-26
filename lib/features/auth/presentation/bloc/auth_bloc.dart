// Auth Bloc - منطق المصادقة (Authentication Business Logic)
// Uses the backend API for authentication

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/auth_api_service.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/services/firebase_auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthApiService _authService = AuthApiService();
  final LocalStorageService _storage = LocalStorageService();
  final FirebaseAuthService _firebaseAuth = FirebaseAuthService();

  AuthBloc() : super(const AuthState()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<ResetFormState>(_onResetFormState);
    on<EmailChanged>(_onEmailChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<ConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<FullNameChanged>(_onFullNameChanged);
    on<PhoneChanged>(_onPhoneChanged);
    on<PasswordVisibilityToggled>(_onPasswordVisibilityToggled);
    on<ConfirmPasswordVisibilityToggled>(_onConfirmPasswordVisibilityToggled);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<SignUpSubmitted>(_onSignUpSubmitted);
    on<OtpSubmitted>(_onOtpSubmitted);
    on<ResendOtpRequested>(_onResendOtpRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<ChangePasswordRequested>(_onChangePasswordRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    await _authService.initialize();
    if (_authService.isLoggedIn) {
      emit(state.copyWith(status: AuthStatus.authenticated));
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  void _onResetFormState(ResetFormState event, Emitter<AuthState> emit) {
    emit(const AuthState());
  }

  void _onEmailChanged(EmailChanged event, Emitter<AuthState> emit) {
    final emailError = _validateEmail(event.email);
    emit(state.copyWith(
      email: event.email,
      emailError: emailError,
      isFormValid: _isLoginFormValid(
        email: event.email,
        password: state.password,
        emailError: emailError,
        passwordError: state.passwordError,
      ),
    ));
  }

  void _onPasswordChanged(PasswordChanged event, Emitter<AuthState> emit) {
    final passwordError = _validatePassword(event.password);
    emit(state.copyWith(
      password: event.password,
      passwordError: passwordError,
      isFormValid: _isLoginFormValid(
        email: state.email,
        password: event.password,
        emailError: state.emailError,
        passwordError: passwordError,
      ),
    ));
  }

  void _onConfirmPasswordChanged(
    ConfirmPasswordChanged event,
    Emitter<AuthState> emit,
  ) {
    String? confirmError;
    if (event.confirmPassword != state.password) {
      confirmError = 'Passwords do not match';
    }
    emit(state.copyWith(
      confirmPassword: event.confirmPassword,
      confirmPasswordError: confirmError,
    ));
  }

  void _onFullNameChanged(FullNameChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(fullName: event.fullName));
  }

  void _onPhoneChanged(PhoneChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(phone: event.phone));
  }

  void _onPasswordVisibilityToggled(
    PasswordVisibilityToggled event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  void _onConfirmPasswordVisibilityToggled(
    ConfirmPasswordVisibilityToggled event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(
      isConfirmPasswordVisible: !state.isConfirmPasswordVisible,
    ));
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final emailError = _validateEmail(event.email);
    final passwordError = _validatePassword(event.password);

    if (emailError != null || passwordError != null) {
      emit(state.copyWith(
        status: AuthStatus.error,
        emailError: emailError,
        passwordError: passwordError,
        errorMessage: 'Please fix the errors above',
      ));
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final result = await _authService.signin(
        email: event.email,
        password: event.password,
      );

      if (result.isSuccess) {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          errorMessage: null,
        ));
      } else {
        emit(state.copyWith(
          status: AuthStatus.error,
          errorMessage: result.message,
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Login failed: ${error.toString()}',
      ));
    }
  }

  Future<void> _onSignUpSubmitted(
    SignUpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final emailError = _validateEmail(event.email);
    final passwordError = _validatePassword(event.password);

    if (emailError != null || passwordError != null) {
      emit(state.copyWith(
        status: AuthStatus.error,
        emailError: emailError,
        passwordError: passwordError,
        errorMessage: 'Please fix the errors above',
      ));
      return;
    }

    if (event.password != event.confirmPassword) {
      emit(state.copyWith(
        status: AuthStatus.error,
        confirmPasswordError: 'Passwords do not match',
        errorMessage: 'Passwords do not match',
      ));
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final nameParts = (event.fullName ?? '').split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final result = await _authService.signup(
        firstName: firstName,
        lastName: lastName,
        email: event.email,
        password: event.password,
        phone: event.phone,
      );

      if (result.isSuccess) {
        emit(state.copyWith(
          status: AuthStatus.otpRequired,
          email: event.email,
          successMessage: result.message,
          errorMessage: null,
        ));
      } else {
        emit(state.copyWith(
          status: AuthStatus.error,
          errorMessage: result.message,
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Sign up failed: ${error.toString()}',
      ));
    }
  }

  Future<void> _onOtpSubmitted(
    OtpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (event.otp.length != 6) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Please enter a valid 6-digit OTP',
      ));
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final result = await _authService.confirmOtp(event.otp);

      if (result.isSuccess) {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          errorMessage: null,
        ));
      } else {
        emit(state.copyWith(
          status: AuthStatus.otpRequired,
          errorMessage: result.message,
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        status: AuthStatus.otpRequired,
        errorMessage: 'OTP verification failed: ${error.toString()}',
      ));
    }
  }

  Future<void> _onResendOtpRequested(
    ResendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final email = await _storage.getPendingEmail();
      if (email == null) {
        emit(state.copyWith(
          status: AuthStatus.otpRequired,
          errorMessage: 'Email not found. Please sign up again.',
        ));
        return;
      }

      final result = await _authService.resendOtp(email);

      emit(state.copyWith(
        status: AuthStatus.otpRequired,
        successMessage: result.isSuccess ? result.message : null,
        errorMessage: result.isSuccess ? null : result.message,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: AuthStatus.otpRequired,
        errorMessage: 'Failed to resend OTP',
      ));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authService.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  Future<void> _onChangePasswordRequested(
    ChangePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final result = await _authService.changePassword(
        oldPassword: event.oldPassword,
        newPassword: event.newPassword,
      );

      if (result.isSuccess) {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          successMessage: result.message,
          errorMessage: null,
        ));
      } else {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          errorMessage: result.message,
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        errorMessage: 'Failed to change password',
      ));
    }
  }

  String? _validateEmail(String email) {
    if (email.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!emailRegex.hasMatch(email)) return 'Please enter a valid email';
    return null;
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) return 'Password is required';
    if (password.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  bool _isLoginFormValid({
    required String email,
    required String password,
    String? emailError,
    String? passwordError,
  }) {
    return emailError == null &&
        passwordError == null &&
        email.isNotEmpty &&
        password.isNotEmpty;
  }

  // Google Sign In - Uses Firebase Auth
  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final result = await _firebaseAuth.signInWithGoogle();

      if (result.isSuccess && result.user != null) {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          errorMessage: null,
        ));
      } else {
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: result.message ?? 'Google Sign In failed',
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Google Sign In failed: ${error.toString()}',
      ));
    }
  }
}
