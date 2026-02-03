import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'lib/features/home/bloc/expense_bloc.dart';
import 'lib/widgets/dialogs/voice_input_dialog_with_api.dart';

/// Test Voice + API Integration
/// يجرب الـ Voice البسيط الشغال + الـ APIs بتوعك
void main() {
  runApp(const VoiceWithAPITestApp());
}

class VoiceWithAPITestApp extends StatelessWidget {
  const VoiceWithAPITestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice + API Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BlocProvider(
        create: (context) => ExpenseBloc(),
        child: const VoiceWithAPITestPage(),
      ),
    );
  }
}

class VoiceWithAPITestPage extends StatelessWidget {
  const VoiceWithAPITestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice + API Test'),
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
                'اختبار Voice + API',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'يستخدم الـ Voice البسيط الشغال\n+ الـ APIs بتوعك بدون تعديل',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              ElevatedButton.icon(
                onPressed: () => _testVoiceWithAPI(context),
                icon: const Icon(Icons.mic, size: 28),
                label: const Text(
                  'اختبار Voice + API',
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
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: const Column(
                  children: [
                    Text(
                      'ما سيحدث:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. 🎤 Voice يسمع الكلام ويحوله لنص\n'
                      '2. 📡 إرسال النص للـ API بتاعك\n'
                      '3. 🧠 الـ API يحلل النص كما هو\n'
                      '4. ✅ إضافة النتيجة للتطبيق\n'
                      '5. 📊 عرض في الـ Chart بالكمية الصحيحة',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
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
                      'جرب هذه الأمثلة:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• "اشتريت خبز بـ 5 جنيه"\n'
                      '• "دفعت 20 جنيه مواصلات"\n'
                      '• "صرفت 50 جنيه على أكل"\n'
                      '• "I bought 2 coffee for 60 EGP"',
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

  void _testVoiceWithAPI(BuildContext context) async {
    final result = await showVoiceInputDialogWithAPI(context);
    
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم معالجة: $result'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}