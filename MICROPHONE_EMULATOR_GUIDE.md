# دليل إصلاح الميكروفون في المحاكي
# Emulator Microphone Fix Guide

## المشكلة / Problem
الميكروفون لا يعمل في المحاكي رغم أنه كان يعمل من قبل
Microphone not working in emulator even though it was working before

## الحلول / Solutions

### 1. إعدادات المحاكي / Emulator Settings

#### الطريقة الأولى: من إعدادات المحاكي
**From Emulator Settings:**

1. افتح المحاكي / Open emulator
2. اضغط على النقاط الثلاث (⋮) في شريط الأدوات / Click three dots (⋮) in toolbar
3. اذهب إلى Settings → Microphone
4. تأكد من اختيار:
   - **Virtual microphone uses host audio input** ✅
   - أو / OR **Host audio input** ✅

#### الطريقة الثانية: من سطر الأوامر
**From Command Line:**

```bash
# إعادة تشغيل المحاكي مع تفعيل الميكروفون
# Restart emulator with microphone enabled

# Windows
emulator -avd YOUR_AVD_NAME -feature VirtualScene

# أو / OR
emulator -avd YOUR_AVD_NAME -qemu -soundhw all
```

### 2. فحص الأذونات / Check Permissions

#### في الكود / In Code:
الأذونات موجودة بالفعل في `AndroidManifest.xml`:
Permissions already exist in `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.MICROPHONE"/>
```

#### في المحاكي / In Emulator:
1. Settings → Apps → Your App → Permissions
2. تأكد من تفعيل Microphone ✅
3. Make sure Microphone is enabled ✅

### 3. اختبار الميكروفون / Test Microphone

#### استخدم ملف الاختبار / Use Test File:
```bash
flutter run -d emulator-5554 -t test_simple_voice_check.dart
```

هذا الملف سيعرض:
This file will show:
- ✅ حالة الأذونات / Permission status
- ✅ اللغات المتاحة / Available languages
- ✅ سجل مفصل للأحداث / Detailed event log
- ✅ مستوى الصوت / Sound level

### 4. إعدادات Windows / Windows Settings

إذا كنت تستخدم Windows:
If using Windows:

1. **Windows Settings → Privacy → Microphone**
   - تأكد من تفعيل "Allow apps to access your microphone" ✅
   - Make sure "Allow apps to access your microphone" is ON ✅

2. **تأكد من عمل الميكروفون**
   - افتح Voice Recorder في Windows
   - سجل صوت قصير للتأكد من عمل الميكروفون
   - Open Voice Recorder in Windows
   - Record a short audio to verify microphone works

### 5. حلول إضافية / Additional Solutions

#### إعادة إنشاء المحاكي / Recreate Emulator:
```bash
# احذف المحاكي القديم / Delete old emulator
avdmanager delete avd -n YOUR_AVD_NAME

# أنشئ محاكي جديد / Create new emulator
avdmanager create avd -n NEW_AVD_NAME -k "system-images;android-33;google_apis;x86_64"
```

#### تحديث Android SDK / Update Android SDK:
```bash
sdkmanager --update
sdkmanager "platform-tools" "platforms;android-33"
```

### 6. التحقق من الكود / Code Verification

الكود الحالي صحيح ويدعم:
Current code is correct and supports:
- ✅ Arabic and English recognition
- ✅ Proper permission handling
- ✅ Error handling
- ✅ Emulator compatibility

### 7. الاختبار على جهاز حقيقي / Test on Real Device

إذا استمرت المشكلة في المحاكي:
If problem persists in emulator:

```bash
# اختبر على جهاز حقيقي / Test on real device
flutter run -d YOUR_DEVICE_ID
```

الميكروفون يعمل بشكل أفضل على الأجهزة الحقيقية
Microphone works better on real devices

## الخطوات الموصى بها / Recommended Steps

1. ✅ افتح إعدادات المحاكي وتأكد من تفعيل الميكروفون
2. ✅ شغل ملف الاختبار: `flutter run -t test_simple_voice_check.dart`
3. ✅ اضغط "فحص الأذونات" ثم "تهيئة"
4. ✅ اضغط على أيقونة الميكروفون وتحدث
5. ✅ راقب السجل للتأكد من استقبال الصوت

1. ✅ Open emulator settings and enable microphone
2. ✅ Run test file: `flutter run -t test_simple_voice_check.dart`
3. ✅ Click "Check Permissions" then "Initialize"
4. ✅ Click microphone icon and speak
5. ✅ Watch log to verify audio is received

## ملاحظات مهمة / Important Notes

- 🎤 المحاكي يحتاج إلى ميكروفون فعال على الكمبيوتر
- 🎤 Emulator needs working microphone on host computer

- 🔊 تحدث بصوت واضح وقريب من الميكروفون
- 🔊 Speak clearly and close to microphone

- ⏱️ انتظر 2-3 ثواني بعد الضغط على الميكروفون قبل التحدث
- ⏱️ Wait 2-3 seconds after clicking mic before speaking

- 🌍 الخدمة تدعم العربية والإنجليزية تلقائياً
- 🌍 Service supports Arabic and English automatically

## الدعم / Support

إذا استمرت المشكلة، تحقق من:
If problem persists, check:

1. سجل الأحداث في ملف الاختبار / Event log in test file
2. إعدادات الميكروفون في Windows / Microphone settings in Windows
3. تحديثات Android SDK / Android SDK updates
4. اختبر على جهاز حقيقي / Test on real device
