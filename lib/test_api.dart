// Test API Connection
// ملف اختبار الاتصال بالـ API

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'core/config/api_config.dart';

class ApiTester {
  static Future<void> testConnection() async {
    print('🔄 Testing API connection...');
    print('Base URL: ${ApiConfig.baseUrl}');
    
    try {
      // Test health check
      final healthResponse = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      print('✅ Health Check: ${healthResponse.statusCode}');
      print('Response: ${healthResponse.body}');
      
      // Test auth endpoints
      await _testAuthEndpoints();
      
      // Test other endpoints
      await _testOtherEndpoints();
      
    } catch (e) {
      print('❌ Connection failed: $e');
    }
  }
  
  static Future<void> _testAuthEndpoints() async {
    print('\n🔐 Testing Auth Endpoints...');
    
    final endpoints = [
      '/auth/signup',
      '/auth/signin',
      '/auth/changePassword',
    ];
    
    for (final endpoint in endpoints) {
      try {
        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}$endpoint'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({}), // Empty body to test endpoint existence
        ).timeout(const Duration(seconds: 5));
        
        print('$endpoint: ${response.statusCode}');
      } catch (e) {
        print('$endpoint: Error - $e');
      }
    }
  }
  
  static Future<void> _testOtherEndpoints() async {
    print('\n📊 Testing Other Endpoints...');
    
    final endpoints = [
      '/transactions',
      '/category',
      '/ai/analyze',
    ];
    
    for (final endpoint in endpoints) {
      try {
        final response = await http.get(
          Uri.parse('${ApiConfig.baseUrl}$endpoint'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 5));
        
        print('$endpoint: ${response.statusCode}');
      } catch (e) {
        print('$endpoint: Error - $e');
      }
    }
  }
}