import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'lib/features/home/bloc/expense_bloc.dart';
import 'lib/widgets/dialogs/voice_to_server_dialog.dart';

/// Test Voice to Server - يرسل الصوت مباشرة للسيرفر بتاعك
void main() {
  runApp(const VoiceToServerTestApp());
}

class VoiceToServerTestApp extends StatelessWidget {
  const VoiceToServerTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice to Server Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BlocProvider(
        create: (context) => ExpenseBloc(),
        child: const VoiceToServerTestPage(),
      ),
    );
  }
}

class VoiceToServerTestPage extends StatelessWidget {
  const VoiceToServerTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice to Server Test'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cloud_upload,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),
              const Text(
                'اختبار الصوت → السيرفر',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'يرسل الصوت مباشرة لسيرفرك\nhttps://gradution-project-u39v.onrender.com/voice',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              ElevatedButton.icon(
                onPressed: () => _testVoiceToServer(context),
                icon: const Icon(Icons.mic, size: 28),
                label: const Text(
                  'تسجيل صوتي',
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
                      '1. 🎤 تسجيل الصوت (عربي أو إنجليزي)\n'
                      '2. 📡 إرسال الملف الصوتي للسيرفر\n'
                      '3. 🧠 السيرفر يحول الصوت لنص ويحلله\n'
                      '4. ✅ إضافة المعاملات للتطبيق\n'
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
                      'بالعربي:\n'
                      '• "اشتريت خبز بخمسة جنيه"\n'
                      '• "دفعت عشرين جنيه مواصلات"\n'
                      '• "جبت قهوتين بستين جنيه"\n\n'
                      'بالإنجليزي:\n'
                      '• "I bought bread for 5 EGP"\n'
                      '• "I paid 20 EGP for transport"',
                      style: TextStyle(fontSize: 12),
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
                      'ملاحظة مهمة:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'هذا يستخدم السيرفر بتاعك مباشرة\n'
                      'لذلك يدعم العربي والإنجليزي بشكل كامل\n'
                      'بدلاً من الاعتماد على Android Speech Recognition',
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
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

  void _testVoiceToServer(BuildContext context) async {
    final result = await showVoiceToServerDialog(context);
    
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تحليل الصوت: $result'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}