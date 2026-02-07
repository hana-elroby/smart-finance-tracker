import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

/// Simple Microphone Test - Direct speech_to_text usage
void main() {
  runApp(const SimpleMicApp());
}

class SimpleMicApp extends StatelessWidget {
  const SimpleMicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'اختبار المايك البسيط',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: GoogleFonts.cairo().fontFamily,
        useMaterial3: true,
      ),
      home: const SimpleMicPage(),
    );
  }
}

class SimpleMicPage extends StatefulWidget {
  const SimpleMicPage({super.key});

  @override
  State<SimpleMicPage> createState() => _SimpleMicPageState();
}

class _SimpleMicPageState extends State<SimpleMicPage> {
  final SpeechToText _speech = SpeechToText();
  
  bool _isListening = false;
  String _recognizedText = '';
  String _statusMessage = 'اضغط للاختبار';
  double _soundLevel = 0.0;
  String _debugLog = '';

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    setState(() {
      _debugLog = 'جاري التهيئة...\n';
    });

    // Request permission first
    final permission = await Permission.microphone.request();
    setState(() {
      _debugLog += 'إذن المايك: $permission\n';
    });

    if (permission != PermissionStatus.granted) {
      setState(() {
        _statusMessage = 'يجب السماح بإذن المايك';
        _debugLog += 'إذن المايك مرفوض!\n';
      });
      return;
    }

    // Initialize speech
    final available = await _speech.initialize(
      onError: (error) {
        setState(() {
          _debugLog += 'خطأ: ${error.errorMsg}\n';
          _statusMessage = 'خطأ: ${error.errorMsg}';
        });
        print('Speech error: ${error.errorMsg}');
      },
      onStatus: (status) {
        setState(() {
          _debugLog += 'حالة: $status\n';
        });
        print('Speech status: $status');
      },
      debugLogging: true,
    );

    setState(() {
      _debugLog += 'متاح: $available\n';
    });

    if (available) {
      // Get locales
      final locales = await _speech.locales();
      setState(() {
        _debugLog += 'اللغات المتاحة: ${locales.length}\n';
        for (int i = 0; i < locales.length && i < 5; i++) {
          _debugLog += '  - ${locales[i].localeId}: ${locales[i].name}\n';
        }
        _statusMessage = 'جاهز! اضغط المايك';
      });
    } else {
      setState(() {
        _statusMessage = 'المايك غير متاح';
        _debugLog += 'فشل في تهيئة المايك\n';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text(
          'اختبار المايك البسيط',
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[600],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Microphone Button
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _toggleListening,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: _isListening ? Colors.red : Colors.blue[600],
                        shape: BoxShape.circle,
                        boxShadow: [
                          if (_isListening)
                            BoxShadow(
                              color: Colors.red.withValues(alpha: 0.4),
                              blurRadius: 25,
                              spreadRadius: 8,
                            ),
                        ],
                      ),
                      child: Icon(
                        _isListening ? Icons.stop : Icons.mic,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
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
                    const SizedBox(height: 12),
                    Text(
                      'مستوى الصوت: ${_soundLevel.toStringAsFixed(1)} dB',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _soundLevel > -25 ? Colors.green : Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 200,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: ((_soundLevel + 50) / 100).clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _soundLevel > -25 ? Colors.green : Colors.orange,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Instructions
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Text(
                '🎯 قل بالإنجليزي:\n"I spent twenty five dollars on lunch"\nأو\n"Twenty five dollars food"',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: Colors.orange[700],
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 16),

            // Recognized Text
            if (_recognizedText.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '✅ نجح! النص:',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.green[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _recognizedText,
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        color: Colors.green[900],
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Debug Log
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🔧 سجل التشخيص:',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _debugLog,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    if (!_speech.isAvailable) {
      setState(() {
        _statusMessage = 'المايك غير متاح';
        _debugLog += 'محاولة استخدام مايك غير متاح\n';
      });
      return;
    }

    setState(() {
      _isListening = true;
      _statusMessage = 'جاري الاستماع...';
      _recognizedText = '';
      _debugLog += 'بدء الاستماع...\n';
    });

    try {
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords;
            _statusMessage = 'يسمع... استمر في الكلام';
            _debugLog += 'نتيجة: "${result.recognizedWords}" (ثقة: ${result.confidence})\n';
          });
          print('Result: ${result.recognizedWords}');
        },
        listenFor: const Duration(minutes: 2),
        pauseFor: const Duration(seconds: 2),
        partialResults: true,
        localeId: 'en-US', // Force English
        cancelOnError: false,
        listenMode: ListenMode.dictation,
        onSoundLevelChange: (level) {
          setState(() {
            _soundLevel = level;
          });
        },
      );

      setState(() {
        _debugLog += 'بدء الاستماع بنجاح\n';
      });

    } catch (e) {
      setState(() {
        _isListening = false;
        _statusMessage = 'خطأ: $e';
        _debugLog += 'خطأ في البدء: $e\n';
      });
      print('Error starting: $e');
    }
  }

  Future<void> _stopListening() async {
    try {
      await _speech.stop();
      setState(() {
        _isListening = false;
        _statusMessage = _recognizedText.isNotEmpty 
            ? '✅ تم بنجاح!' 
            : '⚠️ لم يتم التعرف على كلام';
        _debugLog += 'تم إيقاف الاستماع\n';
      });
    } catch (e) {
      setState(() {
        _isListening = false;
        _statusMessage = 'خطأ في الإيقاف: $e';
        _debugLog += 'خطأ في الإيقاف: $e\n';
      });
    }
  }
}