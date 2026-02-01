// Voice Service - Real speech recognition
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

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

  // Initialize speech recognition
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
        onError: (error) => print('❌ Speech error: ${error.errorMsg}'),
        onStatus: (status) => print('📊 Speech status: $status'),
      );

      if (available) {
        _isInitialized = true;
        print('✅ Voice service initialized successfully');
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

  // Start listening - real voice recognition
  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onError,
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
      print('🎤 Started real voice listening...');
      
      await _speechToText.listen(
        onResult: (result) {
          final recognizedWords = result.recognizedWords;
          if (recognizedWords.isNotEmpty) {
            print('🎯 Voice recognized: "$recognizedWords"');
            onResult(recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: 'ar-EG', // Arabic first
        listenMode: ListenMode.dictation,
        cancelOnError: false,
      );
      
    } catch (e) {
      _isListening = false;
      print('❌ Speech recognition error: $e');
      onError('Failed to start listening: $e');
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