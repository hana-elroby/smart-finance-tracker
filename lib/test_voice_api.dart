// Test Voice API - اختبار الـ Voice API
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> testVoiceAPI() async {
  const baseUrl = 'https://voice-finance-analyzer-production.up.railway.app';
  
  print('🎤 Testing Voice Finance Analyzer API...');
  print('Base URL: $baseUrl');
  print('=' * 50);
  
  // Test 1: Health Check
  await _testHealthCheck(baseUrl);
  
  // Test 2: Text Analysis
  await _testTextAnalysis(baseUrl);
  
  print('=' * 50);
  print('✅ Voice API Tests Completed!');
}

Future<void> _testHealthCheck(String baseUrl) async {
  print('\n🔍 Testing Health Check...');
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 10));
    
    print('Status: ${response.statusCode}');
    print('Response: ${response.body.substring(0, 100)}...');
    
    if (response.statusCode == 200) {
      print('✅ Voice API is online!');
    } else {
      print('❌ Voice API health check failed');
    }
  } catch (e) {
    print('❌ Health Check Error: $e');
  }
}

Future<void> _testTextAnalysis(String baseUrl) async {
  print('\n📝 Testing Text Analysis...');
  
  final testTexts = [
    'قهوة 45 جنيه',
    'Coffee 25 EGP',
    'غداء 120 جنيه في المطعم',
    'Lunch 80 pounds',
    'بنزين 200 جنيه',
  ];
  
  for (final text in testTexts) {
    try {
      print('\n🔍 Testing: "$text"');
      
      final response = await http.post(
        Uri.parse('$baseUrl/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      ).timeout(const Duration(seconds: 15));
      
      print('Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Analysis Result:');
        print('   ${jsonEncode(data)}');
      } else {
        print('❌ Analysis failed: ${response.body}');
      }
      
    } catch (e) {
      print('❌ Error analyzing "$text": $e');
    }
  }
}