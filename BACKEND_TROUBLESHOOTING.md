# دليل حل مشاكل الباك اند - Backend Troubleshooting Guide

## 🚨 المشكلة: البيانات مش بتوصل للباك اند team

### الأسباب المحتملة:

## 1. 💤 السيرفر نايم (الأكثر احتمالاً)
**المشكلة**: Render بينام السيرفرات المجانية بعد 15 دقيقة من عدم الاستخدام

**الحل**:
```bash
dart run wake_up_server_test.dart
```

**العلامات**:
- الطلب الأول بياخد وقت طويل (30-60 ثانية)
- بعدين السيرفر بيشتغل عادي

---

## 2. 🔗 مشكلة في الـ Endpoint
**المشكلة**: الـ endpoint مش صحيح أو مش موجود

**التحقق**:
```bash
dart run test_backend_connection_debug.dart
```

**الـ Endpoints المتوقعة**:
- ✅ `GET /api` → "Server is running!"
- ✅ `GET /transactions` → قائمة المعاملات
- ✅ `POST /transactions` → إضافة معاملة جديدة

---

## 3. 📊 مشكلة في البيانات المرسلة
**المشكلة**: البيانات مش بالشكل اللي السيرفر متوقعه

**البيانات المرسلة حالياً**:
```json
{
  "amount": 25.0,
  "category": "food",
  "title": "قهوة",
  "description": "قهوة",
  "quantity": 1,
  "date": "2025-02-03T10:30:00.000Z",
  "isVoiceInput": false,
  "userId": "shared_user"
}
```

---

## 🧪 خطوات التشخيص

### الخطوة 1: إيقاظ السيرفر
```bash
dart run wake_up_server_test.dart
```
**المتوقع**: السيرفر يستيقظ ويرد على الطلبات

### الخطوة 2: اختبار التطبيق
```bash
dart run test_exact_app_behavior.dart
```
**المتوقع**: محاكاة سلوك التطبيق بالضبط

### الخطوة 3: اختبار مفصل
```bash
dart run test_backend_connection_debug.dart
```
**المتوقع**: تفاصيل كاملة عن كل endpoint

### الخطوة 4: التطبيق الأساسي
```bash
flutter run
```
ثم اضيف مصروف وشوف الـ console logs

---

## 📋 رسائل الـ Console المتوقعة

### عند النجاح:
```
💾 حفظ المصروف في الداتا بيز المشتركة...
📡 Response Status: 200
📄 Response Body: {"id": 123, "message": "Transaction created"}
✅ تم حفظ المصروف في سيرفر الباك اند: قهوة
📊 الباك اند team يقدروا يشوفوا البيانات دلوقتي في الداتا بيز
```

### عند الفشل:
```
💾 حفظ المصروف في الداتا بيز المشتركة...
📡 Response Status: 404
📄 Response Body: Not Found
❌ فشل في حفظ المصروف: 404
```

---

## 🔧 الحلول المحتملة

### إذا كان السيرفر نايم:
1. شغل `wake_up_server_test.dart`
2. انتظر 1-2 دقيقة
3. جرب التطبيق تاني

### إذا كان الـ endpoint غلط:
1. تحقق من الـ URL في `ApiConfig`
2. تأكد من أن `/transactions` موجود
3. جرب endpoints تانية زي `/api/transactions`

### إذا كانت البيانات غلط:
1. شوف الـ response body في الـ console
2. تحقق من الـ backend code
3. تأكد من الـ required fields

---

## 🎯 للباك اند Team

### كيف تتحققوا من وصول البيانات:

1. **افتحوا الداتا بيز**
2. **شوفوا جدول `transactions`**
3. **دوروا على معاملات جديدة بـ**:
   - `userId = "shared_user"`
   - `title` يحتوي على كلمات عربية
   - `date` حديث (آخر ساعة)

### مثال على الـ SQL Query:
```sql
SELECT * FROM transactions 
WHERE userId = 'shared_user' 
AND created_at > NOW() - INTERVAL 1 HOUR
ORDER BY created_at DESC;
```

---

## 🚀 الاختبار النهائي

### الخطوات:
1. شغل `wake_up_server_test.dart`
2. انتظر لحد ما السيرفر يستيقظ
3. شغل التطبيق: `flutter run`
4. اضيف مصروف (فويس أو manual)
5. شوف الـ console logs
6. اطلب من الباك اند team يتحققوا من الداتا بيز

### النتيجة المتوقعة:
- ✅ رسالة نجاح في الـ console
- ✅ المعاملة تظهر في الداتا بيز عند الباك اند team
- ✅ البيانات صحيحة ومكتملة

---

## 📞 إذا لسه مفيش حاجة بتسمع:

### تحقق من:
1. **الإنترنت**: متأكد من الاتصال؟
2. **السيرفر**: شغال ومش نايم؟
3. **الـ URL**: صحيح ومش متغير؟
4. **الباك اند Code**: بيحفظ في الداتا بيز فعلاً؟
5. **الداتا بيز**: متصلة وشغالة؟

### اطلب من الباك اند team:
1. يتحققوا من الـ server logs
2. يشوفوا إذا الطلبات واصلة
3. يتأكدوا من الداتا بيز connection
4. يختبروا الـ endpoint بـ Postman

---

**الخلاصة**: في 99% من الحالات، المشكلة إن السيرفر نايم. شغل `wake_up_server_test.dart` وكل حاجة هتشتغل! 🚀