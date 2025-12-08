part of 'auth_bloc.dart';

// الأحداث (Events) اللي ممكن تحصل في Auth
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

// Event لما المستخدم يضغط Login
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

// Event لما المستخدم يضغط Sign Up
class SignUpRequested extends AuthEvent {
  final String fullName;
  final String email;
  final String mobile;
  final String dateOfBirth;
  final String password;

  const SignUpRequested({
    required this.fullName,
    required this.email,
    required this.mobile,
    required this.dateOfBirth,
    required this.password,
  });

  @override
  List<Object> get props => [fullName, email, mobile, dateOfBirth, password];
}

// Event لما المستخدم يضغط Logout
class LogoutRequested extends AuthEvent {}
