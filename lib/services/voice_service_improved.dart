// Voice Service - محسن للعربي
// Improved Voice Service for Arabic Recognition

import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

/// Voice Recognition Service محسن للعربي
class ImprovedVoiceService {
  static final ImprovedVoiceService _instance = ImprovedVoiceService._internal();
  factory ImprovedVoiceService() => _instance;
  ImprovedVoiceService._internal();

  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;

  // Initialize with Arabic priority
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      print('🔄 تهيئة خدمة التعرف على الصوت...');
      
      // طلب إذن الميكروفون
      final permission = await Permission.microphone.request();
      if (permission != PermissionStatus.granted) {
        print('❌ تم رفض إذن الميكروفون');
        return false;
      }

      // تهيئة التعرف على الكلام
      final available = await _speechToText.initialize(
        onError: (error) => print('❌ خطأ في الصوت: ${error.errorMsg}'),
        onStatus: (status) => print('📊 حالة الصوت: $status'),
        debugLogging: true,
      );

      if (available) {
        _isInitialized = true;
        print('✅ تم تهيئة خدمة الصوت بنجاح');
        await _logAvailableLocales();
        return true;
      } else {
        print('❌ التعرف على الكلام غير متاح');
        return false;
      }
    } catch (e) {
      print('❌ خطأ في تهيئة خدمة الصوت: $e');
      return false;
    }
  }

  // عرض اللغات المتاحة
  Future<void> _logAvailableLocales() async {
    try {
      final locales = await _speechToText.locales();
      print('🌍 إجمالي اللغات المتاحة: ${locales.length}');
      
      // البحث عن العربية
      final arabicLocales = locales.where((locale) => 
        locale.localeId.toLowerCase().contains('ar') || 
        locale.name.toLowerCase().contains('arabic') ||
        locale.name.contains('عربي') ||
        locale.localeId.contains('EG') ||
        locale.localeId.contains('SA') ||
        locale.localeId.contains('AE')
      ).toList();
      
      print('🇪🇬 اللغات العربية المتاحة: ${arabicLocales.length}');
      for (final locale in arabicLocales) {
        print('   - عربي: ${locale.localeId} - ${locale.name}');
      }
      
      // البحث عن الإنجليزية
      final englishLocales = locales.where((locale) => 
        locale.localeId.toLowerCase().startsWith('en')
      ).toList();
      
      print('🇺🇸 اللغات الإنجليزية المتاحة: ${englishLocales.length}');
      for (final locale in englishLocales.take(3)) {
        print('   - إنجليزي: ${locale.localeId} - ${locale.name}');
      }
    } catch (e) {
      print('⚠️ لا يمكن عرض اللغات المتاحة: $e');
    }
  }

  // بدء الاستماع مع أولوية للعربية
  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onError,
    Function(double)? onSoundLevel,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        onError('فشل في تهيئة خدمة الصوت');
        return;
      }
    }

    if (_isListening) {
      print('⚠️ الاستماع جاري بالفعل');
      return;
    }

    try {
      print('🎤 بدء الاستماع...');
      
      // الحصول على اللغات المتاحة
      final locales = await _speechToText.locales();
      String? selectedLocale = await _selectBestLocale(locales);
      
      print('🎯 اللغة المختارة: $selectedLocale');

      await _speechToText.listen(
        onResult: (result) {
          final recognizedWords = result.recognizedWords.trim();
          final confidence = result.confidence;
          
          print('🎤 تم التعرف على: "$recognizedWords" (الثقة: $confidence)');
          
          // قبول النتائج الجزئية والنهائية مع ثقة منخفضة
          if (recognizedWords.isNotEmpty) {
            print('✅ تم قبول: "$recognizedWords"');
            onResult(recognizedWords);
            
            // إذا كانت النتيجة نهائية، لا نوقف الاستماع
            // نتركه يكمل لحد ما المستخدم يوقفه بنفسه
          }
        },
        listenFor: const Duration(minutes: 5), // 5 دقائق بدل 10 ثواني
        pauseFor: const Duration(seconds: 3), // 3 ثواني توقف بين الجمل
        partialResults: true, // عرض النتائج الجزئية
        localeId: selectedLocale,
        onSoundLevelChange: onSoundLevel,
        cancelOnError: false,
        listenMode: ListenMode.dictation,
        // إضافة إعدادات جديدة لتحسين الأداء
        onDevice: false, // استخدام الخدمة السحابية إذا متاحة
      );

      _isListening = true;
      print('✅ بدأ الاستماع باللغة: $selectedLocale (مدة: 5 دقائق)');
      
    } catch (e) {
      print('❌ خطأ في بدء الاستماع: $e');
      _isListening = false;
      
      // معالجة أخطاء محددة مع رسائل أكثر وضوحاً
      if (e.toString().toLowerCase().contains('permission')) {
        onError('مطلوب إذن الميكروفون. يرجى تفعيله من الإعدادات.');
      } else if (e.toString().toLowerCase().contains('network')) {
        onError('خطأ في الشبكة. تحقق من اتصال الإنترنت.');
      } else if (e.toString().toLowerCase().contains('not available')) {
        onError('التعرف على الصوت غير متاح على هذا الجهاز. استخدم الكتابة اليدوية.');
      } else {
        onError('التعرف على الصوت لا يعمل حالياً. جرب الكتابة اليدوية أدناه.');
      }
    }
  }

  // اختيار أفضل لغة متاحة
  Future<String?> _selectBestLocale(List<LocaleName> locales) async {
    // الأولوية 1: العربية المصرية
    var egyptianArabic = locales.where((locale) => 
      locale.localeId.toLowerCase() == 'ar-eg' ||
      locale.localeId.toLowerCase() == 'ar_eg'
    ).firstOrNull;
    
    if (egyptianArabic != null) {
      print('🇪🇬 تم العثور على العربية المصرية: ${egyptianArabic.localeId}');
      return egyptianArabic.localeId;
    }

    // الأولوية 2: أي عربية
    var anyArabic = locales.where((locale) => 
      locale.localeId.toLowerCase().startsWith('ar') ||
      locale.name.toLowerCase().contains('arabic') ||
      locale.name.contains('عربي')
    ).firstOrNull;
    
    if (anyArabic != null) {
      print('🇸🇦 تم العثور على عربية: ${anyArabic.localeId}');
      return anyArabic.localeId;
    }

    // الأولوية 3: الإنجليزية الأمريكية
    var americanEnglish = locales.where((locale) => 
      locale.localeId.toLowerCase() == 'en-us' ||
      locale.localeId.toLowerCase() == 'en_us'
    ).firstOrNull;
    
    if (americanEnglish != null) {
      print('🇺🇸 تم العثور على الإنجليزية الأمريكية: ${americanEnglish.localeId}');
      return americanEnglish.localeId;
    }

    // الأولوية 4: أي إنجليزية
    var anyEnglish = locales.where((locale) => 
      locale.localeId.toLowerCase().startsWith('en')
    ).firstOrNull;
    
    if (anyEnglish != null) {
      print('🇬🇧 تم العثور على إنجليزية: ${anyEnglish.localeId}');
      return anyEnglish.localeId;
    }

    // الأولوية 5: اللغة الافتراضية للنظام
    print('🌍 استخدام اللغة الافتراضية للنظام');
    return null;
  }

  // إيقاف الاستماع
  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      await _speechToText.stop();
      _isListening = false;
      print('⏹️ تم إيقاف الاستماع');
    } catch (e) {
      print('❌ خطأ في إيقاف الاستماع: $e');
      _isListening = false;
    }
  }

  // إلغاء الاستماع
  Future<void> cancel() async {
    if (!_isListening) return;

    try {
      await _speechToText.cancel();
      _isListening = false;
      print('❌ تم إلغاء الاستماع');
    } catch (e) {
      print('❌ خطأ في إلغاء الاستماع: $e');
      _isListening = false;
    }
  }

  // تنظيف الموارد
  void dispose() {
    if (_isListening) {
      stopListening();
    }
  }
}

// Extension للمساعدة
extension on Iterable<LocaleName> {
  LocaleName? get firstOrNull {
    return isEmpty ? null : first;
  }
}