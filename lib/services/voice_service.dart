// Voice Service - Optimized Speech Recognition
// Handles real-time speech recognition with emulator support

import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

/// Voice Recognition Service
/// Optimized for Android emulator and real devices
/// Supports both Arabic and English with smart locale detection
class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;

  // Initialize speech recognition with comprehensive locale detection
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      print('🔄 Initializing voice service...');
      
      // Request microphone permission
      final permission = await Permission.microphone.request();
      if (permission != PermissionStatus.granted) {
        print('❌ Microphone permission denied');
        return false;
      }

      // Initialize speech to text
      final available = await _speechToText.initialize(
        onError: (error) {
          print('❌ Speech error: ${error.errorMsg}');
        },
        onStatus: (status) => print('📊 Speech status: $status'),
        debugLogging: true,
      );

      if (available) {
        _isInitialized = true;
        print('✅ Voice service initialized successfully');
        
        // Get and analyze available locales
        final locales = await _speechToText.locales();
        print('🌍 Total available locales: ${locales.length}');
        
        // Show ALL available locales for debugging
        print('📋 All available locales:');
        for (final locale in locales) {
          print('   - ${locale.localeId}: ${locale.name}');
        }
        
        // Check specifically for Arabic locales
        final arabicLocales = locales.where((locale) => 
          locale.localeId.startsWith('ar') || 
          locale.name.toLowerCase().contains('arabic') ||
          locale.name.toLowerCase().contains('عربي')
        ).toList();
        
        print('🇪🇬 Arabic locales found: ${arabicLocales.length}');
        for (final locale in arabicLocales) {
          print('   - Arabic: ${locale.localeId}: ${locale.name}');
        }
        
        // Check for English locales
        final englishLocales = locales.where((locale) => 
          locale.localeId.startsWith('en')
        ).toList();
        
        print('🇺🇸 English locales found: ${englishLocales.length}');
        for (final locale in englishLocales.take(3)) {
          print('   - English: ${locale.localeId}: ${locale.name}');
        }
        
        return true;
      } else {
        print('❌ Speech recognition not available');
        return false;
      }
    } catch (e) {
      print('❌ Voice service initialization error: $e');
      return false;
    }
  }

  // Start listening - Enhanced with better feedback and error handling
  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onError,
    Function(double)? onSoundLevel,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        onError('Voice service not available');
        return;
      }
    }

    if (_isListening) {
      print('⚠️ Already listening');
      return;
    }

    try {
      _isListening = true;
      print('🎤 Starting enhanced voice recognition...');
      
      // Check if microphone is available
      final hasPermission = await _speechToText.hasPermission;
      if (!hasPermission) {
        print('❌ No microphone permission');
        onError('Microphone permission required');
        _isListening = false;
        return;
      }

      // Get available locales and find the best one
      final locales = await _speechToText.locales();
      String? bestLocale;
      
      // Strategy 1: Look for Arabic locales first
      final arabicLocales = locales.where((locale) => 
        locale.localeId.startsWith('ar') || 
        locale.name.toLowerCase().contains('arabic')
      ).toList();
      
      if (arabicLocales.isNotEmpty) {
        bestLocale = arabicLocales.first.localeId;
        print('🇪🇬 Using Arabic locale: $bestLocale');
      } else {
        // Strategy 2: Look for English locales
        final englishLocales = locales.where((locale) => 
          locale.localeId.startsWith('en')
        ).toList();
        
        if (englishLocales.isNotEmpty) {
          bestLocale = englishLocales.first.localeId;
          print('🇺🇸 Using English locale: $bestLocale (Arabic not available)');
        } else {
          // Strategy 3: Use system default (no locale specified)
          bestLocale = null;
          print('🌍 Using system default (no specific locale)');
        }
      }
      
      await _speechToText.listen(
        onResult: (result) {
          final recognizedWords = result.recognizedWords;
          final confidence = result.confidence;
          print('🎯 Voice result: "${recognizedWords}" (confidence: $confidence)');
          
          // Accept results with reasonable confidence or any final result
          if (recognizedWords.isNotEmpty && 
              recognizedWords.trim().isNotEmpty &&
              (confidence > 0.3 || result.finalResult)) {
            print('✅ Accepted: "$recognizedWords"');
            onResult(recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 30), // Extended duration
        pauseFor: const Duration(seconds: 3), // Shorter pause for better UX
        partialResults: true, // Live feedback
        localeId: bestLocale, // Use best available locale or null for auto-detect
        listenMode: ListenMode.dictation, // Best for natural speech
        cancelOnError: false,
        onSoundLevelChange: (level) {
          // Provide sound level feedback for UI visualization
          if (onSoundLevel != null) {
            onSoundLevel(level);
          }
          if (level > -10.0) { // Only log significant sound levels
            print('🔊 Sound level: ${level.toStringAsFixed(1)}');
          }
        },
      );
      
    } catch (e) {
      _isListening = false;
      print('❌ Speech recognition error: $e');
      
      // Enhanced error handling with specific fallback strategies
      if (e.toString().contains('locale') || e.toString().contains('language')) {
        print('🔄 Trying fallback with English...');
        await _tryFallbackListening(onResult, onError, onSoundLevel);
      } else if (e.toString().contains('permission')) {
        onError('Microphone permission denied. Please enable it in settings.');
      } else if (e.toString().contains('network') || e.toString().contains('connection')) {
        onError('Network error. Check your internet connection.');
      } else {
        onError('Voice recognition failed. You can type manually instead.');
      }
    }
  }

  // Enhanced fallback method with better error handling
  Future<void> _tryFallbackListening(
    Function(String) onResult,
    Function(String) onError,
    Function(double)? onSoundLevel,
  ) async {
    try {
      _isListening = true;
      print('🔄 Fallback: Using English-only recognition...');
      
      await _speechToText.listen(
        onResult: (result) {
          final recognizedWords = result.recognizedWords;
          final confidence = result.confidence;
          print('🎯 Fallback result: "${recognizedWords}" (confidence: $confidence)');
          
          if (recognizedWords.isNotEmpty && 
              (confidence > 0.3 || result.finalResult)) {
            onResult(recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: 'en-US', // Force English
        listenMode: ListenMode.dictation,
        cancelOnError: false,
        onSoundLevelChange: onSoundLevel,
      );
      
    } catch (e) {
      _isListening = false;
      print('❌ Fallback also failed: $e');
      onError('Voice recognition unavailable. Please type your expense manually.');
    }
  }

  // Get current sound level (for UI visualization)
  double get currentSoundLevel => _speechToText.lastRecognizedWords.isNotEmpty ? 1.0 : 0.0;

  // Check if device supports speech recognition
  Future<bool> isDeviceSupported() async {
    try {
      return await _speechToText.initialize();
    } catch (e) {
      print('❌ Device not supported: $e');
      return false;
    }
  }

  // Get available languages for user selection
  Future<List<String>> getAvailableLanguages() async {
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      final locales = await _speechToText.locales();
      return locales.map((locale) => '${locale.name} (${locale.localeId})').toList();
    } catch (e) {
      print('❌ Error getting languages: $e');
      return [];
    }
  }

  // Stop listening
  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      await _speechToText.stop();
      _isListening = false;
      print('🛑 Stopped voice listening');
    } catch (e) {
      print('❌ Error stopping speech recognition: $e');
    }
  }

  // Check if speech recognition is available
  Future<bool> isAvailable() async {
    return await _speechToText.initialize();
  }
}