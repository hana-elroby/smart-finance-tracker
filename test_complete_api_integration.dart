// اختبار شامل للـ API Integration
// Complete API Integration Test

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  print('🚀 بدء الاختبار الشامل للـ API...');
  print('=' * 50);
  
  await testApiHealth();
  await testTextAnalysisArabic();
  await testTextAnalysisEnglish();
  await testTextAnalysisFrancoArabic();
  await testErrorHandling();
  
  print('=' * 50);
  print('✅ انتهى الاختبار الشامل');
}

// 1. اختبار صحة الـ API
Future<void> testApiHealth() async {
  print('\n🏥 اختبار صحة الـ API...');
  
  try {
    final response = await http.get(
      Uri.parse('https://gradution-project-u39v.onrender.com/'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 60));
    
    if (response.statusCode == 200) {
      print('✅ الـ API يعمل بشكل صحيح');
      print('📊 Status: ${response.statusCode}');
    } else {
      print('❌ مشكلة في الـ API - Status: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ خطأ في الاتصال: $e');
  }
}

// 2. اختبار تحليل النص العربي
Future<void> testTextAnalysisArabic() async {
  print('\n🇪🇬 اختبار تحليل النص العربي...');
  
  final testCases = [
    'اشتريت خبز بـ 5 جنيه من البقالة',
    'دفعت 50 جنيه في كارفور على خضار',
    'استلمت مرتب 5000 جنيه',
    'صرفت 25 جنيه على مواصلات',
    'اشتريت دواء بـ 80 جنيه من الصيدلية',
  ];
  
  for (final testText in testCases) {
    await _testSingleText(testText, 'Arabic');
  }
}

// 3. اختبار تحليل النص الإنجليزي
Future<void> testTextAnalysisEnglish() async {
  print('\n🇺🇸 اختبار تحليل النص الإنجليزي...');
  
  final testCases = [
    'I bought bread for 5 EGP from the grocery store',
    'Paid 50 EGP at Carrefour for vegetables',
    'Received salary of 5000 EGP',
    'Spent 25 EGP on transportation',
    'Bought medicine for 80 EGP from pharmacy',
  ];
  
  for (final testText in testCases) {
    await _testSingleText(testText, 'English');
  }
}

// 4. اختبار تحليل النص الفرانكو عربي
Future<void> testTextAnalysisFrancoArabic() async {
  print('\n🔄 اختبار تحليل النص الفرانكو عربي...');
  
  final testCases = [
    'eshtareet khobz be 5 geneeh men el ba2ala',
    'dafa3t 50 geneeh fi carrefour 3ala khodar',
    'estalamet murtab 5000 geneeh',
    'sarraft 25 geneeh 3ala mowasalat',
  ];
  
  for (final testText in testCases) {
    await _testSingleText(testText, 'Franco-Arabic');
  }
}

// 5. اختبار معالجة الأخطاء
Future<void> testErrorHandling() async {
  print('\n⚠️ اختبار معالجة الأخطاء...');
  
  // اختبار نص فارغ
  await _testSingleText('', 'Empty Text');
  
  // اختبار نص غير مفهوم
  await _testSingleText('xyz123!@#', 'Invalid Text');
  
  // اختبار نص طويل جداً
  final longText = 'test ' * 1000;
  await _testSingleText(longText, 'Very Long Text');
}

// دالة مساعدة لاختبار نص واحد
Future<void> _testSingleText(String text, String type) async {
  if (text.isEmpty) {
    print('⚠️ تخطي النص الفارغ');
    return;
  }
  
  try {
    print('🔍 اختبار ($type): "${text.length > 50 ? text.substring(0, 50) + '...' : text}"');
    
    final response = await http.post(
      Uri.parse('https://gradution-project-u39v.onrender.com/analyze'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text}),
    ).timeout(const Duration(seconds: 60));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      if (data['success'] == true) {
        final originalText = data['data']?['original_text'];
        final transactions = data['data']?['analysis']?['transactions'];
        
        print('   ✅ تحليل ناجح');
        print('   📝 النص الأصلي: $originalText');
        
        if (transactions != null && transactions.isNotEmpty) {
          final transaction = transactions[0];
          print('   💰 المبلغ: ${transaction['amount']} ${transaction['currency']}');
          print('   📂 الفئة: ${transaction['category']}');
          print('   🏷️ العنصر: ${transaction['item']}');
          print('   📊 النوع: ${transaction['transaction_type']}');
          print('   🎯 الثقة: ${transaction['confidence_score']}');
        } else {
          print('   ⚠️ لم يتم العثور على معاملات');
        }
        
        // التحقق من أن البيانات ليست mock
        if (originalText == text) {
          print('   ✅ البيانات حقيقية (ليست mock)');
        } else {
          print('   ⚠️ قد تكون البيانات معدلة أو محولة');
        }
      } else {
        print('   ❌ فشل التحليل: ${data['message']}');
      }
    } else {
      print('   ❌ خطأ HTTP: ${response.statusCode}');
      print('   📝 الاستجابة: ${response.body}');
    }
  } catch (e) {
    print('   ❌ خطأ: $e');
  }
  
  // فاصل زمني قصير بين الطلبات
  await Future.delayed(const Duration(milliseconds: 500));
}