part of 'auth_bloc.dart';

// الحالات (States) اللي التطبيق ممكن يكون فيها
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

// الحالة الأولية (لما التطبيق يفتح)
class AuthInitial extends AuthState {}

// لما بنحاول نعمل Login أو Sign Up (Loading)
class AuthLoading extends AuthState {}

// لما Login أو Sign Up ينجح
class AuthSuccess extends AuthState {
  final String userId;
  final String userName;
  final String email;

  const AuthSuccess({
    required this.userId,
    required this.userName,
    required this.email,
  });

  @override
  List<Object> get props => [userId, userName, email];
}

// لما Login أو Sign Up يفشل
class AuthFailure extends AuthState {
  final String errorMessage;

  const AuthFailure({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}

// لما المستخدم يعمل Logout
class AuthLoggedOut extends AuthState {}
