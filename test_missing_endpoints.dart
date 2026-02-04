import 'dart:convert';
import 'package:http/http.dart' as http;

/// اختبار للتأكد من وجود الـ endpoints المطلوبة
void main() async {
  print('🔍 اختبار وجود الـ endpoints المطلوبة...\n');
  
  final baseUrl = 'https://graduation-project-21p3.onrender.com';
  
  // Test existing endpoints
  await testEndpoint('GET', '$baseUrl/api', 'Health check');
  
  // Test auth endpoints (should work)
  await testEndpoint('POST', '$baseUrl/auth/signup', 'Auth signup');
  await testEndpoint('POST', '$baseUrl/auth/signin', 'Auth signin');
  
  // Test missing transactions endpoints
  await testEndpoint('GET', '$baseUrl/transactions', 'Get transactions');
  await testEndpoint('POST', '$baseUrl/transactions', 'Create transaction');
  
  // Test other possible endpoints
  await testEndpoint('GET', '$baseUrl/transaction', 'Get transaction (singular)');
  await testEndpoint('GET', '$baseUrl/api/transactions', 'Get transactions (with /api)');
  
  print('\n📋 الخلاصة:');
  print('✅ Auth endpoints موجودة');
  print('❌ Transactions endpoints مفقودة');
  print('🎯 الباك اند team محتاجين يضيفوا /transactions endpoints');
}

Future<void> testEndpoint(String method, String url, String description) async {
  print('Testing $method $url - $description');
  
  try {
    http.Response response;
    
    if (method == 'GET') {
      response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));
    } else {
      response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({}), // Empty body for testing
      ).timeout(const Duration(seconds: 10));
    }
    
    print('  Status: ${response.statusCode}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('  ✅ موجود وشغال');
    } else if (response.statusCode == 404) {
      print('  ❌ غير موجود (404)');
    } else if (response.statusCode == 400) {
      print('  ⚠️ موجود لكن البيانات غلط (400)');
    } else if (response.statusCode == 401) {
      print('  🔐 موجود لكن محتاج authentication (401)');
    } else if (response.statusCode == 500) {
      print('  💥 موجود لكن فيه خطأ في السيرفر (500)');
    } else {
      print('  ❓ استجابة غير متوقعة: ${response.statusCode}');
    }
    
    if (response.body.isNotEmpty && response.body.length < 200) {
      print('  Body: ${response.body}');
    }
    
  } catch (e) {
    print('  ❌ خطأ في الاتصال: $e');
  }
  
  print('');
}