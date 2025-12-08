import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AuthBloc() : super(AuthInitial()) {
    // لما يحصل LoginRequested Event
    on<LoginRequested>(_onLoginRequested);

    // لما يحصل SignUpRequested Event
    on<SignUpRequested>(_onSignUpRequested);

    // لما يحصل LogoutRequested Event
    on<LogoutRequested>(_onLogoutRequested);
  }

  // معالجة Login
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // محاولة تسجيل الدخول باستخدام Firebase
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      final user = userCredential.user;
      if (user != null) {
        emit(AuthSuccess(
          userId: user.uid,
          userName: user.displayName ?? 'User',
          email: user.email ?? event.email,
        ));
      } else {
        emit(const AuthFailure(errorMessage: 'فشل تسجيل الدخول'));
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'حدث خطأ أثناء تسجيل الدخول';

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'البريد الإلكتروني غير مسجل';
          break;
        case 'wrong-password':
          errorMessage = 'كلمة المرور غير صحيحة';
          break;
        case 'invalid-email':
          errorMessage = 'البريد الإلكتروني غير صالح';
          break;
        case 'user-disabled':
          errorMessage = 'هذا الحساب معطل';
          break;
        case 'too-many-requests':
          errorMessage = 'محاولات كثيرة، حاول لاحقاً';
          break;
        default:
          errorMessage = e.message ?? errorMessage;
      }

      emit(AuthFailure(errorMessage: errorMessage));
    } catch (e) {
      emit(AuthFailure(errorMessage: 'حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }

  // معالجة Sign Up
  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // محاولة إنشاء حساب جديد باستخدام Firebase
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      final user = userCredential.user;
      if (user != null) {
        // تحديث اسم المستخدم
        await user.updateDisplayName(event.fullName);

        emit(AuthSuccess(
          userId: user.uid,
          userName: event.fullName,
          email: event.email,
        ));
      } else {
        emit(const AuthFailure(errorMessage: 'فشل إنشاء الحساب'));
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'حدث خطأ أثناء إنشاء الحساب';

      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'البريد الإلكتروني مستخدم بالفعل';
          break;
        case 'invalid-email':
          errorMessage = 'البريد الإلكتروني غير صالح';
          break;
        case 'weak-password':
          errorMessage = 'كلمة المرور ضعيفة جداً';
          break;
        case 'operation-not-allowed':
          errorMessage = 'العملية غير مسموح بها';
          break;
        default:
          errorMessage = e.message ?? errorMessage;
      }

      emit(AuthFailure(errorMessage: errorMessage));
    } catch (e) {
      emit(AuthFailure(errorMessage: 'حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }

  // معالجة Logout
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await _firebaseAuth.signOut();
      emit(AuthLoggedOut());
    } catch (e) {
      emit(AuthFailure(errorMessage: 'فشل تسجيل الخروج: ${e.toString()}'));
    }
  }
}
