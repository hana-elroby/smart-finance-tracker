import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduation_project/services/voice_service.dart';
import 'package:graduation_project/services/voice_api_service.dart';

/// Direct Microphone Test - Force English recognition for Arabic
void main() {
  runApp(const DirectMicApp());
}

class DirectMicApp extends StatelessWidget {
  const DirectMicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'اختبار المايك المباشر',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: GoogleFonts.cairo().fontFamily,
        useMaterial3: true,
      ),
      home: const DirectMicPage(),
    );
  }
}

class DirectMicPage extends StatefulWidget {
  const DirectMicPage({super.key});

  @override
  State<DirectMicPage> createState() => _DirectMicPageState();
}

class _DirectMicPageState extends State<DirectMicPage> {
  final VoiceService _voiceService = VoiceService();
  final VoiceApiService _voiceApiService = VoiceApiService();
  
  bool _isListening = false;
  String _recognizedText = '';
  String _statusMessage = 'جاهز للاختبار';
  String _analysisResult = '';
  double _soundLevel = 0.0;
  String _debugInfo = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[50],
      appBar: AppBar(
        title: Text(
          'اختبار المايك المباشر',
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red[600],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Big Microphone Button
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
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: _isListening ? Colors.red : Colors.red[600],
                        shape: BoxShape.circle,
                        boxShadow: [
                          if (_isListening)
                            BoxShadow(
                              color: Colors.red.withValues(alpha: 0.4),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                        ],
                      ),
                      child: Icon(
                        _isListening ? Icons.stop : Icons.mic,
                        size: 60,
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
                    const SizedBox(height: 8),
                    Text(
                      'مستوى الصوت: ${_soundLevel.toStringAsFixed(1)} dB',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _soundLevel > -20 ? Colors.green : Colors.orange,
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🎯 تعليمات مهمة:',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.orange[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '1. اضغط على المايك الأحمر\n2. قل بالإنجليزي: "I spent 25 dollars on lunch"\n3. أو قل: "Twenty five dollars food"\n4. لازم تتكلم إنجليزي عشان الإيميوليتر يفهم\n5. السيرفر هيحلل العربي بعد كده',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: Colors.orange[700],
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Debug Info
            if (_debugInfo.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔧 معلومات التشخيص:',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _debugInfo,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Recognized Text
            if (_recognizedText.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '✅ نجح! النص المسجل:',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.green[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _recognizedText,
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        color: Colors.green[900],
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _analyzeWithServer,
                        icon: const Icon(Icons.analytics, size: 20),
                        label: Text(
                          'تحليل بالسيرفر',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Analysis Result
            if (_analysisResult.isNotEmpty) ...[
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🔍 نتيجة تحليل السيرفر:',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.blue[800],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _analysisResult,
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: Colors.blue[900],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
    setState(() {
      _isListening = true;
      _statusMessage = 'جاري البدء...';
      _recognizedText = '';
      _analysisResult = '';
      _debugInfo = 'بدء تشغيل المايك...';
    });

    try {
      // Force initialize first
      final initialized = await _voiceService.initialize();
      setState(() {
        _debugInfo += '\nتم التهيئة: $initialized';
      });

      if (!initialized) {
        setState(() {
          _statusMessage = 'فشل في تهيئة المايك';
          _isListening = false;
        });
        return;
      }

      await _voiceService.startListening(
        onResult: (text) {
          setState(() {
            _recognizedText = text;
            _statusMessage = '✅ نجح! تم التعرف على الكلام';
            _debugInfo += '\nتم التعرف: $text';
          });
          print('🎯 SUCCESS: $text');
        },
        onError: (error) {
          setState(() {
            _isListening = false;
            _statusMessage = '❌ خطأ: $error';
            _debugInfo += '\nخطأ: $error';
          });
          print('❌ Error: $error');
        },
        onSoundLevel: (level) {
          setState(() {
            _soundLevel = level;
            if (level > -20) {
              _statusMessage = '🔊 ممتاز! المايك يسمعك. استمر في الكلام...';
            } else if (level > -40) {
              _statusMessage = '🔇 المايك يعمل لكن تكلم بصوت أعلى...';
            } else {
              _statusMessage = '🎤 المايك شغال، جرب تتكلم...';
            }
          });
        },
      );

      setState(() {
        _debugInfo += '\nبدء الاستماع بنجاح';
      });

    } catch (e) {
      setState(() {
        _isListening = false;
        _statusMessage = '💥 فشل البدء: $e';
        _debugInfo += '\nفشل: $e';
      });
      print('❌ Start failed: $e');
    }
  }

  Future<void> _stopListening() async {
    try {
      await _voiceService.stopListening();
      setState(() {
        _isListening = false;
        _statusMessage = _recognizedText.isNotEmpty 
            ? '✅ تم بنجاح! اضغط تحليل بالسيرفر' 
            : '⚠️ لم يتم التعرف على كلام. جرب الإنجليزي';
        _debugInfo += '\nتم إيقاف المايك';
      });
    } catch (e) {
      setState(() {
        _isListening = false;
        _statusMessage = 'خطأ في الإيقاف: $e';
        _debugInfo += '\nخطأ إيقاف: $e';
      });
    }
  }

  Future<void> _analyzeWithServer() async {
    if (_recognizedText.isEmpty) return;

    setState(() {
      _analysisResult = 'جاري إرسال للسيرفر...';
    });

    try {
      print('📤 Sending to server: $_recognizedText');
      final result = await _voiceApiService.analyzeText(_recognizedText);
      
      if (result.isSuccess) {
        setState(() {
          _analysisResult = '✅ السيرفر شغال ونجح التحليل!\n\nالاستجابة الكاملة:\n${result.data.toString()}';
        });
        print('✅ Server success: ${result.data}');
      } else {
        setState(() {
          _analysisResult = '❌ خطأ من السيرفر: ${result.message}';
        });
        print('❌ Server error: ${result.message}');
      }
    } catch (e) {
      setState(() {
        _analysisResult = '💥 فشل الاتصال بالسيرفر: $e';
      });
      print('💥 Connection failed: $e');
    }
  }
}