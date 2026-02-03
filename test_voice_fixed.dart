import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'lib/features/home/bloc/expense_bloc.dart';
import 'lib/widgets/dialogs/voice_input_dialog_fixed.dart';

/// Test Fixed Voice Input
/// هذا التطبيق لاختبار الـ voice الجديد المبسط
void main() {
  runApp(const VoiceFixedTestApp());
}

class VoiceFixedTestApp extends StatelessWidget {
  const VoiceFixedTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Fixed Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BlocProvider(
        create: (context) => ExpenseBloc(),
        child: const VoiceTestPage(),
      ),
    );
  }
}

class VoiceTestPage extends StatelessWidget {
  const VoiceTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Test - Fixed'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.mic,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),
              const Text(
                'اختبار الميكروفون المحسن',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'هذا الإصدار مبسط ومحسن للتأكد من عمل الميكروفون',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              ElevatedButton.icon(
                onPressed: () => _testVoice(context),
                icon: const Icon(Icons.mic, size: 28),
                label: const Text(
                  'اختبار الميكروفون',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: const Column(
                  children: [
                    Text(
                      'ما يجب أن يحدث:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. يطلب إذن الميكروفون\n'
                      '2. يبدأ الاستماع (أيقونة حمراء)\n'
                      '3. يعرض النص أثناء الكلام\n'
                      '4. يمكن الكتابة يدوياً كبديل\n'
                      '5. يرسل النص للتحليل',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: const Column(
                  children: [
                    Text(
                      'إذا لم يعمل الميكروفون:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• تأكد من إذن الميكروفون\n'
                      '• جرب على جهاز حقيقي\n'
                      '• استخدم الكتابة اليدوية\n'
                      '• اختر من الأمثلة السريعة',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _testVoice(BuildContext context) async {
    final result = await showFixedVoiceInputDialog(context);
    
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم استلام: $result'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}