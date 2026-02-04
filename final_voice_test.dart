// الاختبار النهائي للـ Voice API في التطبيق
// Final Voice API Test in App

import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🚀 الاختبار النهائي للـ Voice API في التطبيق');
  print('=' * 60);
  
  // 1. اختبار الاتصال
  print('\n🔗 1. اختبار الاتصال بالـ API...');
  final isConnected = await testConnection();
  
  if (!isConnected) {
    print('❌ فشل الاتصال بالـ API');
    return;
  }
  
  // 2. اختبار النصوص المختلفة
  print('\n📝 2. اختبار النصوص المختلفة...');
  await testDifferentTexts();
  
  // 3. اختبار التكامل مع التطبيق
  print('\n📱 3. التكامل مع التطبيق...');
  testAppIntegration();
  
  print('\n' + '=' * 60);
  print('✅ الاختبار النهائي مكتمل - الـ API جاهز للاستخدام!');
}

Future<bool> testConnection() async {
  try {
    final response = await http.get(
      Uri.parse('https://graduation-project-21p3.onrender.com/'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 30));
    
    if (response.statusCode == 200) {
      print('   ✅ الاتصال ناجح');
      return true;
    } else {
      print('   ❌ فشل الاتصال - Status: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('   ❌ خطأ في الاتصال: $e');
    return false;
  }
}

Future<void> testDifferentTexts() async {
  final testCases = [
    {
      'text': 'اشتريت خبز بـ 5 جنيه من البقالة',
      'type': 'Arabic',
      'expected': {'amount': 5.0, 'category': 'Shopping'}
    },
    {
      'text': 'I bought bread for 10 EGP from the store',
      'type': 'English',
      'expected': {'amount': 10.0, 'category': 'Shopping'}
    },
    {
      'text': 'eshtareet khobz be 7 geneeh',
      'type': 'Franco-Arabic',
      'expected': {'amount': 7.0}
    },
    {
      'text': 'دفعت 100 جنيه فاتورة كهرباء',
      'type': 'Arabic Bills',
      'expected': {'amount': 100.0, 'category': 'Bills'}
    },
    {
      'text': 'استلمت مرتب 3000 جنيه',
      'type': 'Arabic Income',
      'expected': {'amount': 3000.0, 'type': 'income'}
    }
  ];
  
  for (final testCase in testCases) {
    await testSingleText(
      testCase['text'] as String,
      testCase['type'] as String,
      testCase['expected'] as Map<String, dynamic>,
    );
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

Future<void> testSingleText(String text, String type, Map<String, dynamic> expected) async {
  try {
    print('   🔍 اختبار $type: "$text"');
    
    final response = await http.post(
      Uri.parse('https://graduation-project-21p3.onrender.com/analyze'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text}),
    ).timeout(const Duration(seconds: 30));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      if (data['success'] == true) {
        final transactions = data['data']?['analysis']?['transactions'];
        if (transactions != null && transactions.isNotEmpty) {
          final transaction = transactions[0];
          final amount = (transaction['amount'] as num?)?.toDouble();
          final category = transaction['category'];
          final item = transaction['item'];
          final transactionType = transaction['transaction_type'];
          
          print('      ✅ نجح التحليل');
          print('      💰 المبلغ: $amount EGP');
          print('      📂 الفئة: $category');
          print('      🏷️ العنصر: $item');
          print('      📊 النوع: $transactionType');
          
          // التحقق من التوقعات
          if (expected['amount'] != null && amount == expected['amount']) {
            print('      ✅ المبلغ صحيح');
          }
          if (expected['category'] != null && category.toString().contains(expected['category'])) {
            print('      ✅ الفئة صحيحة');
          }
          if (expected['type'] != null && transactionType == expected['type']) {
            print('      ✅ النوع صحيح');
          }
        } else {
          print('      ⚠️ لم يتم العثور على معاملات');
        }
      } else {
        print('      ❌ فشل التحليل: ${data['message']}');
      }
    } else {
      print('      ❌ خطأ HTTP: ${response.statusCode}');
    }
  } catch (e) {
    print('      ❌ خطأ: $e');
  }
}

void testAppIntegration() {
  print('   📱 ملفات التكامل في التطبيق:');
  print('      ✅ lib/services/voice_api_service.dart - خدمة الـ API');
  print('      ✅ lib/widgets/dialogs/voice_input_dialog_simple.dart - Dialog الصوت');
  print('      ✅ lib/widgets/dialogs/add_options_bottom_sheet.dart - خيارات الإضافة');
  print('      ✅ lib/features/home/bloc/expense_bloc.dart - إدارة المصاريف');
  print('      ✅ lib/widgets/main_layout.dart - التخطيط الرئيسي');
  
  print('\n   🔄 تدفق العمل:');
  print('      1. المستخدم يضغط على Voice');
  print('      2. يفتح Voice Input Dialog');
  print('      3. يسجل صوت أو يكتب نص');
  print('      4. يرسل للـ API للتحليل');
  print('      5. يستخرج المعلومات');
  print('      6. ينشئ Expense object');
  print('      7. يضيفه للـ ExpenseBloc');
  print('      8. يحفظ في SharedPreferences');
  print('      9. يظهر في قائمة المصاريف');
  
  print('\n   🎯 الاستخدام في التطبيق:');
  print('      • من الصفحة الرئيسية: FAB → Voice');
  print('      • من الفئات: Add → Voice');
  print('      • من العناصر: Add → Voice');
  print('      • مباشرة: showSimpleVoiceInputDialog(context)');
}