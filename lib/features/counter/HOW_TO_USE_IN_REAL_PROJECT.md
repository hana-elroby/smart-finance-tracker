# إزاي تطبقي BLoC في مشروعك الحقيقي 🚀

## مثال حقيقي: Login Feature

خلينا نشوف إزاي نعمل Login باستخدام BLoC خطوة بخطوة:

---

## 1️⃣ تحديد الـ Events (الأحداث)

**اسألي نفسك: إيه اللي المستخدم ممكن يعمله؟**

```dart
// lib/features/auth/bloc/auth_event.dart

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

// لما المستخدم يضغط زرار Login
class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  
  const LoginRequested({required this.email, required this.password});
  
  @override
  List<Object> get props => [email, password];
}

// لما المستخدم يضغط زرار Logout
class LogoutRequested extends AuthEvent {}

// لما المستخدم يضغط زرار Sign Up
class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  
  const SignUpRequested({
    required this.email,
    required this.password,
    required this.name,
  });
  
  @override
  List<Object> get props => [email, password, name];
}
```

**بالبلدي:** دي كل الحاجات اللي المستخدم ممكن يعملها في شاشة Login.

---

## 2️⃣ تحديد الـ States (الحالات)

**اسألي نفسك: إيه الحالات اللي الشاشة ممكن تكون فيها؟**

```dart
// lib/features/auth/bloc/auth_state.dart

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object> get props => [];
}

// الحالة الأولية (لما التطبيق يفتح)
class AuthInitial extends AuthState {}

// لما بنحاول نعمل Login (Loading)
class AuthLoading extends AuthState {}

// لما Login ينجح
class AuthSuccess extends AuthState {
  final String userId;
  final String userName;
  
  const AuthSuccess({required this.userId, required this.userName});
  
  @override
  List<Object> get props => [userId, userName];
}

// لما Login يفشل
class AuthFailure extends AuthState {
  final String errorMessage;
  
  const AuthFailure({required this.errorMessage});
  
  @override
  List<Object> get props => [errorMessage];
}

// لما المستخدم يعمل Logout
class AuthLoggedOut extends AuthState {}
```

**بالبلدي:** دي كل الحالات اللي الشاشة ممكن تكون فيها (بتحمل، نجحت، فشلت، إلخ).

---

## 3️⃣ كتابة الـ BLoC (المنطق)

```dart
// lib/features/auth/bloc/auth_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/auth_repository.dart'; // هنعمله بعدين

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  
  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    // لما يحصل LoginRequested Event
    on<LoginRequested>((event, emit) async {
      // 1. نبدأ بـ Loading State
      emit(AuthLoading());
      
      try {
        // 2. نحاول نعمل Login من خلال Repository
        final user = await authRepository.login(
          email: event.email,
          password: event.password,
        );
        
        // 3. لو نجح، نبعت Success State
        emit(AuthSuccess(
          userId: user.id,
          userName: user.name,
        ));
      } catch (e) {
        // 4. لو فشل، نبعت Failure State
        emit(AuthFailure(errorMessage: e.toString()));
      }
    });
    
    // لما يحصل LogoutRequested Event
    on<LogoutRequested>((event, emit) async {
      emit(AuthLoading());
      
      try {
        await authRepository.logout();
        emit(AuthLoggedOut());
      } catch (e) {
        emit(AuthFailure(errorMessage: e.toString()));
      }
    });
    
    // لما يحصل SignUpRequested Event
    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      
      try {
        final user = await authRepository.signUp(
          email: event.email,
          password: event.password,
          name: event.name,
        );
        
        emit(AuthSuccess(
          userId: user.id,
          userName: user.name,
        ));
      } catch (e) {
        emit(AuthFailure(errorMessage: e.toString()));
      }
    });
  }
}
```

**بالبلدي:** ده المخ اللي بيفكر ويقرر إيه اللي يحصل لما Event يجي.

---

## 4️⃣ عمل Repository (للتعامل مع API/Database)

```dart
// lib/features/auth/data/auth_repository.dart

import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  
  // Login
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      return UserModel(
        id: userCredential.user!.uid,
        name: userCredential.user!.displayName ?? 'User',
        email: email,
      );
    } catch (e) {
      throw Exception('فشل تسجيل الدخول: ${e.toString()}');
    }
  }
  
  // Sign Up
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      await userCredential.user!.updateDisplayName(name);
      
      return UserModel(
        id: userCredential.user!.uid,
        name: name,
        email: email,
      );
    } catch (e) {
      throw Exception('فشل إنشاء الحساب: ${e.toString()}');
    }
  }
  
  // Logout
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}

// Model للـ User
class UserModel {
  final String id;
  final String name;
  final String email;
  
  UserModel({
    required this.id,
    required this.name,
    required this.email,
  });
}
```

**بالبلدي:** ده اللي بيكلم Firebase أو أي API عشان يجيب أو يبعت بيانات.

---

## 5️⃣ استخدام BLoC في الـ UI

```dart
// lib/features/auth/presentation/pages/login_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth_bloc.dart';
import '../../data/auth_repository.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // تسجيل الـ BLoC
    return BlocProvider(
      create: (context) => AuthBloc(authRepository: AuthRepository()),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل الدخول')),
      body: BlocConsumer<AuthBloc, AuthState>(
        // Listener للتعامل مع Navigation أو Dialogs
        listener: (context, state) {
          if (state is AuthSuccess) {
            // لو Login نجح، نروح للـ Home
            Navigator.pushReplacementNamed(context, '/home');
          } else if (state is AuthFailure) {
            // لو فشل، نعرض رسالة خطأ
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage)),
            );
          }
        },
        // Builder لتحديث الـ UI
        builder: (context, state) {
          // لو بنحمل، نعرض Loading
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Email Field
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Password Field
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'كلمة المرور',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 30),
                
                // Login Button
                ElevatedButton(
                  onPressed: () {
                    // بنبعت LoginRequested Event للـ BLoC
                    context.read<AuthBloc>().add(
                      LoginRequested(
                        email: _emailController.text,
                        password: _passwordController.text,
                      ),
                    );
                  },
                  child: const Text('تسجيل الدخول'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
```

**بالبلدي:** ده الشاشة اللي المستخدم بيشوفها، وبتستخدم BLoC عشان تعرض البيانات وتتفاعل مع المستخدم.

---

## 6️⃣ الفرق بين BlocBuilder و BlocListener و BlocConsumer

### BlocBuilder:
- بيستخدم لما عايزة **تحدثي الـ UI** بناءً على الـ State
- مثال: عرض Loading أو عرض البيانات

### BlocListener:
- بيستخدم لما عايزة **تعملي حاجة واحدة** بناءً على الـ State
- مثال: Navigation، عرض Dialog، عرض SnackBar

### BlocConsumer:
- **الاتنين مع بعض!**
- بيستخدم لما عايزة تحدثي الـ UI **و** تعملي حاجة تانية

---

## 7️⃣ Testing الـ BLoC

```dart
// test/features/auth/bloc/auth_bloc_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('AuthBloc', () {
    late AuthRepository mockRepository;
    late AuthBloc authBloc;

    setUp(() {
      mockRepository = MockAuthRepository();
      authBloc = AuthBloc(authRepository: mockRepository);
    });

    test('initial state is AuthInitial', () {
      expect(authBloc.state, AuthInitial());
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] when login succeeds',
      build: () {
        when(() => mockRepository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => UserModel(
          id: '123',
          name: 'Test User',
          email: 'test@test.com',
        ));
        return authBloc;
      },
      act: (bloc) => bloc.add(const LoginRequested(
        email: 'test@test.com',
        password: 'password123',
      )),
      expect: () => [
        AuthLoading(),
        const AuthSuccess(userId: '123', userName: 'Test User'),
      ],
    );
  });
}
```

**بالبلدي:** ده Testing عشان نتأكد إن الـ BLoC بيشتغل صح.

---

## الخلاصة النهائية 🎯

### الخطوات:
1. **حددي الـ Events** (إيه اللي المستخدم ممكن يعمله؟)
2. **حددي الـ States** (إيه الحالات اللي الشاشة ممكن تكون فيها؟)
3. **اكتبي الـ BLoC** (المنطق اللي بيحصل لما Event يجي)
4. **اعملي Repository** (للتعامل مع API/Database)
5. **استخدمي BLoC في الـ UI** (BlocProvider, BlocBuilder, BlocListener)
6. **اعملي Testing** (عشان تتأكدي إن كل حاجة شغالة)

### نصائح مهمة:
- ابدأي بـ Feature واحد بسيط (زي Counter)
- بعدين طبقي على Feature حقيقي (زي Login)
- متخافيش من الـ Boilerplate، ده بيخلي الكود منظم
- استخدمي Extensions في VS Code عشان تسهل الشغل

### Extensions مفيدة:
- **Bloc** (by Felix Angelov) - بيعملك Code Generation
- **Bloc Snippets** - بيسهل كتابة الكود

---

**بالتوفيق في مشروع التخرج! 💪🎓**
