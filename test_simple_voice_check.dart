import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const SimpleVoiceCheckApp());
}

class SimpleVoiceCheckApp extends StatelessWidget {
  const SimpleVoiceCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Check',
      home: const VoiceCheckPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class VoiceCheckPage extends StatefulWidget {
  const VoiceCheckPage({super.key});

  @override
  State<VoiceCheckPage> createState() => _VoiceCheckPageState();
}

class _VoiceCheckPageState extends State<VoiceCheckPage> {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  String _text = 'اضغط على الميكروفون للتحدث';
  String _status = 'جاهز';
  List<String> _logs = [];

  void _addLog(String log) {
    setState(() {
      _logs.insert(0, '${DateTime.now().toString().substring(11, 19)} - $log');
      if (_logs.length > 20) _logs.removeLast();
    });
    print(log);
  }

  Future<void> _checkPermissions() async {
    _addLog('🔍 فحص الأذونات...');
    
    final status = await Permission.microphone.status;
    _addLog('📊 حالة الميكروفون: $status');
    
    if (!status.isGranted) {
      _addLog('⚠️ طلب إذن الميكروفون...');
      final result = await Permission.microphone.request();
      _addLog('✅ نتيجة الطلب: $result');
    } else {
      _addLog('✅ الإذن ممنوح بالفعل');
    }
  }

  Future<void> _initSpeech() async {
    _addLog('🔄 تهيئة خدمة الصوت...');
    
    try {
      final available = await _speech.initialize(
        onError: (error) {
          _addLog('❌ خطأ: ${error.errorMsg}');
          setState(() {
            _status = 'خطأ: ${error.errorMsg}';
          });
        },
        onStatus: (status) {
          _addLog('📊 الحالة: $status');
          setState(() {
            _status = status;
          });
        },
        debugLogging: true,
      );

      if (available) {
        _addLog('✅ الخدمة متاحة');
        
        // Get locales
        final locales = await _speech.locales();
        _addLog('🌍 عدد اللغات المتاحة: ${locales.length}');
        
        // Find Arabic
        final arabic = locales.where((l) => l.localeId.startsWith('ar')).toList();
        _addLog('🇪🇬 اللغة العربية: ${arabic.length} متاحة');
        for (var loc in arabic) {
          _addLog('   - ${loc.localeId}: ${loc.name}');
        }
        
        // Find English
        final english = locales.where((l) => l.localeId.startsWith('en')).take(3).toList();
        _addLog('🇺🇸 الإنجليزية: ${english.length} متاحة');
        for (var loc in english) {
          _addLog('   - ${loc.localeId}: ${loc.name}');
        }
      } else {
        _addLog('❌ الخدمة غير متاحة');
      }
    } catch (e) {
      _addLog('❌ خطأ في التهيئة: $e');
    }
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    _addLog('🎤 بدء الاستماع...');
    
    setState(() {
      _isListening = true;
      _text = 'استمع...';
    });

    try {
      await _speech.listen(
        onResult: (result) {
          _addLog('🎯 نتيجة: "${result.recognizedWords}"');
          setState(() {
            _text = result.recognizedWords.isEmpty 
                ? 'لم يتم التعرف على كلام' 
                : result.recognizedWords;
          });
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: false,
        onSoundLevelChange: (level) {
          // _addLog('🔊 مستوى الصوت: $level');
        },
      );
      
      _addLog('✅ بدأ الاستماع بنجاح');
    } catch (e) {
      _addLog('❌ خطأ في بدء الاستماع: $e');
      setState(() {
        _isListening = false;
        _text = 'خطأ: $e';
      });
    }
  }

  Future<void> _stopListening() async {
    _addLog('🛑 إيقاف الاستماع...');
    
    await _speech.stop();
    setState(() {
      _isListening = false;
    });
    
    _addLog('✅ تم الإيقاف');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('فحص الميكروفون'),
        backgroundColor: const Color(0xFF667eea),
      ),
      body: Column(
        children: [
          // Status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Column(
              children: [
                Text(
                  _status,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _text,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _checkPermissions,
                  icon: const Icon(Icons.security),
                  label: const Text('فحص الأذونات'),
                ),
                ElevatedButton.icon(
                  onPressed: _initSpeech,
                  icon: const Icon(Icons.refresh),
                  label: const Text('تهيئة'),
                ),
              ],
            ),
          ),
          
          // Mic Button
          GestureDetector(
            onTap: _toggleListening,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _isListening ? Colors.red[100] : Colors.blue[100],
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isListening ? Colors.red : Colors.blue,
                  width: 4,
                ),
              ),
              child: Icon(
                _isListening ? Icons.stop : Icons.mic,
                size: 50,
                color: _isListening ? Colors.red : Colors.blue,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Logs
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      _logs[index],
                      style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
