# 🔄 Sync Strategy - دليل المزامنة

## 📊 الفكرة:

```
Offline-First Architecture
↓
البيانات تتحفظ محلياً أولاً (Local Database)
↓
لما النت يرجع، تتبعت للسيرفر (Remote Database)
```

---

## 🎯 إزاي بيشتغل؟

### 1️⃣ المستخدم يضيف مصروف (مفيش نت):
```dart
// يتحفظ في Local Database
Expense expense = Expense(
  title: "قهوة",
  amount: 25.0,
  isSynced: 0, // ← مش متزامن
  ...
);
await dbHelper.addExpense(expense.toMap());
```

### 2️⃣ النت يرجع تلقائياً:
```dart
// SyncService بيكتشف إن النت رجع
// ويبدأ يبعت المصاريف للسيرفر تلقائياً
```

### 3️⃣ بعد الإرسال:
```dart
// يعلم المصروف كمتزامن
isSynced: 1 // ← متزامن ✅
```

---

## 💻 الاستخدام:

### في main.dart:
```dart
import 'core/services/sync_service.dart';

void main() {
  // ابدأ الـ Sync Service
  SyncService().startListening();
  
  runApp(const MyApp());
}
```

### زرار Sync يدوي:
```dart
IconButton(
  icon: Icon(Icons.sync),
  onPressed: () async {
    await SyncService().manualSync();
  },
)
```

---

## 🔍 الملفات المهمة:

1. **sync_service.dart** - الخدمة الرئيسية
2. **database_helper.dart** - فيه functions للـ sync
3. **expense_model.dart** - فيه حقل `isSynced`

---

## ⚙️ الإعدادات المطلوبة:

### Android (android/app/src/main/AndroidManifest.xml):
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

### iOS (ios/Runner/Info.plist):
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

---

## 🚀 الخطوة الجاية:

لما يكون عندك Backend جاهز، غيري function `_sendToServer` في sync_service.dart:

```dart
Future<bool> _sendToServer(Expense expense) async {
  try {
    final response = await http.post(
      Uri.parse('https://your-api.com/expenses'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(expense.toMap()),
    );
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}
```

---

## ✅ المميزات:

- ✅ يشتغل offline
- ✅ sync تلقائي لما النت يرجع
- ✅ sync يدوي بزرار
- ✅ تتبع حالة كل مصروف (متزامن ولا لأ)
- ✅ مفيش فقد بيانات

---

**دلوقتي عندك نظام كامل للـ Offline-First! 🎉**
