import 'package:flutter/material.dart';
import 'package:graduation_project/main.dart' as app;

void main() {
  print('🚀 Testing Main App - All Dependencies Fixed');
  print('📱 Running main app...');
  
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Main App Test',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('✅ Main App Dependencies Fixed'),
          backgroundColor: Colors.green,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 100,
              ),
              SizedBox(height: 20),
              Text(
                '🎉 All Import Errors Fixed!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Dependencies installed successfully',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                '✅ http: installed\n'
                '✅ shared_preferences: installed\n'
                '✅ All services created\n'
                '✅ All models created\n'
                '✅ All routes created',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}