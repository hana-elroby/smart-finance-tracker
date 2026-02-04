import 'dart:convert';
import 'package:http/http.dart' as http;

/// Voice API Direct Service - يستخدم API المستخدم مباشرة
/// يرسل النص مباشرة للسيرفر بدون أي معالجة لغوية
/// https://gradution-project-u39v.onrender.com
class VoiceApiDirectService {
  static const String _baseUrl = 'https://gradution-project-u39v.onrender.com';
  
  /// تحليل النص مباشرة عبر API المستخدم
  /// يدعم العربي والإنجليزي والفرانكو-عربي
  static Future<Map<String, dynamic>?> analyzeText(String text) async {
    if (text.trim().isEmpty) {
      print('❌ النص فارغ');
      return null;
    }

    try {
      print('📡 إرسال النص للتحليل: "$text"');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/analyze'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'text': text, // إرسال النص كما هو بدون أي تعديل
        }),
      ).timeout(const Duration(seconds: 30));

      print('📥 استجابة السيرفر: ${response.statusCode}');
      print('📄 محتوى الاستجابة: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['success'] == true) {
          print('✅ تم تحليل النص بنجاح');
          return jsonResponse;
        } else {
          print('❌ فشل في تحليل النص: ${jsonResponse['message'] ?? 'Unknown error'}');
          return null;
        }
      } else {
        print('❌ خطأ من السيرفر: ${response.statusCode}');
        print('❌ رسالة الخطأ: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ خطأ في الاتصال بالسيرفر: $e');
      return null;
    }
  }

  /// استخراج المعاملات من استجابة API
  static List<Map<String, dynamic>> extractTransactions(Map<String, dynamic> apiResponse) {
    try {
      final data = apiResponse['data'];
      if (data == null) return [];

      final analysis = data['analysis'];
      if (analysis == null) return [];

      final transactions = analysis['transactions'];
      if (transactions == null || transactions is! List) return [];

      List<Map<String, dynamic>> result = [];
      
      for (var transaction in transactions) {
        if (transaction is Map<String, dynamic>) {
          // استخراج البيانات كما هي من API بدون تعديل
          final amount = (transaction['amount'] as num?)?.toDouble() ?? 0.0;
          final category = transaction['category'] as String? ?? 'other';
          final item = transaction['item'] as String? ?? 'Unknown';
          final quantity = (transaction['quantity'] as num?)?.toInt() ?? 1;

          if (amount > 0) {
            result.add({
              'amount': amount,
              'category': category,
              'item': item,
              'quantity': quantity,
            });
          }
        }
      }

      print('✅ تم استخراج ${result.length} معاملة');
      return result;
    } catch (e) {
      print('❌ خطأ في استخراج المعاملات: $e');
      return [];
    }
  }

  /// اختبار الاتصال بالسيرفر
  static Future<bool> testConnection() async {
    try {
      print('🔍 اختبار الاتصال بالسيرفر...');
      
      // Test the main page first (should work)
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {'Accept': 'text/html,application/json'},
      ).timeout(const Duration(seconds: 10));

      print('📡 حالة الاتصال: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ سيرفر الفويس متاح');
        return true;
      } else {
        print('❌ سيرفر الفويس غير متاح: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ فشل في الاتصال بالسيرفر: $e');
      return false;
    }
  }
}