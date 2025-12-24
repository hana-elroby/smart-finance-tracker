# State Management Guide - دليل إدارة الحالة

## 📚 ما هو Bloc؟

**Bloc (Business Logic Component)** هو pattern لإدارة الحالة في Flutter بيفصل الـ UI عن الـ Business Logic.

## 🎯 المفاهيم الأساسية

### 1. **Events** (الأحداث)
- الأفعال اللي المستخدم ممكن يعملها (مثال: ضغط زر، كتابة نص)
- Input للـ Bloc

### 2. **States** (الحالات)
- الأوضاع المختلفة للـ UI (مثال: Loading، Success، Error)
- Output من الـ Bloc

### 3. **Bloc** (العقل المدبر)
- بياخد Events وبيحولها لـ States
- فيه كل الـ Business Logic

## 📁 هيكل المشروع

```
lib/features/
├── splash/
│   └── presentation/
│       ├── bloc/
│       │   ├── splash_bloc.dart      # العقل المدبر
│       │   ├── splash_event.dart     # الأحداث
│       │   └── splash_state.dart     # الحالات
│       └── pages/
│           └── splash_page.dart      # الـ UI (معدلة لاستخدام Bloc)
│
├── onboarding/
│   └── presentation/
│       ├── bloc/
│       │   ├── onboarding_bloc.dart
│       │   ├── onboarding_event.dart
│       │   └── onboarding_state.dart
│       └── pages/
│
└── auth/
    └── presentation/
        ├── bloc/
        │   ├── auth_bloc.dart
        │   ├── auth_event.dart
        │   └── auth_state.dart
        └── pages/
```

## 🔄 كيف يعمل Bloc؟

```
المستخدم يضغط زر
    ↓
  Event يتم إرساله للـ Bloc
    ↓
  Bloc يعالج الـ Event
    ↓
  Bloc يطلع State جديد
    ↓
  UI تتحدث بناءً على الـ State
```

## 📝 أمثلة من المشروع

### مثال 1: Splash Screen

**Event:**
```dart
class StartSplashTimer extends SplashEvent {}
```

**States:**
```dart
class SplashInitial extends SplashState {}
class SplashLoading extends SplashState {}
class SplashNavigateToOnboarding extends SplashState {}
```

**الاستخدام في UI:**
```dart
BlocProvider(
  create: (context) => SplashBloc()..add(const StartSplashTimer()),
  child: BlocListener<SplashBloc, SplashState>(
    listener: (context, state) {
      if (state is SplashNavigateToOnboarding) {
        // Navigate to next screen
      }
    },
    child: // Your UI
  ),
)
```

### مثال 2: Onboarding

**Events:**
```dart
class PageChanged extends OnboardingEvent {
  final int pageIndex;
}
class NextPageRequested extends OnboardingEvent {}
class PreviousPageRequested extends OnboardingEvent {}
class SkipRequested extends OnboardingEvent {}
```

**State:**
```dart
class OnboardingState {
  final int currentPage;
  final bool isLastPage;
  final bool isFirstPage;
  final bool shouldNavigateToAuth;
}
```

**الاستخدام:**
```dart
// لإرسال Event
context.read<OnboardingBloc>().add(const NextPageRequested());

// للاستماع للـ State
BlocBuilder<OnboardingBloc, OnboardingState>(
  builder: (context, state) {
    return Text(state.isLastPage ? 'Get Started' : 'Next');
  },
)
```

### مثال 3: Authentication

**Events:**
```dart
class EmailChanged extends AuthEvent {
  final String email;
}
class PasswordChanged extends AuthEvent {
  final String password;
}
class LoginSubmitted extends AuthEvent {}
```

**State:**
```dart
class AuthState {
  final AuthStatus status;  // initial, loading, authenticated, error
  final String email;
  final String password;
  final String? emailError;
  final String? passwordError;
  final bool isFormValid;
}
```

**الاستخدام:**
```dart
// عند تغيير الإيميل
context.read<AuthBloc>().add(EmailChanged(email));

// عند الضغط على Login
context.read<AuthBloc>().add(LoginSubmitted(
  email: email,
  password: password,
));

// لعرض Loading
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state.status == AuthStatus.loading) {
      return CircularProgressIndicator();
    }
    return LoginButton();
  },
)
```

## 🛠️ Bloc Widgets الأساسية

### 1. **BlocProvider**
- بيوفر الـ Bloc لكل الـ widgets اللي تحته
```dart
BlocProvider(
  create: (context) => OnboardingBloc(),
  child: OnboardingPage(),
)
```

### 2. **BlocBuilder**
- بيعيد بناء الـ UI لما الـ State يتغير
```dart
BlocBuilder<OnboardingBloc, OnboardingState>(
  builder: (context, state) {
    return Text('Page ${state.currentPage}');
  },
)
```

### 3. **BlocListener**
- بينفذ أكشن واحد (مش rebuild) لما الـ State يتغير
- مثال: Navigation، SnackBar
```dart
BlocListener<SplashBloc, SplashState>(
  listener: (context, state) {
    if (state is SplashNavigateToOnboarding) {
      Navigator.pushNamed(context, '/onboarding');
    }
  },
  child: // Your UI
)
```

### 4. **BlocConsumer**
- مزيج من BlocBuilder و BlocListener
```dart
BlocConsumer<OnboardingBloc, OnboardingState>(
  listener: (context, state) {
    // للـ side effects
    if (state.shouldNavigateToAuth) {
      Navigator.push(context, AuthPage());
    }
  },
  builder: (context, state) {
    // للـ UI rebuilding
    return PageView(currentPage: state.currentPage);
  },
)
```

## ✅ أفضل الممارسات

1. **فصل المسؤوليات:**
   - Events = User Actions
   - States = UI States
   - Bloc = Business Logic

2. **استخدام Equatable:**
   - لمقارنة الـ States والـ Events بكفاءة
   ```dart
   class MyState extends Equatable {
     @override
     List<Object?> get props => [field1, field2];
   }
   ```

3. **State Immutability:**
   - دائماً استخدم `copyWith()` لتغيير الـ State
   ```dart
   emit(state.copyWith(currentPage: newPage));
   ```

4. **التعليقات بالعربي والإنجليزي:**
   - لسهولة الفهم للجميع

5. **Event Naming:**
   - استخدم أسماء واضحة: `NextPageRequested` بدل `Next`

## 🚀 كيف تضيف Feature جديد بـ Bloc؟

1. **أنشئ مجلد bloc:**
   ```
   lib/features/my_feature/presentation/bloc/
   ```

2. **أنشئ 3 ملفات:**
   - `my_feature_event.dart` - الأحداث
   - `my_feature_state.dart` - الحالات
   - `my_feature_bloc.dart` - الـ Logic

3. **في الـ Page:**
   ```dart
   BlocProvider(
     create: (context) => MyFeatureBloc(),
     child: MyFeaturePage(),
   )
   ```

4. **استخدم BlocBuilder/BlocListener حسب الحاجة**

## 📖 موارد إضافية

- [Bloc Documentation](https://bloclibrary.dev)
- [Flutter Bloc Package](https://pub.dev/packages/flutter_bloc)

---

**ملاحظة:** كل الملفات معلقة بالعربي والإنجليزي لسهولة الفهم! 🎯
