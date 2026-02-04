import 'dart:convert';
import 'package:http/http.dart' as http;

/// اختبار مفصل لاتصال سيرفر الباك اند
/// يختبر كل endpoint ويطبع تفاصيل كاملة
void main() async {
  print('🔍 بدء اختبار مفصل لسيرفر الباك اند...\n');
  
  // 1. اختبار الاتصال الأساسي
  await testBasicConnection();
  
  // 2. اختبار GET /transactions
  await testGetTransactions();
  
  // 3. اختبار POST /transactions
  await testPostTransaction();
  
  // 4. اختبار endpoints أخرى
  await testOtherEndpoints();
  
  print('\n✅ انتهى الاختبار المفصل');
}

Future<void> testBasicConnection() async {
  print('📡 اختبار 1: الاتصال الأساسي');
  print('URL: https://graduation-project-21p3.onrender.com/api');
  
  try {
    final response = await http.get(
      Uri.parse('https://graduation-project-21p3.onrender.com/api'),
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 15));

    print('Status Code: ${response.statusCode}');
    print('Headers: ${response.headers}');
    print('Body: ${response.body}');
    
    if (response.statusCode == 200) {
      print('✅ الاتصال الأساسي نجح\n');
    } else {
      print('❌ الاتصال الأساسي فشل\n');
    }
  } catch (e) {
    print('❌ خطأ في الاتصال الأساسي: $e\n');
  }
}

Future<void> testGetTransactions() async {
  print('📥 اختبار 2: جلب المعاملات (GET /transactions)');
  print('URL: https://graduation-project-21p3.onrender.com/transactions');
  
  try {
    final response = await http.get(
      Uri.parse('https://graduation-project-21p3.onrender.com/transactions'),
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 15));

    print('Status Code: ${response.statusCode}');
    print('Headers: ${response.headers}');
    print('Body: ${response.body}');
    
    if (response.statusCode == 200) {
      try {
        final jsonData = jsonDecode(response.body);
        print('JSON parsed successfully');
        print('Data type: ${jsonData.runtimeType}');
        if (jsonData is List) {
          print('Number of transactions: ${jsonData.length}');
        } else if (jsonData is Map) {
          print('Response keys: ${jsonData.keys}');
        }
        print('✅ جلب المعاملات نجح\n');
      } catch (e) {
        print('❌ خطأ في تحليل JSON: $e\n');
      }
    } else {
      print('❌ جلب المعاملات فشل\n');
    }
  } catch (e) {
    print('❌ خطأ في جلب المعاملات: $e\n');
  }
}

Future<void> testPostTransaction() async {
  print('💾 اختبار 3: إضافة معاملة (POST /transactions)');
  print('URL: https://graduation-project-21p3.onrender.com/transactions');
  
  final testData = {
    'amount': 50.0,
    'category': 'food',
    'title': 'اختبار اتصال ${DateTime.now().millisecondsSinceEpoch}',
    'description': 'معاملة اختبار من Flutter Debug',
    'quantity': 1,
    'date': DateTime.now().toIso8601String(),
    'isVoiceInput': false,
    'userId': 'flutter_debug_test',
  };
  
  print('Data to send: ${jsonEncode(testData)}');
  
  try {
    final response = await http.post(
      Uri.parse('https://graduation-project-21p3.onrender.com/transactions'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(testData),
    ).timeout(const Duration(seconds: 30));

    print('Status Code: ${response.statusCode}');
    print('Headers: ${response.headers}');
    print('Body: ${response.body}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ إضافة المعاملة نجحت');
      print('🎯 المعاملة دي المفروض تظهر عند الباك اند team دلوقتي!\n');
    } else {
      print('❌ إضافة المعاملة فشلت');
      print('🔍 تحقق من الـ endpoint أو البيانات المطلوبة\n');
    }
  } catch (e) {
    print('❌ خطأ في إضافة المعاملة: $e\n');
  }
}

Future<void> testOtherEndpoints() async {
  print('🔍 اختبار 4: endpoints أخرى');
  
  final endpoints = [
    '/health',
    '/status',
    '/',
    '/api/transactions',
    '/api/health',
  ];
  
  for (String endpoint in endpoints) {
    final url = 'https://graduation-project-21p3.onrender.com$endpoint';
    print('Testing: $url');
    
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('  Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('  Body: ${response.body.length > 100 ? response.body.substring(0, 100) + '...' : response.body}');
      }
    } catch (e) {
      print('  Error: $e');
    }
    print('');
  }
}