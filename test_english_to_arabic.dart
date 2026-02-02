// Voice Test - Final Working Version
// Use this to test the voice system if needed

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'lib/widgets/dialogs/voice_input_dialog_simple.dart';
import 'lib/features/home/bloc/expense_bloc.dart';

void main() {
  runApp(const VoiceTestApp());
}

class VoiceTestApp extends StatelessWidget {
  const VoiceTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice System Test',
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
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text('🎤 Voice System Test'),
        backgroundColor: const Color(0xFF0D5DB8),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.mic_rounded,
              size: 80,
              color: Color(0xFF0D5DB8),
            ),
            const SizedBox(height: 20),
            const Text(
              'Voice System Test\nاختبار نظام الصوت',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D5DB8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await showSimpleVoiceInputDialog(context);
                if (result != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ Result: $result'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.mic_rounded, size: 28),
              label: const Text(
                'Test Voice',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D5DB8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '🎤 Speak in English\n✏️ Edit to Arabic if needed\n🤖 AI understands both\n\n'
                '🎤 اتكلم إنجليزي\n✏️ عدل للعربي لو عايز\n🤖 الذكي الاصطناعي يفهم الاتنين',
                style: TextStyle(fontSize: 14, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}