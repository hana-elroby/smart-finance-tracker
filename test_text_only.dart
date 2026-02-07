import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduation_project/services/voice_api_service.dart';

/// Text Only Test - Skip microphone, test server directly
void main() {
  runApp(const TextOnlyApp());
}

class TextOnlyApp extends StatelessWidget {
  const TextOnlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'اختبار النص فقط',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: GoogleFonts.cairo().fontFamily,
        useMaterial3: true,
      ),
      home: const TextOnlyPage(),
    );
  }
}

class TextOnlyPage extends StatefulWidget {
  const TextOnlyPage({super.key});

  @override
  State<TextOnlyPage> createState() => _TextOnlyPageState();
}

class _TextOnlyPageState extends State<TextOnlyPage> {
  final VoiceApiService _voiceApiService = VoiceApiService();
  final TextEditingController _textController = TextEditingController();
  
  String _analysisResult = '';
  bool _isAnalyzing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: Text(
          'اختبار السيرفر بالنص',
          style: GoogleFonts.cairo(
            fontSize: 20,
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
            // Instructions
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🎯 اختبار السيرفر مباشرة:',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'اكتب مصروفك بالعربي وهنبعته للسيرفر يحلله',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: Colors.blue[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Text Input
            Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'اكتب مصروفك:',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'مثال: دفعت 25 جنيه على الغداء في مطعم ماكدونالدز',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.green[600]!),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    maxLines: 3,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Quick Examples
                  Text(
                    'أمثلة سريعة:',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildExampleChip('دفعت 50 جنيه على البنزين'),
                      _buildExampleChip('اشتريت خضار بـ 30 جنيه'),
                      _buildExampleChip('فاتورة كهرباء 200 جنيه'),
                      _buildExampleChip('غداء في مطعم 75 جنيه'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Analyze Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _analyzeText,
                icon: _isAnalyzing 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.analytics, size: 24),
                label: Text(
                  _isAnalyzing ? 'جاري التحليل...' : 'تحليل بالسيرفر',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Analysis Result
            if (_analysisResult.isNotEmpty) ...[
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.purple[200]!),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🔍 نتيجة تحليل السيرفر:',
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.purple[800],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.purple[200]!),
                          ),
                          child: Text(
                            _analysisResult,
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: Colors.purple[900],
                              height: 1.5,
                            ),
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

  Widget _buildExampleChip(String text) {
    return GestureDetector(
      onTap: () {
        _textController.text = text;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.green[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green[300]!),
        ),
        child: Text(
          text,
          style: GoogleFonts.cairo(
            fontSize: 12,
            color: Colors.green[800],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Future<void> _analyzeText() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى كتابة النص أولاً',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: Colors.orange[600],
        ),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analysisResult = '';
    });

    try {
      print('📤 Sending to server: $text');
      final result = await _voiceApiService.analyzeText(text);
      
      if (result.isSuccess) {
        setState(() {
          _analysisResult = '''✅ نجح التحليل!

النص الأصلي: $text

استجابة السيرفر:
${result.data.toString()}

---

تفاصيل التحليل:
${_formatAnalysisResult(result.data)}''';
        });
        print('✅ Server success: ${result.data}');
      } else {
        setState(() {
          _analysisResult = '''❌ خطأ من السيرفر:

الرسالة: ${result.message}

النص المرسل: $text

تأكد من اتصال الإنترنت والسيرفر.''';
        });
        print('❌ Server error: ${result.message}');
      }
    } catch (e) {
      setState(() {
        _analysisResult = '''💥 فشل الاتصال بالسيرفر:

الخطأ: $e

النص المرسل: $text

تحقق من اتصال الإنترنت.''';
      });
      print('💥 Connection failed: $e');
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  String _formatAnalysisResult(dynamic data) {
    if (data == null) return 'لا توجد بيانات';
    
    try {
      if (data is Map<String, dynamic>) {
        final analysis = data['data']?['analysis'];
        if (analysis != null) {
          final transactions = analysis['transactions'];
          if (transactions != null && transactions.isNotEmpty) {
            final transaction = transactions[0];
            return '''
المبلغ: ${transaction['amount'] ?? 'غير محدد'}
الفئة: ${transaction['category'] ?? 'غير محدد'}
الوصف: ${transaction['item'] ?? 'غير محدد'}
العملة: ${transaction['currency'] ?? 'غير محدد'}
            ''';
          }
        }
      }
      return 'تم التحليل لكن لم يتم استخراج بيانات المصروف';
    } catch (e) {
      return 'خطأ في تحليل الاستجابة: $e';
    }
  }
}