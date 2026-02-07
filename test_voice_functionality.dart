import 'package:flutter/material.dart';
import 'package:graduation_project/services/voice_service.dart';
import 'package:graduation_project/services/voice_api_service.dart';

/// Simple test to verify voice functionality
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🧪 Testing Voice Functionality...');
  
  // Test 1: Voice Service Initialization
  final voiceService = VoiceService();
  final initialized = await voiceService.initialize();
  print('✅ Voice Service Initialized: $initialized');
  
  // Test 2: Voice API Service
  final voiceApiService = VoiceApiService();
  try {
    final result = await voiceApiService.analyzeText('اشتريت قهوة بـ 25 جنيه');
    print('✅ Voice API Test: ${result.isSuccess ? 'SUCCESS' : 'FAILED'}');
    if (result.isSuccess) {
      print('   Analysis: ${result.data}');
    } else {
      print('   Error: ${result.message}');
    }
  } catch (e) {
    print('❌ Voice API Error: $e');
  }
  
  print('🧪 Voice functionality test completed!');
}