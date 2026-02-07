import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduation_project/services/voice_service.dart';

/// Simple Microphone Test - Fixed Version
void main() {
  runApp(const SimpleMicApp());
}

class SimpleMicApp extends StatelessWidget {
  const SimpleMicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'اختبار الميكروفون البسيط',
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
  final VoiceService _voiceService = VoiceService();
  bool _isListening = false;
  String _recognizedText = '';
  String _statusMessage = 'اضغط على الميكروفون للبدء';
  double _soundLevel = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'اختبار الميكروفون البسيط',
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF667eea),
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
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _isListening ? Colors.red : const Color(0xFF667eea),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      size: 40,
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
                      'مستوى الصوت: ${_soundLevel.toStringAsFixed(1)}',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (_soundLevel + 50) / 100,
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

            // Microphone Button
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

            // Instructions
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.orange[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '1. اضغط "بدء التسجيل"\n2. تحدث بوضوح: "مرحبا"\n3. شاهد النص يظهر\n4. اضغط "إيقاف التسجيل"',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Colors.orange[700],
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '💡 إذا ظهر النص، فالميكروفون يعمل بشكل صحيح!',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: Colors.orange[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
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
    setState(() {
      _isListening = true;
      _statusMessage = 'جاري البدء...';
      _recognizedText = '';
    });

    try {
      await _voiceService.startListening(
        onResult: (text) {
          setState(() {
            _recognizedText = text;
            _statusMessage = 'يستمع... تحدث الآن!';
          });
          print('🎯 Recognized: $text');
        },
        onError: (error) {
          setState(() {
            _isListening = false;
            _statusMessage = 'خطأ: $error';
          });
          print('❌ Error: $error');
        },
        onSoundLevel: (level) {
          setState(() {
            _soundLevel = level;
          });
        },
      );
    } catch (e) {
      setState(() {
        _isListening = false;
        _statusMessage = 'فشل في البدء: $e';
      });
      print('❌ Start failed: $e');
    }
  }

  Future<void> _stopListening() async {
    try {
      await _voiceService.stopListening();
      setState(() {
        _isListening = false;
        _statusMessage = 'تم الإيقاف';
      });
      print('🛑 Stopped');
    } catch (e) {
      setState(() {
        _isListening = false;
        _statusMessage = 'خطأ في الإيقاف: $e';
      });
      print('❌ Stop failed: $e');
    }
  }
}