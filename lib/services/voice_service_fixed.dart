import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

/// Fixed Voice Service - مبسط وفعال
class FixedVoiceService {
  static final FixedVoiceService _instance = FixedVoiceService._internal();
  factory FixedVoiceService() => _instance;
  FixedVoiceService._internal();

  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  bool get isListening => _isListening;

  /// تهيئة الخدمة
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      print('🔄 بدء تهيئة الميكروفون...');
      
      // طلب إذن الميكروفون
      final permission = await Permission.microphone.request();
      if (permission != PermissionStatus.granted) {
        print('❌ مطلوب إذن الميكروفون');
        return false;
      }
      print('✅ تم الحصول على إذن الميكروفون');

      // تهيئة التعرف على الكلام
      final available = await _speech.initialize(
        onError: (error) {
          print('❌ خطأ في الصوت: ${error.errorMsg}');
        },
        onStatus: (status) {
          print('📊 حالة الصوت: $status');
        },
        debugLogging: true,
      );

      if (available) {
        _isInitialized = true;
        print('✅ تم تهيئة خدمة الصوت بنجاح');
        
        // عرض اللغات المتاحة
        final locales = await _speech.locales();
        print('🌍 اللغات المتاحة: ${locales.length}');
        
        // البحث عن العربية
        final arabicLocales = locales.where((l) => 
          l.localeId.contains('ar') || l.name.toLowerCase().contains('arabic')
        ).toList();
        print('🇪🇬 عربية متاحة: ${arabicLocales.length}');
        
        // البحث عن الإنجليزية
        final englishLocales = locales.where((l) => 
          l.localeId.startsWith('en')
        ).toList();
        print('🇺🇸 إنجليزية متاحة: ${englishLocales.length}');
        
        return true;
      } else {
        print('❌ التعرف على الكلام غير متاح');
        return false;
      }
    } catch (e) {
      print('❌ خطأ في التهيئة: $e');
      return false;
    }
  }

  /// بدء الاستماع
  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onError,
    Function(double)? onSoundLevel,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        onError('فشل في تهيئة الميكروفون');
        return;
      }
    }

    if (_isListening) {
      print('⚠️ الاستماع جاري بالفعل');
      return;
    }

    try {
      print('🎤 بدء الاستماع...');
      
      // اختيار اللغة
      final locales = await _speech.locales();
      String? selectedLocale;
      
      // البحث عن العربية أولاً
      final arabic = locales.where((l) => l.localeId.contains('ar')).firstOrNull;
      if (arabic != null) {
        selectedLocale = arabic.localeId;
        print('🇪🇬 استخدام العربية: $selectedLocale');
      } else {
        // استخدام الإنجليزية
        final english = locales.where((l) => l.localeId.startsWith('en')).firstOrNull;
        if (english != null) {
          selectedLocale = english.localeId;
          print('🇺🇸 استخدام الإنجليزية: $selectedLocale');
        }
      }

      await _speech.listen(
        onResult: (result) {
          final text = result.recognizedWords.trim();
          print('🎤 سمعت: "$text"');
          
          if (text.isNotEmpty) {
            print('✅ إرسال النص: "$text"');
            onResult(text);
          }
        },
        listenFor: const Duration(minutes: 2), // دقيقتين
        pauseFor: const Duration(seconds: 2), // ثانيتين توقف
        partialResults: true, // عرض النتائج أثناء الكلام
        localeId: selectedLocale,
        onSoundLevelChange: onSoundLevel,
        cancelOnError: false,
        listenMode: ListenMode.dictation,
      );

      _isListening = true;
      print('✅ بدأ الاستماع بنجاح');
      
    } catch (e) {
      print('❌ خطأ في بدء الاستماع: $e');
      _isListening = false;
      onError('خطأ في بدء الاستماع: $e');
    }
  }

  /// إيقاف الاستماع
  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      await _speech.stop();
      _isListening = false;
      print('⏹️ تم إيقاف الاستماع');
    } catch (e) {
      print('❌ خطأ في الإيقاف: $e');
      _isListening = false;
    }
  }

  /// إلغاء الاستماع
  Future<void> cancel() async {
    if (!_isListening) return;

    try {
      await _speech.cancel();
      _isListening = false;
      print('❌ تم إلغاء الاستماع');
    } catch (e) {
      print('❌ خطأ في الإلغاء: $e');
      _isListening = false;
    }
  }
}

extension on Iterable {
  get firstOrNull => isEmpty ? null : first;
}