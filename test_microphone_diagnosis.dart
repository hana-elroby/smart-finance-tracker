import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduation_project/services/voice_service.dart';
import 'package:graduation_project/services/voice_api_service.dart';

/// Microphone Diagnosis - Test what's actually working
void main() {
  runApp(const MicrophoneDiagnosisApp());
}

class MicrophoneDiagnosisApp extends StatelessWidget {
  const MicrophoneDiagnosisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Microphone Diagnosis',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: GoogleFonts.cairo().fontFamily,
        useMaterial3: true,
      ),
      home: const MicrophoneDiagnosisPage(),
    );
  }
}

class MicrophoneDiagnosisPage extends StatefulWidget {
  const MicrophoneDiagnosisPage({super.key});

  @override
  State<MicrophoneDiagnosisPage> createState() => _MicrophoneDiagnosisPageState();
}

class _MicrophoneDiagnosisPageState extends State<MicrophoneDiagnosisPage> {
  final VoiceService _voiceService = VoiceService();
  final VoiceApiService _voiceApiService = VoiceApiService();
  
  bool _isListening = false;
  String _recognizedText = '';
  String _statusMessage = 'Ready to test';
  String _analysisResult = '';
  double _soundLevel = 0.0;
  String _testResults = '';

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _testResults = 'Running diagnostics...\n';
    });

    // Test 1: Voice service initialization
    final initialized = await _voiceService.initialize();
    setState(() {
      _testResults += '✅ Voice service initialized: $initialized\n';
    });

    // Test 2: Available languages
    final languages = await _voiceService.getAvailableLanguages();
    setState(() {
      _testResults += '📋 Available languages: ${languages.length}\n';
      for (int i = 0; i < languages.length && i < 5; i++) {
        _testResults += '   - ${languages[i]}\n';
      }
      if (languages.length > 5) {
        _testResults += '   ... and ${languages.length - 5} more\n';
      }
    });

    // Test 3: Server connection
    final serverConnected = await _voiceApiService.testConnection();
    setState(() {
      _testResults += '🌐 Server connection: $serverConnected\n';
    });

    // Test 4: Device support
    final deviceSupported = await _voiceService.isDeviceSupported();
    setState(() {
      _testResults += '📱 Device supported: $deviceSupported\n';
    });

    setState(() {
      _testResults += '\n🎯 DIAGNOSIS COMPLETE\n';
      _testResults += '💡 Try speaking in ENGLISH first!\n';
      _testResults += '💡 Say: "I spent 25 dollars on lunch"\n';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Microphone Diagnosis',
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
            // Microphone Test Section
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
                  // Microphone Icon with Sound Level
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: _isListening ? Colors.red : const Color(0xFF667eea),
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
                  
                  // Sound Level Display
                  if (_isListening) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Sound Level: ${_soundLevel.toStringAsFixed(1)} dB',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _soundLevel > -20 ? Colors.green : Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: ((_soundLevel + 50) / 100).clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _soundLevel > -20 ? Colors.green : Colors.orange,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _soundLevel > -20 ? '🔊 Good sound level!' : '🔇 Speak louder!',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: _soundLevel > -20 ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

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
                  _isListening ? 'Stop Test' : 'Test Microphone',
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

            const SizedBox(height: 20),

            // Results Section
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Diagnosis Results:',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _testResults,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                      
                      if (_recognizedText.isNotEmpty) ...[
                        const SizedBox(height: 20),
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
                                '✅ SUCCESS! Recognized Text:',
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
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
                              ElevatedButton(
                                onPressed: _testServerAnalysis,
                                child: Text('Test Server Analysis'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[600],
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      if (_analysisResult.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '🔍 Server Analysis Result:',
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.blue[800],
                                ),
                              ),
                              const SizedBox(height: 8),
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
                      ],
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
    setState(() {
      _isListening = true;
      _statusMessage = 'Starting microphone...';
      _recognizedText = '';
      _analysisResult = '';
    });

    try {
      await _voiceService.startListening(
        onResult: (text) {
          setState(() {
            _recognizedText = text;
            _statusMessage = '✅ WORKING! Keep speaking...';
          });
          print('🎯 SUCCESS: $text');
        },
        onError: (error) {
          setState(() {
            _isListening = false;
            _statusMessage = '❌ Error: $error';
          });
          print('❌ Error: $error');
        },
        onSoundLevel: (level) {
          setState(() {
            _soundLevel = level;
            if (level > -20) {
              _statusMessage = '🔊 Good! Microphone is working. Speak clearly...';
            } else {
              _statusMessage = '🔇 Microphone working but speak louder...';
            }
          });
        },
      );
    } catch (e) {
      setState(() {
        _isListening = false;
        _statusMessage = '💥 Failed to start: $e';
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
            ? '✅ Test completed successfully!' 
            : '⚠️ No speech recognized. Try English phrases.';
      });
    } catch (e) {
      setState(() {
        _isListening = false;
        _statusMessage = 'Stop error: $e';
      });
    }
  }

  Future<void> _testServerAnalysis() async {
    if (_recognizedText.isEmpty) return;

    setState(() {
      _analysisResult = 'Testing server...';
    });

    try {
      final result = await _voiceApiService.analyzeText(_recognizedText);
      
      if (result.isSuccess) {
        setState(() {
          _analysisResult = '✅ Server working!\nResponse: ${result.data.toString()}';
        });
      } else {
        setState(() {
          _analysisResult = '❌ Server error: ${result.message}';
        });
      }
    } catch (e) {
      setState(() {
        _analysisResult = '💥 Analysis failed: $e';
      });
    }
  }
}