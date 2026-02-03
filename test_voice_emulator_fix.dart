// اختبار حل مشاكل الـ Voice على الـ Android Emulator
// Test Voice Issues Fix on Android Emulator

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'lib/widgets/dialogs/voice_input_dialog_simple.dart';

void main() {
  runApp(const VoiceEmulatorFixTestApp());
}

class VoiceEmulatorFixTestApp extends StatelessWidget {
  const VoiceEmulatorFixTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Emulator Fix Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: GoogleFonts.inter().fontFamily,
      ),
      home: const VoiceEmulatorFixTestPage(),
    );
  }
}

class VoiceEmulatorFixTestPage extends StatefulWidget {
  const VoiceEmulatorFixTestPage({super.key});

  @override
  State<VoiceEmulatorFixTestPage> createState() => _VoiceEmulatorFixTestPageState();
}

class _VoiceEmulatorFixTestPageState extends State<VoiceEmulatorFixTestPage> {
  List<String> _results = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Emulator Fix Test'),
        backgroundColor: const Color(0xFF0D5DB8),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFF59E0B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.build_rounded, color: Colors.white, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Voice Emulator Fix',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'حل مشاكل الـ Voice على الـ Android Emulator',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Test Button
            ElevatedButton.icon(
              onPressed: _testVoiceFix,
              icon: const Icon(Icons.mic_rounded, size: 24),
              label: const Text(
                'Test Fixed Voice Dialog',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
            const SizedBox(height: 24),

            // Problem Analysis
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'المشاكل المكتشفة:',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '❌ اللغات العربية المتاحة: 0\n'
                    '❌ Error 7: error_no_match, error_speech_timeout\n'
                    '❌ rmsDB -2.0 (مستوى صوت ضعيف)\n'
                    '❌ Android Emulator لا يدعم العربي جيداً',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.red[700],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Solutions Applied
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'الحلول المطبقة:',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '✅ تقليل مدة الاستماع (10 ثواني)\n'
                    '✅ تحسين معالجة الأخطاء\n'
                    '✅ إضافة أمثلة سريعة للكتابة\n'
                    '✅ رسائل خطأ أكثر وضوحاً\n'
                    '✅ نصائح للمستخدم',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.green[700],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_rounded, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'كيفية الاختبار:',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1️⃣ اضغط على "Test Fixed Voice Dialog"\n'
                    '2️⃣ جرب التسجيل الصوتي أولاً\n'
                    '3️⃣ إذا لم يعمل، استخدم الأمثلة السريعة\n'
                    '4️⃣ أو اكتب يدوياً في الحقل\n'
                    '5️⃣ لاحظ الرسائل المحسنة',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.blue[700],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Results
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.history_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Test Results (${_results.length})',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _results.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.build_rounded,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No tests run yet',
                                    style: GoogleFonts.inter(
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Press the button above to test the fixes',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _results.length,
                              itemBuilder: (context, index) {
                                final result = _results[index];
                                final isSuccess = result.startsWith('✅');
                                final isWarning = result.startsWith('⚠️');
                                
                                Color cardColor = Colors.grey;
                                if (isSuccess) cardColor = Colors.green;
                                if (isWarning) cardColor = Colors.orange;
                                
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: cardColor.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: cardColor.withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          isSuccess ? Icons.check_rounded : 
                                          isWarning ? Icons.warning_rounded : Icons.info_rounded,
                                          color: cardColor,
                                          size: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          result,
                                          style: GoogleFonts.inter(fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
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

  Future<void> _testVoiceFix() async {
    try {
      final result = await showSimpleVoiceInputDialog(context);
      
      setState(() {
        if (result != null && result.isNotEmpty) {
          _results.insert(0, '✅ Fixed Voice Result: "$result"');
        } else {
          _results.insert(0, '⚠️ Test cancelled or no result (but dialog worked!)');
        }
      });

      if (result != null && result.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Fixed Voice Result: $result'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _results.insert(0, '❌ Error: $e');
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }
}