# 🔥 Firebase Authentication Setup

## لماذا Firebase Auth؟
- ✅ OTP تلقائي على الإيميل والموبايل
- ✅ مجاني حتى 10,000 مستخدم شهرياً
- ✅ آمن ومضمون من Google
- ✅ سهل التطبيق

## خطوات الإعداد:

### 1. إنشاء مشروع Firebase
1. اذهب لـ https://console.firebase.google.com
2. اضغط "Create a project"
3. اكتب اسم المشروع: "Smart Finance Tracker"
4. فعل Google Analytics (اختياري)

### 2. إضافة Android App
1. اضغط Android icon
2. Package name: `com.example.graduation_project`
3. حمل `google-services.json`
4. ضعه في `android/app/`

### 3. تفعيل Authentication
1. اذهب لـ Authentication > Sign-in method
2. فعل Email/Password
3. فعل Phone (للـ SMS OTP)

### 4. إضافة Dependencies
```yaml
# في pubspec.yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
```

### 5. تحديث الكود
```dart
// في main.dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

// خدمة Firebase Auth
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // إرسال OTP للإيميل
  Future<void> sendEmailVerification() async {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }
  
  // تسجيل مستخدم جديد
  Future<UserCredential?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // إرسال OTP تلقائياً
      await result.user?.sendEmailVerification();
      return result;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
```

## المميزات:
- 🚀 OTP فوري على الإيميل
- 📱 دعم SMS OTP للموبايل
- 🔒 حماية قوية
- 📊 إحصائيات مفصلة