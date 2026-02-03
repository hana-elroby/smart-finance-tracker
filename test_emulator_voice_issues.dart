// اختبار مشاكل الـ Voice على الـ Android Emulator
// Test Voice Issues on Android Emulator

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'lib/widgets/dialogs/voice_input_dialog_simple.dart';

void main() {
  runApp(const EmulatorVoiceIssuesTestApp());
}

class EmulatorVoiceIssuesTestApp extends StatelessWidget {
  const EmulatorVoiceIssuesTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emulator Voice Issues Test',
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: GoogleFonts.inter().fontFamily,
      ),
      home: const EmulatorVoiceIssuesTestPage(),
    );
  }
}

class EmulatorVoiceIssuesTestPage extends StatefulWidget {
  const EmulatorVoiceIssuesTestPage({super.key});

  @override
  State<EmulatorVoiceIssuesTestPage> createState() => _EmulatorVoiceIssuesTestPageState();
}

class _EmulatorVoiceIssuesTestPageState extends State<EmulatorVoiceIssuesTestPage> {
  List<String> _results = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Android Emulator Voice Issues'),
        backgroundColor: Colors.red[600],
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
                gradient: LinearGradient(
                  colors: [Colors.red[600]!, Colors.orange[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.warning_rounded, color: Colors.white, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Android Emulator Voice Issues',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'مشاكل الصوت على الـ Android Emulator',
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
              onPressed: _testEmulatorVoice,
              icon: const Icon(Icons.mic_off_rounded, size: 24),
              label: const Text(
                'Test Voice (Will Likely Fail on Emulator)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
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
                      const Icon(Icons.bug_report, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'مشاكل الـ Android Emulator:',
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
                    '❌ مستوى الصوت ضعيف جداً (rmsDB -2.0)\n'
                    '❌ الميكروفون مش بيسمع صوت خالص\n'
                    '❌ error_speech_timeout بعد ثواني قليلة\n'
                    '❌ مفيش دعم كويس للعربي (0 لغات عربية)\n'
                    '❌ مشاكل في الـ Audio Input على الـ Virtual Device',
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

            // Solutions
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
                      const Icon(Icons.lightbulb, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'الحلول المتاحة:',
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
                    '✅ استخدم جهاز أندرويد حقيقي\n'
                    '✅ استخدم الأمثلة السريعة في التطبيق\n'
                    '✅ اكتب يدوياً في حقل النص\n'
                    '✅ الـ API يعمل مثالي مع النص المكتوب\n'
                    '✅ كل الميزات شغالة عدا التعرف على الصوت',
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

            // Real Device Instructions
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
                      const Icon(Icons.smartphone, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'للاختبار على جهاز حقيقي:',
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
                    '1️⃣ وصل الموبايل بالـ USB\n'
                    '2️⃣ فعل الـ USB Debugging\n'
                    '3️⃣ شغل: flutter devices\n'
                    '4️⃣ شغل: flutter run -d [device-id]\n'
                    '5️⃣ جرب الـ Voice Input على الجهاز الحقيقي',
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

            // Alternative Testing
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.keyboard, color: Colors.purple, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'اختبار بديل (بدون صوت):',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '⌨️ اكتب: "اشتريت خبز بـ 5 جنيه"\n'
                    '⌨️ اكتب: "دفعت 20 جنيه مواصلات"\n'
                    '⌨️ اكتب: "صرفت 50 جنيه على أكل"\n'
                    '🔍 شوف الـ API يحلل النص ويستخرج البيانات\n'
                    '✅ كل حاجة هتشتغل عادي عدا الصوت',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.purple[700],
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
                                    Icons.warning_rounded,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No emulator tests yet',
                                    style: GoogleFonts.inter(
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Press the button above to see emulator issues',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.grey[400],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _results.length,
                              itemBuilder: (context, index) {
                                final result = _results[index];
                                final isError = result.startsWith('❌');
                                final isWarning = result.startsWith('⚠️');
                                final isSuccess = result.startsWith('✅');
                                
                                Color cardColor = Colors.grey;
                                if (isError) cardColor = Colors.red;
                                if (isWarning) cardColor = Colors.orange;
                                if (isSuccess) cardColor = Colors.green;
                                
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
                                          isError ? Icons.error_rounded : 
                                          isWarning ? Icons.warning_rounded :
                                          isSuccess ? Icons.check_rounded : Icons.info_rounded,
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

  Future<void> _testEmulatorVoice() async {
    try {
      final result = await showSimpleVoiceInputDialog(context);
      
      setState(() {
        if (result != null && result.isNotEmpty) {
          _results.insert(0, '✅ Unexpected Success: "$result" (Typed manually?)');
        } else {
          _results.insert(0, '⚠️ Expected: Voice failed on emulator, but dialog worked');
        }
      });

      if (result != null && result.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Got result (probably typed): $result'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('⚠️ Voice failed as expected on emulator'),
            backgroundColor: Colors.orange,
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