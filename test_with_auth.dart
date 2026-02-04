import 'dart:convert';
import 'package:http/http.dart' as http;

/// اختبار مع تسجيل دخول حقيقي
/// يسجل دخول ويجيب token ويستخدمه في إضافة معاملة
void main() async {
  print('🔐 بدء اختبار مع Authentication...\n');
  
  final baseUrl = 'https://graduation-project-21p3.onrender.com';
  
  // 1. تسجيل دخول والحصول على token
  final token = await signIn(baseUrl);
  
  if (token != null) {
    // 2. استخدام الـ token في إضافة معاملة
    await addTransactionWithToken(baseUrl, token);
    
    // 3. جلب المعاملات بالـ token
    await getMyTransactions(baseUrl, token);
  } else {
    print('❌ فشل في تسجيل الدخول - جرب بدون authentication');
    await testWithoutAuth(baseUrl);
  }
}

Future<String?> signIn(String baseUrl) async {
  print('🔑 تسجيل دخول...');
  
  final loginData = {
    'email': 'test@example.com',
    'password': 'password123',
  };
  
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signin'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(loginData),
    ).timeout(const Duration(seconds: 15));
    
    print('  Status: ${response.statusCode}');
    print('  Body: ${response.body}');
    
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final token = jsonData['token'];
      
      if (token != null) {
        print('  ✅ تم تسجيل الدخول بنجاح!');
        print('  🎫 Token: ${token.toString().substring(0, 20)}...\n');
        return token;
      }
    } else if (response.statusCode == 401) {
      print('  ❌ بيانات تسجيل الدخول غلط');
    } else if (response.statusCode == 404) {
      print('  ❌ المستخدم غير موجود');
    }
  } catch (e) {
    print('  ❌ خطأ في تسجيل الدخول: $e');
  }
  
  print('');
  return null;
}

Future<void> addTransactionWithToken(String baseUrl, String token) async {
  print('💾 إضافة معاملة مع الـ token...');
  
  final transactionData = {
    'text': 'معاملة مع authentication - قهوة بـ 40 جنيه',
    'items': [],
    'price': 40.0,
  };
  
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/transactions/createWithText'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'token': token, // استخدام الـ token الحقيقي
      },
      body: jsonEncode(transactionData),
    ).timeout(const Duration(seconds: 15));
    
    print('  Status: ${response.statusCode}');
    print('  Body: ${response.body}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('  ✅ تم إضافة المعاملة بنجاح مع الـ token!');
      print('  🎯 البيانات وصلت للباك اند team دلوقتي!');
    } else {
      print('  ❌ فشل في إضافة المعاملة');
    }
  } catch (e) {
    print('  ❌ خطأ: $e');
  }
  
  print('');
}

Future<void> getMyTransactions(String baseUrl, String token) async {
  print('📥 جلب معاملاتي مع الـ token...');
  
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/transactions/my'),
      headers: {
        'Accept': 'application/json',
        'token': token,
      },
    ).timeout(const Duration(seconds: 15));
    
    print('  Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      print('  ✅ تم جلب معاملاتي');
      
      if (jsonData['data'] is List) {
        final transactions = jsonData['data'] as List;
        print('  📊 عدد معاملاتي: ${transactions.length}');
        
        if (transactions.isNotEmpty) {
          print('  📄 آخر معاملة: ${transactions.first['text'] ?? 'Unknown'}');
        }
      }
    } else {
      print('  ❌ فشل في جلب المعاملات: ${response.statusCode}');
    }
  } catch (e) {
    print('  ❌ خطأ: $e');
  }
  
  print('');
}

Future<void> testWithoutAuth(String baseUrl) async {
  print('🔓 اختبار بدون authentication (للمقارنة)...');
  
  // اطلب من الباك اند team يخلوا endpoint يشتغل بدون token للاختبار
  print('💡 اطلبي من الباك اند team:');
  print('   1. يخلوا /transactions/createWithText يشتغل بدون token مؤقتاً');
  print('   2. أو يدوكي user credentials للاختبار');
  print('   3. أو يعملوا test endpoint بدون authentication');
}