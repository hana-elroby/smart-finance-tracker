import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduation_project/services/voice_service.dart';
import 'package:graduation_project/services/voice_api_service.dart';

/// Arabic Fix Test - Test the updated voice service
void main() {
  runApp(const ArabicFixApp());
}

class ArabicFixApp extends StatelessWidget {
  const ArabicFixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arabic Voice Fix Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: GoogleFonts.cairo().fontFamily,
        useMaterial3: true,
      ),
      home: const ArabicFixPage(),
    );
  }
}

class ArabicFixPage extends StatefulWidget {
  const ArabicFixPage({super.key});

  @override
  State<ArabicFixPage> createState() => _ArabicFixPageState();
}

class _ArabicFixPageState extends State<ArabicFixPage> {
  final VoiceService _voiceService = VoiceService();
  final VoiceApiService _voiceApiService = VoiceApiService();
  
  bool _isListening = false;
  String _recognizedText = '';
  String _statusMessage = 'جاهز للاختبار - Ready to test';
  String _analysisResult = '';
  double _soundLevel = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'اختبار الصوت العربي - Arabic Voice Test',
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[600],
        elevation: 0,
      ),
      body: Padding(
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
                  // Microphone Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: _isListening ? Colors.red : Colors.green[600],
                      shape: BoxShape.circle,
                      boxShadow: [
                        if (_isListening)
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Status Message
                  Text(
                    _statusMessage,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  // Sound Level
                  if (_isListening) ...[
                    const SizedBox(height: 16),
                    Text(
                      'مستوى الصوت: ${_soundLevel.toStringAsFixed(1)} dB',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _soundLevel > -20 ? Colors.green : Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: ((_soundLevel + 50) / 100).clamp(0.0, 1.0),
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _soundLevel > -20 ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Test Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: _toggleListening,
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
                  backgroundColor: _isListening ? Colors.red : Colors.green[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Instructions
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
                    'تعليمات الاختبار:',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '1. اضغط "بدء التسجيل"\n2. قل بوضوح: "دفعت 25 جنيه على الغداء"\n3. أو قل: "I spent 25 dollars on lunch"\n4. شاهد النص يظهر\n5. اضغط "تحليل بالسيرفر"',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: Colors.blue[700],
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Recognized Text
            if (_recognizedText.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '✅ النص المسجل:',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _recognizedText,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        color: Colors.green[900],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _analyzeText,
                        child: Text(
                          'تحليل بالسيرفر',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
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
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.purple[200]!),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🔍 نتيجة تحليل السيرفر:',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.purple[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _analysisResult,
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: Colors.purple[900],
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
      _statusMessage = 'جاري البدء... Starting...';
      _recognizedText = '';
      _analysisResult = '';
    });

    try {
      await _voiceService.startListening(
        onResult: (text) {
          setState(() {
            _recognizedText = text;
            _statusMessage = '✅ يعمل! تحدث الآن... Working! Keep speaking...';
          });
          print('🎯 SUCCESS: $text');
        },
        onError: (error) {
          setState(() {
            _isListening = false;
            _statusMessage = '❌ خطأ: $error';
          });
          print('❌ Error: $error');
        },
        onSoundLevel: (level) {
          setState(() {
            _soundLevel = level;
            if (level > -20) {
              _statusMessage = '🔊 ممتاز! المايك يعمل. تحدث بوضوح...';
            } else {
              _statusMessage = '🔇 المايك يعمل لكن تحدث بصوت أعلى...';
            }
          });
        },
      );
    } catch (e) {
      setState(() {
        _isListening = false;
        _statusMessage = '💥 فشل البدء: $e';
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
            ? '✅ تم الاختبار بنجاح!' 
            : '⚠️ لم يتم التعرف على الكلام. جرب العبارات الإنجليزية.';
      });
    } catch (e) {
      setState(() {
        _isListening = false;
        _statusMessage = 'خطأ في الإيقاف: $e';
      });
    }
  }

  Future<void> _analyzeText() async {
    if (_recognizedText.isEmpty) return;

    setState(() {
      _analysisResult = 'جاري التحليل... Analyzing...';
    });

    try {
      final result = await _voiceApiService.analyzeText(_recognizedText);
      
      if (result.isSuccess) {
        setState(() {
          _analysisResult = '✅ السيرفر يعمل!\nالاستجابة: ${result.data.toString()}';
        });
      } else {
        setState(() {
          _analysisResult = '❌ خطأ في السيرفر: ${result.message}';
        });
      }
    } catch (e) {
      setState(() {
        _analysisResult = '💥 فشل التحليل: $e';
      });
    }
  }
}