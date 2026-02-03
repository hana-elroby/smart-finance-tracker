// اختبار الـ Voice المستمر - يفضل شغال لحد ما المستخدم يوقفه
// Test Continuous Voice - Stays active until user stops it

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'lib/widgets/dialogs/voice_input_dialog_simple.dart';

void main() {
  runApp(const ContinuousVoiceTestApp());
}

class ContinuousVoiceTestApp extends StatelessWidget {
  const ContinuousVoiceTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Continuous Voice Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: GoogleFonts.inter().fontFamily,
      ),
      home: const ContinuousVoiceTestPage(),
    );
  }
}

class ContinuousVoiceTestPage extends StatefulWidget {
  const ContinuousVoiceTestPage({super.key});

  @override
  State<ContinuousVoiceTestPage> createState() => _ContinuousVoiceTestPageState();
}

class _ContinuousVoiceTestPageState extends State<ContinuousVoiceTestPage> {
  List<String> _results = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Continuous Voice Test'),
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
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.record_voice_over, color: Colors.white, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Continuous Voice Recording',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'المايك هيفضل شغال لحد ما توقفه بنفسك',
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
              onPressed: _testContinuousVoice,
              icon: const Icon(Icons.mic_rounded, size: 24),
              label: const Text(
                'Test Continuous Voice (5 minutes)',
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

            // New Features
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
                      const Icon(Icons.new_releases, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'الميزات الجديدة:',
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
                    '🎤 المايك يفضل شغال لمدة 5 دقائق\n'
                    '📝 النص يتحدث في الوقت الفعلي\n'
                    '⏸️ 3 ثواني توقف بين الجمل\n'
                    '🔄 عرض النتائج الجزئية\n'
                    '🛑 المستخدم يوقف المايك بنفسه',
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
                    '1️⃣ اضغط على "Test Continuous Voice"\n'
                    '2️⃣ ابدأ الكلام واستمر لفترة طويلة\n'
                    '3️⃣ لاحظ النص يتحدث في الوقت الفعلي\n'
                    '4️⃣ اضغط على زر الإيقاف لما تخلص\n'
                    '5️⃣ جرب تقول جمل متعددة ومصاريف مختلفة',
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

            // Example Sentences
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.record_voice_over, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'جرب تقول الجمل دي:',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '🗣️ "اشتريت خبز بخمسة جنيه من البقالة"\n'
                    '🗣️ "دفعت عشرين جنيه مواصلات النهاردة"\n'
                    '🗣️ "صرفت خمسين جنيه على أكل في المطعم"\n'
                    '🗣️ "اشتريت دواء من الصيدلية بتلاتين جنيه"\n'
                    '🗣️ "دفعت فاتورة الكهرباء مائتين جنيه"',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.orange[700],
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
                          'Continuous Voice Results (${_results.length})',
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
                                    Icons.record_voice_over,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No continuous voice tests yet',
                                    style: GoogleFonts.inter(
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Press the button above to test continuous recording',
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
                                final isLong = result.length > 50;
                                
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isLong 
                                          ? Colors.green.withValues(alpha: 0.3)
                                          : Colors.blue.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: (isLong ? Colors.green : Colors.blue)
                                              .withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          isLong ? Icons.check_circle : Icons.mic_rounded,
                                          color: isLong ? Colors.green : Colors.blue,
                                          size: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              result,
                                              style: GoogleFonts.inter(fontSize: 12),
                                            ),
                                            if (isLong) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                '✅ Long recording detected (${result.length} chars)',
                                                style: GoogleFonts.inter(
                                                  fontSize: 10,
                                                  color: Colors.green[600],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ],
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

  Future<void> _testContinuousVoice() async {
    try {
      final result = await showSimpleVoiceInputDialog(context);
      
      setState(() {
        if (result != null && result.isNotEmpty) {
          _results.insert(0, '🎤 Continuous Voice: "$result"');
        } else {
          _results.insert(0, 'ℹ️ Test cancelled or no continuous input');
        }
      });

      if (result != null && result.isNotEmpty) {
        final isLongRecording = result.length > 50;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isLongRecording 
                  ? '✅ Great! Long continuous recording: ${result.length} characters'
                  : '🎤 Continuous Voice: $result'
            ),
            backgroundColor: isLongRecording ? Colors.green : const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: Duration(seconds: isLongRecording ? 5 : 3),
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