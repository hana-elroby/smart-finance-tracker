import 'dart:convert';
import 'package:http/http.dart' as http;

/// اختبار نهائي لمعرفة إيه اللي بيحصل بالضبط
/// يختبر كل الاحتمالات ويطبع كل التفاصيل
void main() async {
  print('🔍 بدء الاختبار النهائي لمعرفة المشكلة...\n');
  
  final baseUrl = 'https://graduation-project-21p3.onrender.com';
  
  // 1. اختبار Health Check
  await testHealthCheck(baseUrl);
  
  // 2. اختبار الـ endpoint الغلط (اللي كان مستخدم)
  await testWrongEndpoint(baseUrl);
  
  // 3. اختبار الـ endpoint الصح (الجديد)
  await testCorrectEndpoint(baseUrl);
  
  // 4. اختبار مع Authentication
  await testWithAuth(baseUrl);
  
  // 5. اختبار جلب البيانات
  await testGetData(baseUrl);
  
  print('\n📋 الخلاصة النهائية:');
  print('🎯 المشكلة الأساسية: كنا بنبعت لـ endpoint غلط');
  print('✅ الحل: استخدام /transactions/createWithText');
  print('⚠️ مشكلة محتملة: Authentication مطلوب');
}

Future<void> testHealthCheck(String baseUrl) async {
  print('🏥 اختبار Health Check...');
  
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/api'),
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 10));
    
    print('  Status: ${response.statusCode}');
    print('  Body: ${response.body}');
    
    if (response.statusCode == 200) {
      print('  ✅ السيرفر شغال\n');
    } else {
      print('  ❌ السيرفر مش شغال\n');
    }
  } catch (e) {
    print('  ❌ خطأ: $e\n');
  }
}

Future<void> testWrongEndpoint(String baseUrl) async {
  print('❌ اختبار الـ endpoint الغلط (اللي كان مستخدم)...');
  print('URL: $baseUrl/transactions');
  
  final wrongData = {
    'amount': 25.0,
    'category': 'food',
    'title': 'قهوة',
    'description': 'قهوة',
    'quantity': 1,
    'date': DateTime.now().toIso8601String(),
    'isVoiceInput': false,
    'userId': 'shared_user',
  };
  
  print('Data: ${jsonEncode(wrongData)}');
  
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/transactions'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(wrongData),
    ).timeout(const Duration(seconds: 15));
    
    print('  Status: ${response.statusCode}');
    print('  Body: ${response.body}');
    
    if (response.statusCode == 404) {
      print('  ❌ الـ endpoint مش موجود (404) - دا كان السبب!\n');
    } else if (response.statusCode == 401) {
      print('  🔐 الـ endpoint موجود لكن محتاج authentication\n');
    } else {
      print('  ❓ استجابة غير متوقعة\n');
    }
  } catch (e) {
    print('  ❌ خطأ: $e\n');
  }
}

Future<void> testCorrectEndpoint(String baseUrl) async {
  print('✅ اختبار الـ endpoint الصح (الجديد)...');
  print('URL: $baseUrl/transactions/createWithText');
  
  final correctData = {
    'text': 'اختبار نهائي - قهوة بـ 30 جنيه',
    'items': [],
    'price': 30.0,
  };
  
  print('Data: ${jsonEncode(correctData)}');
  
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/transactions/createWithText'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(correctData),
    ).timeout(const Duration(seconds: 15));
    
    print('  Status: ${response.statusCode}');
    print('  Body: ${response.body}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('  ✅ نجح! البيانات وصلت للباك اند');
    } else if (response.statusCode == 401) {
      print('  🔐 الـ endpoint صح لكن محتاج authentication');
    } else if (response.statusCode == 400) {
      print('  ⚠️ البيانات مش صحيحة');
    } else {
      print('  ❌ فشل لسبب آخر');
    }
    print('');
  } catch (e) {
    print('  ❌ خطأ: $e\n');
  }
}

Future<void> testWithAuth(String baseUrl) async {
  print('🔐 اختبار مع Authentication...');
  print('URL: $baseUrl/transactions/createWithText');
  
  final authData = {
    'text': 'اختبار مع authentication - قهوة بـ 35 جنيه',
    'items': [],
    'price': 35.0,
  };
  
  print('Data: ${jsonEncode(authData)}');
  
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/transactions/createWithText'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'token': 'dummy_token_for_testing', // Token تجريبي
      },
      body: jsonEncode(authData),
    ).timeout(const Duration(seconds: 15));
    
    print('  Status: ${response.statusCode}');
    print('  Body: ${response.body}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('  ✅ نجح مع الـ token!');
    } else if (response.statusCode == 401) {
      print('  🔐 الـ token مش صحيح أو مطلوب تسجيل دخول');
    } else {
      print('  ❓ استجابة أخرى');
    }
    print('');
  } catch (e) {
    print('  ❌ خطأ: $e\n');
  }
}

Future<void> testGetData(String baseUrl) async {
  print('📥 اختبار جلب البيانات...');
  print('URL: $baseUrl/transactions');
  
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/transactions'),
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 15));
    
    print('  Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      print('  ✅ تم جلب البيانات');
      
      if (jsonData is List) {
        print('  📊 عدد المعاملات: ${jsonData.length}');
        if (jsonData.isNotEmpty) {
          print('  📄 آخر معاملة: ${jsonData.first}');
        }
      } else if (jsonData is Map) {
        print('  📋 هيكل البيانات: ${jsonData.keys}');
      }
    } else if (response.statusCode == 401) {
      print('  🔐 محتاج authentication للجلب');
    } else {
      print('  ❌ فشل في الجلب: ${response.statusCode}');
      print('  Body: ${response.body}');
    }
    print('');
  } catch (e) {
    print('  ❌ خطأ: $e\n');
  }
}