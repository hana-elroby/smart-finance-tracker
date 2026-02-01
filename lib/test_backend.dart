// Backend API Testing
// اختبار شامل للباك إند

import 'dart:convert';
import 'package:http/http.dart' as http;

class BackendTester {
  static const String baseUrl = 'https://graduation-project-21p3.onrender.com';
  
  static Future<void> testAllEndpoints() async {
    print('🚀 Starting Backend API Tests...');
    print('Base URL: $baseUrl');
    print('=' * 50);
    
    // Test 1: Health Check
    await _testHealthCheck();
    
    // Test 2: Auth Endpoints
    await _testAuthEndpoints();
    
    // Test 3: Transaction Endpoints
    await _testTransactionEndpoints();
    
    // Test 4: Category Endpoints
    await _testCategoryEndpoints();
    
    // Test 5: AI Endpoints
    await _testAIEndpoints();
    
    print('=' * 50);
    print('✅ Backend API Tests Completed!');
  }
  
  static Future<void> _testHealthCheck() async {
    print('\n🔍 Testing Health Check...');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');
      
      if (response.statusCode == 200) {
        print('✅ Health Check: PASSED');
      } else {
        print('❌ Health Check: FAILED');
      }
    } catch (e) {
      print('❌ Health Check: ERROR - $e');
    }
  }
  
  static Future<void> _testAuthEndpoints() async {
    print('\n🔐 Testing Auth Endpoints...');
    
    final authEndpoints = [
      '/auth/signup',
      '/auth/signin', 
      '/auth/changePassword',
      '/auth/resendOTP',
      '/auth/signup/configurationOTP',
    ];
    
    for (final endpoint in authEndpoints) {
      await _testEndpoint('POST', endpoint, {
        'email': 'test@example.com',
        'password': 'test123',
      });
    }
  }
  
  static Future<void> _testTransactionEndpoints() async {
    print('\n💰 Testing Transaction Endpoints...');
    
    // Test GET transactions
    await _testEndpoint('GET', '/transactions');
    
    // Test POST transaction
    await _testEndpoint('POST', '/transactions', {
      'title': 'Test Transaction',
      'amount': 100,
      'category': 'Food',
      'type': 'expense',
    });
    
    // Test AI-powered endpoints
    await _testEndpoint('POST', '/transactions/createWithText', {
      'text': 'Coffee 45 EGP',
    });
    
    await _testEndpoint('POST', '/transactions/createWithVoice', {
      'voiceData': 'test voice data',
    });
  }
  
  static Future<void> _testCategoryEndpoints() async {
    print('\n📂 Testing Category Endpoints...');
    
    await _testEndpoint('GET', '/category');
    await _testEndpoint('POST', '/category', {
      'name': 'Test Category',
      'icon': 'test_icon',
    });
  }
  
  static Future<void> _testAIEndpoints() async {
    print('\n🤖 Testing AI Endpoints...');
    
    await _testEndpoint('POST', '/ai/analyze', {
      'text': 'Coffee 45 pounds',
    });
    
    await _testEndpoint('POST', '/ai/voice', {
      'audioData': 'test audio data',
    });
  }
  
  static Future<void> _testEndpoint(
    String method, 
    String endpoint, [
    Map<String, dynamic>? body,
  ]) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      late http.Response response;
      
      final headers = {'Content-Type': 'application/json'};
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers)
              .timeout(const Duration(seconds: 10));
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(const Duration(seconds: 10));
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(const Duration(seconds: 10));
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers)
              .timeout(const Duration(seconds: 10));
          break;
        default:
          print('❌ $method $endpoint: Unsupported method');
          return;
      }
      
      final status = response.statusCode;
      final statusIcon = _getStatusIcon(status);
      
      print('$statusIcon $method $endpoint: $status');
      
      // Print response body if it's not too long
      if (response.body.length < 200) {
        print('   Response: ${response.body}');
      } else {
        print('   Response: ${response.body.substring(0, 100)}...');
      }
      
    } catch (e) {
      print('❌ $method $endpoint: ERROR - $e');
    }
  }
  
  static String _getStatusIcon(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) {
      return '✅';
    } else if (statusCode >= 400 && statusCode < 500) {
      return '⚠️';
    } else {
      return '❌';
    }
  }
}

// Test function to call from main
Future<void> testBackend() async {
  await BackendTester.testAllEndpoints();
}