import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

/// Simple Voice Test - اختبار بسيط للميكروفون
void main() {
  runApp(const SimpleVoiceTestApp());
}

class SimpleVoiceTestApp extends StatelessWidget {
  const SimpleVoiceTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Voice Test',
      home: const SimpleVoiceTestPage(),
    );
  }
}

class SimpleVoiceTestPage extends StatefulWidget {
  const SimpleVoiceTestPage({super.key});

  @override
  State<SimpleVoiceTestPage> createState() => _SimpleVoiceTestPageState();
}

class _SimpleVoiceTestPageState extends State<SimpleVoiceTestPage> {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  String _text = '';
  String _status = 'اضغط للاختبار';
  double _confidence = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Voice Test'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isListening ? Colors.red.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isListening ? Colors.red : Colors.blue,
                ),
              ),
              child: Text(
                _status,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _isListening ? Colors.red : Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            // Voice Button
            GestureDetector(
              onTap: _toggleListening,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: _isListening ? Colors.red : Colors.blue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_isListening ? Colors.red : Colors.blue).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  _isListening ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Confidence
            if (_confidence > 0) ...[
              Text(
                'الثقة: ${(_confidence * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 10),
            ],

            // Text Result
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
                  child: Text(
                    _text.isEmpty ? 'النص المسموع سيظهر هنا...' : _text,
                    style: TextStyle(
                      fontSize: 16,
                      color: _text.isEmpty ? Colors.grey : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Clear Button
            if (_text.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _text = '';
                    _confidence = 0.0;
                    _status = 'تم المسح';
                  });
                },
                child: const Text('مسح'),
              ),
          ],
        ),
      ),
    );
  }

  void _toggleListening() async {
    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    // طلب إذن الميكروفون
    final permission = await Permission.microphone.request();
    if (permission != PermissionStatus.granted) {
      setState(() {
        _status = 'مطلوب إذن الميكروفون';
      });
      return;
    }

    // تهيئة التعرف على الكلام
    final available = await _speech.initialize(
      onError: (error) {
        print('❌ خطأ: ${error.errorMsg}');
        setState(() {
          _status = 'خطأ: ${error.errorMsg}';
          _isListening = false;
        });
      },
      onStatus: (status) {
        print('📊 الحالة: $status');
        setState(() {
          if (status == 'listening') {
            _status = '🎤 أتكلم الآن...';
          } else if (status == 'notListening') {
            _status = 'توقف الاستماع';
            _isListening = false;
          } else if (status == 'done') {
            _status = 'انتهى';
            _isListening = false;
          }
        });
      },
    );

    if (!available) {
      setState(() {
        _status = 'التعرف على الكلام غير متاح';
      });
      return;
    }

    // بدء الاستماع
    try {
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _text = result.recognizedWords;
            _confidence = result.confidence;
          });
          print('🎤 سمعت: "${result.recognizedWords}" (ثقة: ${result.confidence})');
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: false,
        listenMode: ListenMode.dictation,
      );

      setState(() {
        _isListening = true;
        _status = '🎤 أتكلم الآن...';
      });
    } catch (e) {
      setState(() {
        _status = 'فشل في بدء الاستماع: $e';
      });
    }
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
      _status = _text.isEmpty ? 'لم يتم سماع شيء' : 'تم الانتهاء';
    });
  }
}