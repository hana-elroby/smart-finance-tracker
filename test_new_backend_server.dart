import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// اختبار السيرفر الجديد للباك اند
/// https://graduation-project-21p3.onrender.com
void main() {
  runApp(const TestNewBackendApp());
}

class TestNewBackendApp extends StatelessWidget {
  const TestNewBackendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test New Backend Server',
      home: const TestNewBackendPage(),
    );
  }
}

class TestNewBackendPage extends StatefulWidget {
  const TestNewBackendPage({super.key});

  @override
  State<TestNewBackendPage> createState() => _TestNewBackendPageState();
}

class _TestNewBackendPageState extends State<TestNewBackendPage> {
  String _status = 'جاري الاختبار...';
  String _response = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _testNewServer();
  }

  Future<void> _testNewServer() async {
    setState(() {
      _isLoading = true;
      _status = 'جاري اختبار السيرفر الجديد...';
    });

    try {
      // Test 1: Check server availability using /api endpoint
      print('🔍 اختبار الاتصال بالسيرفر الجديد...');
      final baseResponse = await http.get(
        Uri.parse('https://graduation-project-21p3.onrender.com/api'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      print('📡 حالة الاتصال: ${baseResponse.statusCode}');
      print('📄 استجابة السيرفر: ${baseResponse.body}');

      if (baseResponse.statusCode == 200) {
        setState(() {
          _status = '✅ السيرفر الجديد متاح';
          _response = 'Server Response: ${baseResponse.body}';
        });

        // Test 2: Test analyze endpoint
        await _testAnalyzeEndpoint();
      } else {
        setState(() {
          _status = '❌ السيرفر غير متاح - Status: ${baseResponse.statusCode}';
          _response = baseResponse.body;
        });
      }
    } catch (e) {
      print('❌ خطأ في الاتصال: $e');
      setState(() {
        _status = '❌ فشل في الاتصال بالسيرفر';
        _response = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testAnalyzeEndpoint() async {
    try {
      print('🧪 اختبار endpoint التحليل...');
      
      final testTexts = [
        'اشتريت خبز بخمسة جنيه',
        'I bought bread for 5 EGP',
        'shtarit khobz b 5 geneih', // Franco-Arabic
      ];

      for (String testText in testTexts) {
        print('📝 اختبار النص: "$testText"');
        
        final response = await http.post(
          Uri.parse('https://graduation-project-21p3.onrender.com/analyze'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({'text': testText}),
        ).timeout(const Duration(seconds: 30));

        print('📥 استجابة التحليل: ${response.statusCode}');
        print('📄 محتوى الاستجابة: ${response.body}');

        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          if (jsonResponse['success'] == true) {
            setState(() {
              _status = '✅ السيرفر الجديد يعمل بشكل مثالي!';
              _response += '\n\n✅ تحليل "$testText":\n${response.body}';
            });
          } else {
            setState(() {
              _status = '⚠️ السيرفر متاح لكن التحليل فشل';
              _response += '\n\n❌ فشل تحليل "$testText":\n${response.body}';
            });
          }
        } else {
          setState(() {
            _status = '❌ خطأ في endpoint التحليل';
            _response += '\n\n❌ خطأ في "$testText": ${response.statusCode}\n${response.body}';
          });
        }
      }
    } catch (e) {
      print('❌ خطأ في اختبار التحليل: $e');
      setState(() {
        _status = '❌ خطأ في اختبار endpoint التحليل';
        _response += '\n\nError in analyze test: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test New Backend Server'),
        backgroundColor: const Color(0xFF0D5DB8),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Server Info
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
                    'السيرفر الجديد:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D5DB8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'https://graduation-project-21p3.onrender.com',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'monospace',
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Endpoints: /, /analyze',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isLoading 
                    ? Colors.orange.withOpacity(0.1)
                    : _status.contains('✅') 
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isLoading 
                      ? Colors.orange.withOpacity(0.3)
                      : _status.contains('✅') 
                          ? Colors.green.withOpacity(0.3)
                          : Colors.red.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  if (_isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(
                      _status.contains('✅') ? Icons.check_circle : Icons.error,
                      color: _status.contains('✅') ? Colors.green : Colors.red,
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _status,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _isLoading 
                            ? Colors.orange[700]
                            : _status.contains('✅') 
                                ? Colors.green[700]
                                : Colors.red[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Response
            if (_response.isNotEmpty) ...[
              const Text(
                'استجابة السيرفر:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _response,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Retry Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _testNewServer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D5DB8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _isLoading ? 'جاري الاختبار...' : 'إعادة الاختبار',
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
}