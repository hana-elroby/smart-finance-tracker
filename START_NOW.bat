@echo off
echo 🚀 تشغيل المتتبع المالي الذكي...
echo.
echo ⏳ جاري التنظيف والتحضير...
flutter clean
flutter pub get
echo.
echo 🎤 تشغيل التطبيق مع الصوت المحسن...
flutter run quick_run.dart
pause