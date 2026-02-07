import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

/// Simple Microphone Test - Debug Voice Issues
void main() {
  runApp(const MicrophoneTestApp());
}

class MicrophoneTestApp extends StatelessWidget {
  const MicrophoneTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'اختبار الميكروفون',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: GoogleFonts.cairo().fontFamily,
        useMaterial3: true,
      ),
      home: const MicrophoneTestPage(),
    );
  }
}

class MicrophoneTestPage extends StatefulWidget {
  const MicrophoneTestPage({super.key});

  @override
  State<MicrophoneTestPage> createState() => _MicrophoneTestPageState();
}

class _MicrophoneTestPageState extends State<MicrophoneTestPage> {
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  bool _isInitialized = false;
  String _recognizedText = '';
  String _statusMessage = 'اضغط على الميكروفون للبدء';
  double _soundLevel = 0.0;
  List<String> _availableLocales = [];

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    try {
      setState(() {
        _statusMessage = 'جاري التحضير...';
      });

      // Request permission first
      final permission = await Permission.microphone.request();
      if (permission != PermissionStatus.granted) {
        setState(() {
          _statusMessage = 'يجب السماح بإذن الميكروفون من الإعدادات';
        });
        return;
      }

      // Initialize speech to text
      final available = await _speechToText.initialize(
        onError: (error) {
          print('❌ Speech error: ${error.errorMsg}');
          setState(() {
            _statusMessage = 'خطأ: ${error.errorMsg}';
            _isListening = false;
          });
        },
        onStatus: (status) {
          print('📊 Speech status: $status');
          setState(() {
            if (status == 'listening') {
              _statusMessage = 'جاري الاستماع... تحدث الآن!';
            } else if (status == 'notListening') {
              _statusMessage = 'توقف الاستماع';
              _isListening = false;
            }
          });
        },
        debugLogging: true,
      );

      if (available) {
        final locales = await _speechToText.locales();
        setState(() {
          _isInitialized = true;
          _statusMessage = 'جاهز! اضغط على الميكروفون';
          _availableLocales = locales.map((l) => '${l.name} (${l.localeId})').toList();
        });
        print('✅ Speech initialized with ${locales.length} locales');
      } else {
        setState(() {
          _statusMessage = 'الميكروفون غير متاح على هذا الجهاز';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'خطأ في التحضير: $e';
      });
      print('❌ Initialization error: $e');
    }
  }

  Future<void> _startListening() async {
    if (!_isInitialized) {
      await _initializeSpeech();
      return;
    }

    if (_isListening) {
      await _stopListening();
      return;
    }

    try {
      setState(() {
        _isListening = true;
        _recognizedText = '';
        _statusMessage = 'جاري البدء...';
      });

      await _speechToText.listen(
        onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords;
            _statusMessage = 'يستمع... (${result.confidence.toStringAsFixed(2)})';
          });
          print('🎯 Result: "${result.recognizedWords}" (${result.confidence})');
        },
        listenFor: const Duration(minutes: 5),
        pauseFor: const Duration(seconds: 1),
        partialResults: true,
        localeId: null, // Use system default
        cancelOnError: false,
        onSoundLevelChange: (level) {
          setState(() {
            _soundLevel = level;
          });
        },
      );

      print('✅ Started listening');
    } catch (e) {
      setState(() {
        _isListening = false;
        _statusMessage = 'خطأ في البدء: $e';
      });
      print('❌ Start error: $e');
    }
  }

  Future<void> _stopListening() async {
    try {
      await _speechToText.stop();
      setState(() {
        _isListening = false;
        _statusMessage = 'تم الإيقاف';
      });
      print('🛑 Stopped listening');
    } catch (e) {
      setState(() {
        _isListening = false;
        _statusMessage = 'خطأ في الإيقاف: $e';
      });
      print('❌ Stop error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'اختبار الميكروفون',
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF667eea),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    size: 64,
                    color: _isListening ? Colors.red : Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _statusMessage,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_isListening) ...[
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: (_soundLevel + 50) / 100, // Convert dB to 0-1
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _soundLevel > -20 ? Colors.green : Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'مستوى الصوت: ${_soundLevel.toStringAsFixed(1)} dB',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Microphone Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: _isInitialized ? _startListening : _initializeSpeech,
                icon: Icon(
                  _isListening ? Icons.stop : Icons.mic,
                  size: 24,
                ),
                label: Text(
                  _isListening ? 'إيقاف التسجيل' : 'بدء التسجيل',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isListening ? Colors.red : const Color(0xFF667eea),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Recognized Text
            if (_recognizedText.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'النص المسجل:',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _recognizedText,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        color: Colors.blue[900],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Debug Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'معلومات التشخيص:',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'مُهيأ: ${_isInitialized ? "نعم" : "لا"}',
                    style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey[700]),
                  ),
                  Text(
                    'يستمع: ${_isListening ? "نعم" : "لا"}',
                    style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey[700]),
                  ),
                  Text(
                    'اللغات المتاحة: ${_availableLocales.length}',
                    style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Instructions
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تعليمات الاختبار:',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. اضغط "بدء التسجيل"\n2. تحدث بوضوح\n3. شاهد النص يظهر\n4. اضغط "إيقاف التسجيل"',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: Colors.orange[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}