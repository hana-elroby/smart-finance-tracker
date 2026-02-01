import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

/// Debug Voice Recognition - تشخيص مشاكل التعرف على الصوت
class VoiceDebugPage extends StatefulWidget {
  const VoiceDebugPage({super.key});

  @override
  State<VoiceDebugPage> createState() => _VoiceDebugPageState();
}

class _VoiceDebugPageState extends State<VoiceDebugPage> {
  final SpeechToText _speechToText = SpeechToText();
  String _debugInfo = 'Starting debug...\n';
  bool _isListening = false;
  String _recognizedText = '';

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  void _addDebugInfo(String info) {
    setState(() {
      _debugInfo += '$info\n';
    });
    print(info);
  }

  Future<void> _runDiagnostics() async {
    _addDebugInfo('🔍 Starting Voice Recognition Diagnostics...');
    
    // Step 1: Check permissions
    _addDebugInfo('📋 Step 1: Checking permissions...');
    final micPermission = await Permission.microphone.status;
    _addDebugInfo('🎤 Microphone permission: $micPermission');
    
    if (micPermission != PermissionStatus.granted) {
      _addDebugInfo('⚠️ Requesting microphone permission...');
      final result = await Permission.microphone.request();
      _addDebugInfo('🎤 Permission result: $result');
    }

    // Step 2: Check speech recognition availability
    _addDebugInfo('📋 Step 2: Checking speech recognition...');
    try {
      final available = await _speechToText.initialize(
        onError: (error) {
          _addDebugInfo('❌ Speech error: ${error.errorMsg} (${error.permanent})');
        },
        onStatus: (status) {
          _addDebugInfo('📊 Speech status: $status');
        },
        debugLogging: true,
      );
      
      _addDebugInfo('✅ Speech recognition available: $available');
      
      if (available) {
        // Step 3: Check supported locales
        _addDebugInfo('📋 Step 3: Checking supported languages...');
        final locales = await _speechToText.locales();
        _addDebugInfo('🌍 Available locales: ${locales.length}');
        
        for (final locale in locales.take(5)) {
          _addDebugInfo('   - ${locale.localeId}: ${locale.name}');
        }
        
        // Check for Arabic and English
        final hasArabic = locales.any((l) => l.localeId.startsWith('ar'));
        final hasEnglish = locales.any((l) => l.localeId.startsWith('en'));
        _addDebugInfo('🇸🇦 Arabic support: $hasArabic');
        _addDebugInfo('🇺🇸 English support: $hasEnglish');
        
        // Step 4: Test basic listening
        _addDebugInfo('📋 Step 4: Ready for voice test!');
        _addDebugInfo('✅ All checks passed. Tap "Test Voice" to try recording.');
      } else {
        _addDebugInfo('❌ Speech recognition not available on this device');
      }
    } catch (e) {
      _addDebugInfo('❌ Error during initialization: $e');
    }
  }

  Future<void> _testVoiceRecognition() async {
    if (_isListening) {
      await _speechToText.stop();
      setState(() {
        _isListening = false;
      });
      _addDebugInfo('🛑 Stopped listening');
      return;
    }

    _addDebugInfo('🎤 Starting voice test...');
    setState(() {
      _isListening = true;
      _recognizedText = '';
    });

    try {
      await _speechToText.listen(
        onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords;
          });
          _addDebugInfo('🎯 Recognized: "${result.recognizedWords}" (confidence: ${result.confidence})');
          
          if (result.finalResult) {
            _addDebugInfo('✅ Final result received');
            setState(() {
              _isListening = false;
            });
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: 'en-US', // Start with English
        listenMode: ListenMode.dictation,
        cancelOnError: true,
        onSoundLevelChange: (level) {
          // Don't log every sound level change to avoid spam
        },
      );
      
      _addDebugInfo('🎤 Listening started successfully');
    } catch (e) {
      _addDebugInfo('❌ Failed to start listening: $e');
      setState(() {
        _isListening = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Debug'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Debug info
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _debugInfo,
                    style: const TextStyle(
                      color: Colors.green,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Recognized text
            if (_recognizedText.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recognized Text:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _recognizedText,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Test button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _testVoiceRecognition,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isListening ? Colors.red : Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isListening ? Icons.stop : Icons.mic,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isListening ? 'Stop Recording' : 'Test Voice Recognition',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
}

// Test function to run from main
void main() {
  runApp(MaterialApp(
    home: const VoiceDebugPage(),
    debugShowCheckedModeBanner: false,
  ));
}