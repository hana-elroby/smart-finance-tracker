// اختبار الاتصال بالـ API
// Test API Connection for Voice & Text Analysis

import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🚀 بدء اختبار الـ API...');
  
  await testApiConnection();
  await testTextAnalysis();
  
  print('✅ انتهى الاختبار');
}

// اختبار الاتصال الأساسي
Future<void> testApiConnection() async {
  print('\n🔍 اختبار الاتصال الأساسي...');
  
  try {
    final response = await http.get(
      Uri.parse('https://graduation-project-21p3.onrender.com/'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 60)); // زيادة الوقت للـ cold start
    
    print('📊 حالة الاستجابة: ${response.statusCode}');
    print('📝 محتوى الاستجابة (أول 200 حرف): ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
    
    if (response.statusCode == 200) {
      print('✅ الاتصال ناجح! الـ API يعمل بشكل صحيح');
    } else {
      print('❌ فشل الاتصال');
    }
  } catch (e) {
    print('❌ خطأ في الاتصال: $e');
  }
}

// اختبار تحليل النص
Future<void> testTextAnalysis() async {
  print('\n🔍 اختبار تحليل النص...');
  
  try {
    final testText = 'اشتريت خبز بـ 5 جنيه من البقالة';
    
    final response = await http.post(
      Uri.parse('https://graduation-project-21p3.onrender.com/analyze'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': testText}),
    ).timeout(const Duration(seconds: 60)); // زيادة الوقت
    
    print('📊 حالة الاستجابة: ${response.statusCode}');
    print('📝 محتوى الاستجابة: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ تحليل النص ناجح!');
      print('📊 البيانات المستخرجة:');
      print('   - النص الأصلي: ${data['data']?['original_text']}');
      
      final transactions = data['data']?['analysis']?['transactions'];
      if (transactions != null && transactions.isNotEmpty) {
        final transaction = transactions[0];
        print('   - المبلغ: ${transaction['amount']}');
        print('   - الفئة: ${transaction['category']}');
        print('   - العنصر: ${transaction['item']}');
        print('   - النوع: ${transaction['type']}');
      }
      
      // التحقق من أن البيانات ليست mock data
      if (data['data']?['original_text'] == testText) {
        print('✅ البيانات حقيقية وليست mock data');
      } else {
        print('⚠️ قد تكون البيانات mock data');
      }
    } else {
      print('❌ فشل تحليل النص');
    }
  } catch (e) {
    print('❌ خطأ في تحليل النص: $e');
  }
}