import 'dart:convert';
import 'package:http/http.dart' as http;

/// اختبار بسيط جداً للداتا بيز المشتركة
/// يختبر إضافة وجلب البيانات من سيرفر الباك اند مباشرة
void main() async {
  print('🚀 بدء اختبار سيرفر الباك اند...');
  
  // اختبار الاتصال
  await testConnection();
  
  // اختبار إضافة معاملة
  await testAddTransaction();
  
  // اختبار جلب المعاملات
  await testGetTransactions();
  
  print('✅ انتهى الاختبار');
}

Future<void> testConnection() async {
  print('\n📡 اختبار الاتصال بسيرفر الباك اند...');
  
  try {
    final response = await http.get(
      Uri.parse('https://graduation-project-21p3.onrender.com/api'),
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      print('✅ السيرفر متاح: ${response.body}');
    } else {
      print('❌ السيرفر غير متاح: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ خطأ في الاتصال: $e');
  }
}

Future<void> testAddTransaction() async {
  print('\n💾 اختبار إضافة معاملة جديدة...');
  
  try {
    final transactionData = {
      'amount': 30.0,
      'category': 'food',
      'title': 'قهوة اختبار ${DateTime.now().millisecondsSinceEpoch}',
      'description': 'معاملة تجريبية من Flutter',
      'quantity': 1,
      'date': DateTime.now().toIso8601String(),
      'isVoiceInput': false,
      'userId': 'flutter_test_user',
    };

    final response = await http.post(
      Uri.parse('https://graduation-project-21p3.onrender.com/transactions'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(transactionData),
    ).timeout(const Duration(seconds: 30));

    print('📡 Response Status: ${response.statusCode}');
    print('📄 Response Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ تم إضافة المعاملة بنجاح!');
      print('🎯 الباك اند team يقدروا يشوفوا المعاملة دي في الداتا بيز دلوقتي');
    } else {
      print('❌ فشل في إضافة المعاملة: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ خطأ في إضافة المعاملة: $e');
  }
}

Future<void> testGetTransactions() async {
  print('\n📥 اختبار جلب المعاملات...');
  
  try {
    final response = await http.get(
      Uri.parse('https://graduation-project-21p3.onrender.com/transactions'),
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 30));

    print('📡 Response Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      
      List<dynamic> transactions = [];
      
      if (jsonResponse is List) {
        transactions = jsonResponse;
      } else if (jsonResponse is Map) {
        if (jsonResponse['data'] is List) {
          transactions = jsonResponse['data'];
        } else if (jsonResponse['transactions'] is List) {
          transactions = jsonResponse['transactions'];
        }
      }

      print('✅ تم جلب ${transactions.length} معاملة من السيرفر');
      
      if (transactions.isNotEmpty) {
        print('📊 آخر 3 معاملات:');
        final lastThree = transactions.take(3).toList();
        for (int i = 0; i < lastThree.length; i++) {
          final transaction = lastThree[i];
          print('   ${i + 1}. ${transaction['title'] ?? 'Unknown'} - ${transaction['amount']} جنيه');
        }
      } else {
        print('📭 لا توجد معاملات في السيرفر');
      }
    } else {
      print('❌ فشل في جلب المعاملات: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ خطأ في جلب المعاملات: $e');
  }
}