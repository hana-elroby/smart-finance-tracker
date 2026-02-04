import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// اختبار السيرفرين: الباك اند والفويس
/// Backend: https://graduation-project-21p3.onrender.com
/// Voice: https://gradution-project-u39v.onrender.com
void main() {
  runApp(const TestBothServersApp());
}

class TestBothServersApp extends StatelessWidget {
  const TestBothServersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Both Servers',
      home: const TestBothServersPage(),
    );
  }
}

class TestBothServersPage extends StatefulWidget {
  const TestBothServersPage({super.key});

  @override
  State<TestBothServersPage> createState() => _TestBothServersPageState();
}

class _TestBothServersPageState extends State<TestBothServersPage> {
  String _backendStatus = 'جاري الاختبار...';
  String _voiceStatus = 'جاري الاختبار...';
  String _backendResponse = '';
  String _voiceResponse = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _testBothServers();
  }

  Future<void> _testBothServers() async {
    setState(() {
      _isLoading = true;
      _backendStatus = 'جاري اختبار سيرفر الباك اند...';
      _voiceStatus = 'جاري اختبار سيرفر الفويس...';
    });

    // Test both servers simultaneously
    await Future.wait([
      _testBackendServer(),
      _testVoiceServer(),
    ]);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testBackendServer() async {
    const backendUrl = 'https://graduation-project-21p3.onrender.com';
    
    try {
      print('🔍 اختبار سيرفر الباك اند...');
      
      // Test /api endpoint directly (we know / is slow)
      final response = await http.get(
        Uri.parse('$backendUrl/api'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      print('📡 Backend Status: ${response.statusCode}');
      print('📄 Backend Response: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          _backendStatus = '✅ سيرفر الباك اند متاح ويعمل بشكل مثالي!';
          _backendResponse = 'Status: ${response.statusCode}\nEndpoint: /api\nResponse: ${response.body}';
        });
      } else {
        setState(() {
          _backendStatus = '❌ سيرفر الباك اند غير متاح - Status: ${response.statusCode}';
          _backendResponse = 'Error: ${response.body}';
        });
      }
    } catch (e) {
      print('❌ خطأ في سيرفر الباك اند: $e');
      setState(() {
        _backendStatus = '❌ فشل في الاتصال بسيرفر الباك اند';
        _backendResponse = 'Error: $e';
      });
    }
  }

  Future<void> _testBackendHealthCheck() async {
    try {
      // Use /api endpoint which is working
      final response = await http.get(
        Uri.parse('https://graduation-project-21p3.onrender.com/api'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() {
          _backendStatus = '✅ سيرفر الباك اند يعمل بشكل مثالي!';
          _backendResponse += '\n\n✅ Health Check (/api): ${response.body}';
        });
      }
    } catch (e) {
      print('⚠️ Health check failed: $e');
    }
  }

  Future<void> _testVoiceServer() async {
    const voiceUrl = 'https://gradution-project-u39v.onrender.com';
    
    try {
      print('🔍 اختبار سيرفر الفويس...');
      
      // Test main page (should work)
      final response = await http.get(
        Uri.parse(voiceUrl),
        headers: {'Accept': 'text/html,application/json'},
      ).timeout(const Duration(seconds: 15));

      print('📡 Voice Status: ${response.statusCode}');
      print('📄 Voice Response Length: ${response.body.length} chars');

      if (response.statusCode == 200) {
        setState(() {
          _voiceStatus = '✅ سيرفر الفويس متاح';
          _voiceResponse = 'Status: ${response.statusCode}\nResponse: Voice analyzer interface loaded successfully';
        });

        // Test voice analyze endpoint with POST
        await _testVoiceAnalyze();
      } else {
        setState(() {
          _voiceStatus = '❌ سيرفر الفويس غير متاح - Status: ${response.statusCode}';
          _voiceResponse = 'Error: ${response.body}';
        });
      }
    } catch (e) {
      print('❌ خطأ في سيرفر الفويس: $e');
      setState(() {
        _voiceStatus = '❌ فشل في الاتصال بسيرفر الفويس';
        _voiceResponse = 'Error: $e';
      });
    }
  }

  Future<void> _testVoiceAnalyze() async {
    try {
      final testText = 'اشتريت خبز بخمسة جنيه';
      
      final response = await http.post(
        Uri.parse('https://gradution-project-u39v.onrender.com/analyze'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'text': testText}),
      ).timeout(const Duration(seconds: 30));

      print('📥 Voice Analyze: ${response.statusCode}');
      print('📄 Voice Analyze Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          setState(() {
            _voiceStatus = '✅ سيرفر الفويس يعمل بشكل مثالي!';
            _voiceResponse += '\n\n✅ تحليل النص:\n${response.body}';
          });
        } else {
          setState(() {
            _voiceStatus = '⚠️ سيرفر الفويس متاح لكن التحليل فشل';
            _voiceResponse += '\n\n❌ فشل التحليل:\n${response.body}';
          });
        }
      } else {
        setState(() {
          _voiceStatus = '❌ خطأ في endpoint التحليل';
          _voiceResponse += '\n\n❌ خطأ في التحليل: ${response.statusCode}\n${response.body}';
        });
      }
    } catch (e) {
      print('❌ خطأ في اختبار التحليل: $e');
      setState(() {
        _voiceStatus = '❌ خطأ في اختبار endpoint التحليل';
        _voiceResponse += '\n\nError in analyze test: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Both Servers'),
        backgroundColor: const Color(0xFF0D5DB8),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Servers Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0D5DB8).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF0D5DB8).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'السيرفرات المستخدمة:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D5DB8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '🔧 Backend: https://graduation-project-21p3.onrender.com',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '🎤 Voice: https://gradution-project-u39v.onrender.com',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: Color(0xFF374151),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Backend Server Status
            _buildServerStatusCard(
              title: '🔧 Backend Server',
              status: _backendStatus,
              response: _backendResponse,
            ),

            const SizedBox(height: 16),

            // Voice Server Status
            _buildServerStatusCard(
              title: '🎤 Voice Server',
              status: _voiceStatus,
              response: _voiceResponse,
            ),

            const Spacer(),

            // Retry Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _testBothServers,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D5DB8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _isLoading ? 'جاري الاختبار...' : 'إعادة اختبار السيرفرين',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServerStatusCard({
    required String title,
    required String status,
    required String response,
  }) {
    final isSuccess = status.contains('✅');
    final isError = status.contains('❌');
    final isLoading = status.contains('جاري');

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isLoading 
              ? Colors.orange.withOpacity(0.1)
              : isSuccess 
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isLoading 
                ? Colors.orange.withOpacity(0.3)
                : isSuccess 
                    ? Colors.green.withOpacity(0.3)
                    : Colors.red.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),

            // Status
            Row(
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    isSuccess ? Icons.check_circle : Icons.error,
                    color: isSuccess ? Colors.green : Colors.red,
                    size: 16,
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isLoading 
                          ? Colors.orange[700]
                          : isSuccess 
                              ? Colors.green[700]
                              : Colors.red[700],
                    ),
                  ),
                ),
              ],
            ),

            // Response
            if (response.isNotEmpty) ...[
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      response,
                      style: const TextStyle(
                        fontSize: 10,
                        fontFamily: 'monospace',
                        color: Color(0xFF374151),
                      ),
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
}