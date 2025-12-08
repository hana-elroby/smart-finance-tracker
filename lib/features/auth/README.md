# Auth Feature مع BLoC 🔐

## اللي عملناه:

أضفنا **BLoC Pattern** لـ Authentication (Login & Sign Up) مع Firebase.

---

## 📁 الملفات:

### 1. BLoC Files:
```
auth/
├── bloc/
│   ├── auth_bloc.dart       # المنطق الرئيسي
│   ├── auth_event.dart      # الأحداث
│   └── auth_state.dart      # الحالات
└── presentation/
    └── pages/
        ├── login_page.dart  # صفحة Login
        └── signup_page.dart # صفحة Sign Up
```

---

## 🎯 الـ Events (الأحداث):

### 1. LoginRequested
**متى يحصل؟** لما المستخدم يضغط زرار Login

**البيانات:**
- `email` - البريد الإلكتروني
- `password` - كلمة المرور

### 2. SignUpRequested
**متى يحصل؟** لما المستخدم يضغط زرار Sign Up

**البيانات:**
- `fullName` - الاسم الكامل
- `email` - البريد الإلكتروني
- `mobile` - رقم الموبايل
- `dateOfBirth` - تاريخ الميلاد
- `password` - كلمة المرور

### 3. GoogleSignInRequested
**متى يحصل؟** لما المستخدم يضغط زرار Google Sign In

### 4. FacebookSignInRequested
**متى يحصل؟** لما المستخدم يضغط زرار Facebook Sign In

### 5. LogoutRequested
**متى يحصل؟** لما المستخدم يضغط زرار Logout

---

## 📊 الـ States (الحالات):

### 1. AuthInitial
**الحالة الأولية** - لما التطبيق يفتح أول مرة

### 2. AuthLoading
**بنحمل** - لما بنحاول نعمل Login أو Sign Up

**في الـ UI:**
- نعرض CircularProgressIndicator
- نعطل الأزرار

### 3. AuthSuccess
**نجح!** - لما Login أو Sign Up ينجح

**البيانات:**
- `userId` - معرف المستخدم
- `userName` - اسم المستخدم
- `email` - البريد الإلكتروني

**في الـ UI:**
- نعرض رسالة نجاح
- نروح للـ Home Page

### 4. AuthFailure
**فشل!** - لما Login أو Sign Up يفشل

**البيانات:**
- `errorMessage` - رسالة الخطأ

**في الـ UI:**
- نعرض SnackBar بالخطأ

### 5. AuthLoggedOut
**تم تسجيل الخروج** - لما المستخدم يعمل Logout

---

## 🔄 التدفق (Flow):

### Login Flow:
```
المستخدم يكتب Email و Password
        ↓
يضغط زرار "Log In"
        ↓
بنبعت LoginRequested Event للـ BLoC
        ↓
BLoC يبعت AuthLoading State
        ↓
UI يعرض Loading
        ↓
BLoC يحاول يعمل Login من Firebase
        ↓
لو نجح:
  - BLoC يبعت AuthSuccess State
  - UI يعرض رسالة نجاح
  - UI يروح للـ Home Page
        ↓
لو فشل:
  - BLoC يبعت AuthFailure State
  - UI يعرض رسالة الخطأ
```

### Sign Up Flow:
```
المستخدم يملأ البيانات
        ↓
يضغط زرار "Sign Up"
        ↓
بنبعت SignUpRequested Event للـ BLoC
        ↓
BLoC يبعت AuthLoading State
        ↓
UI يعرض Loading
        ↓
BLoC يحاول يعمل Sign Up في Firebase
        ↓
لو نجح:
  - BLoC يبعت AuthSuccess State
  - UI يعرض رسالة نجاح
  - UI يروح للـ Home Page
        ↓
لو فشل:
  - BLoC يبعت AuthFailure State
  - UI يعرض رسالة الخطأ
```

---

## 🔥 Firebase Integration:

### الـ BLoC بيستخدم:
- `FirebaseAuth` - للـ Email/Password Authentication
- `GoogleSignIn` - للـ Google Sign In

### رسائل الأخطاء بالعربي:
```dart
'user-not-found' → 'البريد الإلكتروني غير مسجل'
'wrong-password' → 'كلمة المرور غير صحيحة'
'invalid-email' → 'البريد الإلكتروني غير صالح'
'email-already-in-use' → 'البريد الإلكتروني مستخدم بالفعل'
'weak-password' → 'كلمة المرور ضعيفة جداً'
```

---

## 💻 الكود المهم:

### في Login Page:
```dart
// تسجيل الـ BLoC
BlocProvider(
  create: (context) => AuthBloc(),
  child: const LoginView(),
)

// إرسال Event
context.read<AuthBloc>().add(
  LoginRequested(
    email: _emailController.text.trim(),
    password: _passwordController.text,
  ),
);

// الاستماع للـ State
BlocConsumer<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthSuccess) {
      // نروح للـ Home
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else if (state is AuthFailure) {
      // نعرض الخطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage)),
      );
    }
  },
  builder: (context, state) {
    final isLoading = state is AuthLoading;
    // نعرض Loading أو الـ UI العادي
  },
)
```

---

## ✅ المميزات:

### 1. منظم ونضيف
- المنطق منفصل عن الواجهة
- سهل تعديل أي حاجة

### 2. User Experience ممتاز
- Loading Indicator لما بنحمل
- رسائل نجاح وفشل واضحة
- الأزرار بتتعطل لما بنحمل

### 3. Error Handling قوي
- كل أخطاء Firebase متعاملين معاها
- رسائل الأخطاء بالعربي

### 4. سهل التطوير
- لو عايزة تضيفي Facebook Sign In، بس اكتبي الكود في `_onFacebookSignInRequested`
- لو عايزة تضيفي Apple Sign In، اعملي Event جديد

---

## 🚀 إزاي تجرب؟

### 1. تأكدي إن Firebase متفعل:
- Firebase Auth enabled في Console
- Google Sign In enabled (لو هتستخدميه)

### 2. شغلي التطبيق:
```bash
flutter run
```

### 3. جربي:
- اضغطي "Sign Up" واعملي حساب جديد
- هتروحي للـ Home Page فورًا!
- ارجعي للـ Auth Page وجربي Login
- جربي Google Sign In

---

## 📝 ملاحظات:

### Facebook Sign In:
- محتاج تضيفي `flutter_facebook_auth` package
- محتاج تعملي Facebook App في Facebook Developers
- محتاج تضيفي الـ Configuration في Firebase

### Apple Sign In:
- محتاج تضيفي `sign_in_with_apple` package
- بيشتغل بس على iOS

### Offline Support:
- Firebase Auth بيحفظ الـ Session تلقائياً
- لو المستخدم سجل دخول، هيفضل مسجل حتى لو قفل التطبيق

---

## 🎓 للتطوير المستقبلي:

### 1. Email Verification:
```dart
await user.sendEmailVerification();
```

### 2. Password Reset:
```dart
await _firebaseAuth.sendPasswordResetEmail(email: email);
```

### 3. Profile Update:
```dart
await user.updateDisplayName(newName);
await user.updatePhotoURL(photoUrl);
```

### 4. Delete Account:
```dart
await user.delete();
```

---

## 🎯 الخلاصة:

**دلوقتي عندك:**
- ✅ Login شغال مع BLoC
- ✅ Sign Up شغال مع BLoC
- ✅ Google Sign In جاهز
- ✅ Error Handling قوي
- ✅ Loading States
- ✅ Navigation للـ Home بعد النجاح

**كل حاجة منظمة واحترافية! 💪**
