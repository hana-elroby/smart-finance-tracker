import 'dart:convert';
import 'package:http/http.dart' as http;

/// اختبار يوقظ السيرفر ويختبر كل الـ endpoints
/// Render servers sleep after 15 minutes of inactivity
void main() async {
  print('🌅 بدء إيقاظ واختبار سيرفر الباك اند...\n');
  
  // 1. إيقاظ السيرفر
  await wakeUpServer();
  
  // 2. اختبار الـ endpoints
  await testAllEndpoints();
  
  // 3. إضافة معاملة حقيقية
  await addRealTransaction();
  
  // 4. التحقق من البيانات
  await verifyData();
  
  print('\n🎉 انتهى اختبار إيقاظ السيرفر');
}

Future<void> wakeUpServer() async {
  print('🌅 إيقاظ السيرفر...');
  print('⏰ قد يستغرق هذا 30-60 ثانية إذا كان السيرفر نائماً');
  
  try {
    // محاولة إيقاظ السيرفر بعدة طلبات
    final urls = [
      'https://graduation-project-21p3.onrender.com',
      'https://graduation-project-21p3.onrender.com/api',
      'https://graduation-project-21p3.onrender.com/health',
    ];
    
    for (String url in urls) {
      print('📡 محاولة الوصول لـ: $url');
      
      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 60)); // وقت أطول للسيرفر النائم
        
        print('   Status: ${response.statusCode}');
        if (response.statusCode == 200) {
          print('   Body: ${response.body}');
          print('✅ السيرفر مستيقظ!');
          break;
        }
      } catch (e) {
        print('   Error: $e');
        print('⏳ السيرفر لا يزال يستيقظ...');
      }
      
      // انتظار بين المحاولات
      await Future.delayed(const Duration(seconds: 5));
    }
    
    print('✅ انتهى إيقاظ السيرفر\n');
  } catch (e) {
    print('❌ خطأ في إيقاظ السيرفر: $e\n');
  }
}

Future<void> testAllEndpoints() async {
  print('🔍 اختبار جميع الـ endpoints...');
  
  final endpoints = [
    {'url': '/api', 'method': 'GET', 'description': 'Health check'},
    {'url': '/transactions', 'method': 'GET', 'description': 'Get transactions'},
    {'url': '/health', 'method': 'GET', 'description': 'Health endpoint'},
    {'url': '/', 'method': 'GET', 'description': 'Root endpoint'},
  ];
  
  for (var endpoint in endpoints) {
    final url = 'https://graduation-project-21p3.onrender.com${endpoint['url']}';
    print('Testing ${endpoint['method']} $url - ${endpoint['description']}');
    
    try {
      http.Response response;
      
      if (endpoint['method'] == 'GET') {
        response = await http.get(
          Uri.parse(url),
          headers: {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 30));
      } else {
        response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 30));
      }
      
      print('  ✅ Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final body = response.body.length > 200 ? 
            '${response.body.substring(0, 200)}...' : response.body;
        print('  📄 Body: $body');
      }
    } catch (e) {
      print('  ❌ Error: $e');
    }
    print('');
  }
}

Future<void> addRealTransaction() async {
  print('💾 إضافة معاملة حقيقية...');
  
  final transactionData = {
    'amount': 75.0,
    'category': 'food',
    'title': 'اختبار إيقاظ السيرفر ${DateTime.now().hour}:${DateTime.now().minute}',
    'description': 'معاملة اختبار بعد إيقاظ السيرفر',
    'quantity': 1,
    'date': DateTime.now().toIso8601String(),
    'isVoiceInput': false,
    'userId': 'wake_up_test_user',
  };
  
  print('📤 البيانات المرسلة:');
  print(jsonEncode(transactionData));
  
  try {
    final response = await http.post(
      Uri.parse('https://graduation-project-21p3.onrender.com/transactions'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(transactionData),
    ).timeout(const Duration(seconds: 45));

    print('📡 Response Status: ${response.statusCode}');
    print('📄 Response Body: ${response.body}');
    print('📋 Response Headers: ${response.headers}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ تم إضافة المعاملة بنجاح!');
      print('🎯 المعاملة دي المفروض تظهر عند الباك اند team دلوقتي!');
    } else if (response.statusCode == 404) {
      print('❌ الـ endpoint مش موجود - تحقق من الـ URL');
    } else if (response.statusCode == 400) {
      print('❌ البيانات مش صحيحة - تحقق من الـ request body');
    } else if (response.statusCode == 500) {
      print('❌ خطأ في السيرفر - تحقق من الباك اند code');
    } else {
      print('❌ خطأ غير متوقع: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ خطأ في إضافة المعاملة: $e');
  }
  
  print('');
}

Future<void> verifyData() async {
  print('🔍 التحقق من البيانات في السيرفر...');
  
  try {
    final response = await http.get(
      Uri.parse('https://graduation-project-21p3.onrender.com/transactions'),
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 30));

    print('📡 Response Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      print('📄 Response Body: ${response.body}');
      
      try {
        final jsonData = jsonDecode(response.body);
        
        if (jsonData is List) {
          print('✅ تم العثور على ${jsonData.length} معاملة');
          
          if (jsonData.isNotEmpty) {
            print('📊 آخر 3 معاملات:');
            final lastThree = jsonData.take(3).toList();
            for (int i = 0; i < lastThree.length; i++) {
              final transaction = lastThree[i];
              print('   ${i + 1}. ${transaction['title'] ?? 'Unknown'} - ${transaction['amount']} جنيه');
              print('      التاريخ: ${transaction['date'] ?? 'Unknown'}');
              print('      المستخدم: ${transaction['userId'] ?? 'Unknown'}');
            }
            
            print('\n🎉 البيانات موجودة في السيرفر!');
            print('📞 اطلب من الباك اند team يتحققوا من الداتا بيز دلوقتي');
          }
        } else if (jsonData is Map) {
          print('📋 Response structure: ${jsonData.keys}');
          if (jsonData.containsKey('data') || jsonData.containsKey('transactions')) {
            final transactions = jsonData['data'] ?? jsonData['transactions'];
            if (transactions is List) {
              print('✅ تم العثور على ${transactions.length} معاملة في ${jsonData.keys.first}');
            }
          }
        }
      } catch (e) {
        print('❌ خطأ في تحليل JSON: $e');
        print('📄 Raw response: ${response.body}');
      }
    } else {
      print('❌ فشل في جلب البيانات: ${response.statusCode}');
      print('📄 Response: ${response.body}');
    }
  } catch (e) {
    print('❌ خطأ في التحقق من البيانات: $e');
  }
}