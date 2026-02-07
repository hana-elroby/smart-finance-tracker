import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/widgets/dialogs/enhanced_voice_dialog.dart';
import 'package:graduation_project/features/home/bloc/expense_bloc.dart';
import 'package:graduation_project/core/theme/app_theme.dart';

/// Test app for Enhanced Voice Dialog
/// Run this to test the new voice functionality
void main() {
  runApp(const TestEnhancedVoiceApp());
}

class TestEnhancedVoiceApp extends StatelessWidget {
  const TestEnhancedVoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enhanced Voice Test',
      theme: AppTheme.lightTheme,
      home: BlocProvider(
        create: (context) => ExpenseBloc(),
        child: const TestVoicePage(),
      ),
    );
  }
}

class TestVoicePage extends StatelessWidget {
  const TestVoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختبار الصوت المحسن'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.mic_rounded,
              size: 80,
              color: Color(0xFF667eea),
            ),
            const SizedBox(height: 24),
            const Text(
              'اختبار تسجيل المصروفات بالصوت',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'اضغط على الزر لفتح نافذة التسجيل الصوتي المحسنة',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showVoiceDialog(context),
              icon: const Icon(Icons.mic),
              label: const Text('فتح تسجيل الصوت'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'جرب قول شيء مثل:\n"دفعت 25 جنيه على الغداء"\n"اشتريت كتاب بـ 50 جنيه"\n"صرفت 100 جنيه على المواصلات"',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showVoiceDialog(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => const EnhancedVoiceDialog(),
    );
    
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}