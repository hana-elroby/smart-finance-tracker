import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// اختبار الاستخدام الحقيقي - تجربة مع صحابك
/// يختبر إضافة بيانات حقيقية ومشاهدة النتائج
void main() {
  runApp(const TestRealUsageApp());
}

class TestRealUsageApp extends StatelessWidget {
  const TestRealUsageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Real Usage',
      home: const TestRealUsagePage(),
    );
  }
}

class TestRealUsagePage extends StatefulWidget {
  const TestRealUsagePage({super.key});

  @override
  State<TestRealUsagePage> createState() => _TestRealUsagePageState();
}

class _TestRealUsagePageState extends State<TestRealUsagePage> {
  final TextEditingController _textController = TextEditingController();
  String _status = 'جاهز للاختبار';
  String _lastResult = '';
  List<Map<String, dynamic>> _allResults = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختبار حقيقي مع صحابك'),
        backgroundColor: const Color(0xFF0D5DB8),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0D5DB8).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF0D5DB8).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🧪 اختبار مع صحابك:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D5DB8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1. اكتب جملة مصروف (عربي أو إنجليزي)\n'
                    '2. اضغط "تحليل وإضافة"\n'
                    '3. شوف النتيجة تظهر تحت\n'
                    '4. كرر مع صحابك وشوفوا البيانات تتجمع',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF374151),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Input Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'اكتب مصروف:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _textController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'مثال: اشتريت 3 خبز بـ15 جنيه\nI bought 2 coffee for 20 EGP',
                      hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF0D5DB8)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _analyzeAndAdd,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D5DB8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'تحليل وإضافة للداتا بيز',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _status.contains('✅') 
                    ? Colors.green.withOpacity(0.1)
                    : _status.contains('❌')
                        ? Colors.red.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _status.contains('✅') 
                      ? Colors.green.withOpacity(0.3)
                      : _status.contains('❌')
                          ? Colors.red.withOpacity(0.3)
                          : Colors.blue.withOpacity(0.3),
                ),
              ),
              child: Text(
                _status,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _status.contains('✅') 
                      ? Colors.green[700]
                      : _status.contains('❌')
                          ? Colors.red[700]
                          : Colors.blue[700],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Results
            const Text(
              'النتائج المضافة:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: _allResults.isEmpty
                    ? const Center(
                        child: Text(
                          'لا توجد نتائج بعد\nجرب إضافة مصروف أعلاه',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _allResults.length,
                        itemBuilder: (context, index) {
                          final result = _allResults[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${index + 1}. ${result['item']} (${result['quantity']}x)',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'المبلغ: ${result['amount']} جنيه | الفئة: ${result['category']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  'الوقت: ${DateTime.now().toString().substring(11, 19)}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),

            // Clear Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _allResults.isEmpty ? null : _clearResults,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'مسح النتائج (${_allResults.length})',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _analyzeAndAdd() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _status = '❌ يرجى إدخال النص أولاً';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'جاري التحليل...';
    });

    try {
      // استخدام سيرفر الفويس للتحليل
      final response = await http.post(
        Uri.parse('https://gradution-project-u39v.onrender.com/analyze'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'text': text}),
      ).timeout(const Duration(seconds: 30));

      print('📥 Response: ${response.statusCode}');
      print('📄 Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['success'] == true) {
          final transactions = _extractTransactions(jsonResponse);
          
          if (transactions.isNotEmpty) {
            setState(() {
              _allResults.addAll(transactions);
              _status = '✅ تم إضافة ${transactions.length} معاملة بنجاح!';
              _textController.clear();
            });
          } else {
            setState(() {
              _status = '⚠️ تم التحليل لكن لم يتم العثور على معاملات مالية';
            });
          }
        } else {
          setState(() {
            _status = '❌ فشل في التحليل: ${jsonResponse['message'] ?? 'Unknown error'}';
          });
        }
      } else {
        setState(() {
          _status = '❌ خطأ من السيرفر: ${response.statusCode}';
        });
      }
    } catch (e) {
      print('❌ Error: $e');
      setState(() {
        _status = '❌ خطأ في الاتصال: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _extractTransactions(Map<String, dynamic> apiResponse) {
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

      return result;
    } catch (e) {
      print('❌ خطأ في استخراج المعاملات: $e');
      return [];
    }
  }

  void _clearResults() {
    setState(() {
      _allResults.clear();
      _status = 'تم مسح النتائج';
    });
  }
}