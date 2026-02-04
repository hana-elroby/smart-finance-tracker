import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// اختبار سيرفر الباك اند والداتا بيز
/// يختبر حفظ وجلب البيانات من سيرفر الباك اند الحقيقي
void main() {
  runApp(const TestBackendDatabaseApp());
}

class TestBackendDatabaseApp extends StatelessWidget {
  const TestBackendDatabaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Backend Database',
      home: const TestBackendDatabasePage(),
    );
  }
}

class TestBackendDatabasePage extends StatefulWidget {
  const TestBackendDatabasePage({super.key});

  @override
  State<TestBackendDatabasePage> createState() => _TestBackendDatabasePageState();
}

class _TestBackendDatabasePageState extends State<TestBackendDatabasePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController(text: 'food');
  
  String _status = 'جاهز لاختبار سيرفر الباك اند';
  String _response = '';
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _testServerConnection() async {
    setState(() {
      _isLoading = true;
      _status = 'جاري اختبار الاتصال بسيرفر الباك اند...';
    });

    try {
      final response = await http.get(
        Uri.parse('https://graduation-project-21p3.onrender.com/api'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      setState(() {
        _status = response.statusCode == 200 
            ? '✅ سيرفر الباك اند متاح: ${response.body}'
            : '❌ سيرفر الباك اند غير متاح: ${response.statusCode}';
        _response = 'Status: ${response.statusCode}\nResponse: ${response.body}';
      });
    } catch (e) {
      setState(() {
        _status = '❌ فشل في الاتصال بسيرفر الباك اند: $e';
        _response = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addTransaction() async {
    final title = _titleController.text.trim();
    final amountText = _amountController.text.trim();
    final category = _categoryController.text.trim();
    
    if (title.isEmpty || amountText.isEmpty || category.isEmpty) {
      setState(() {
        _status = '❌ يرجى ملء جميع الحقول';
      });
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      setState(() {
        _status = '❌ يرجى إدخال مبلغ صحيح';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'جاري إضافة المعاملة لسيرفر الباك اند...';
    });

    try {
      final response = await http.post(
        Uri.parse('https://graduation-project-21p3.onrender.com/transactions'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'amount': amount,
          'category': category,
          'title': title,
          'description': title,
          'quantity': 1,
          'date': DateTime.now().toIso8601String(),
          'isVoiceInput': false,
          'userId': 'test_user_${DateTime.now().millisecondsSinceEpoch}',
        }),
      ).timeout(const Duration(seconds: 30));

      print('📡 Add Response Status: ${response.statusCode}');
      print('📄 Add Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _status = '✅ تم إضافة المعاملة بنجاح!';
          _response = 'Status: ${response.statusCode}\nResponse: ${response.body}';
          _titleController.clear();
          _amountController.clear();
        });
        
        // Reload transactions
        await _loadTransactions();
      } else {
        setState(() {
          _status = '❌ فشل في إضافة المعاملة: ${response.statusCode}';
          _response = 'Error Status: ${response.statusCode}\nError Body: ${response.body}';
        });
      }
    } catch (e) {
      print('❌ Add Transaction Error: $e');
      setState(() {
        _status = '❌ خطأ في إضافة المعاملة: $e';
        _response = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _status = 'جاري جلب المعاملات من سيرفر الباك اند...';
    });

    try {
      final response = await http.get(
        Uri.parse('https://graduation-project-21p3.onrender.com/transactions'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      print('📡 Get Response Status: ${response.statusCode}');
      print('📄 Get Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        List<Map<String, dynamic>> transactions = [];
        
        if (jsonResponse is List) {
          transactions = List<Map<String, dynamic>>.from(jsonResponse);
        } else if (jsonResponse is Map) {
          if (jsonResponse['data'] is List) {
            transactions = List<Map<String, dynamic>>.from(jsonResponse['data']);
          } else if (jsonResponse['transactions'] is List) {
            transactions = List<Map<String, dynamic>>.from(jsonResponse['transactions']);
          } else {
            transactions = [Map<String, dynamic>.from(jsonResponse)];
          }
        }

        setState(() {
          _transactions = transactions;
          _status = transactions.isNotEmpty 
              ? '✅ تم جلب ${transactions.length} معاملة من سيرفر الباك اند'
              : '📭 لا توجد معاملات في سيرفر الباك اند';
          _response = 'Status: ${response.statusCode}\nTransactions: ${transactions.length}\nResponse: ${response.body}';
        });
      } else {
        setState(() {
          _status = '❌ فشل في جلب المعاملات: ${response.statusCode}';
          _response = 'Error Status: ${response.statusCode}\nError Body: ${response.body}';
        });
      }
    } catch (e) {
      print('❌ Load Transactions Error: $e');
      setState(() {
        _status = '❌ خطأ في جلب المعاملات: $e';
        _response = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختبار سيرفر الباك اند'),
        backgroundColor: const Color(0xFF0D5DB8),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Server Info
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
                    'سيرفر الباك اند:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D5DB8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'https://graduation-project-21p3.onrender.com/transactions',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'هنا المفروض تتحفظ كل البيانات عشان كل الناس تشوفها',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Add Transaction Form
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
                    'إضافة معاملة جديدة:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'اسم المعاملة',
                      hintText: 'مثال: قهوة',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'المبلغ',
                            hintText: '25',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _categoryController,
                          decoration: InputDecoration(
                            labelText: 'الفئة',
                            hintText: 'food',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _addTransaction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('إضافة للسيرفر'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testServerConnection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D5DB8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('اختبار الاتصال'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _loadTransactions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('جلب البيانات (${_transactions.length})'),
                  ),
                ),
              ],
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
              child: Row(
                children: [
                  if (_isLoading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(
                      _status.contains('✅') ? Icons.check_circle : 
                      _status.contains('❌') ? Icons.error : Icons.info,
                      color: _status.contains('✅') ? Colors.green : 
                             _status.contains('❌') ? Colors.red : Colors.blue,
                      size: 16,
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _status.contains('✅') ? Colors.green[700] : 
                               _status.contains('❌') ? Colors.red[700] : Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Transactions List
            const Text(
              'المعاملات في السيرفر:',
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
                child: _transactions.isEmpty
                    ? const Center(
                        child: Text(
                          'لا توجد معاملات\nجرب إضافة معاملة أعلاه',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = _transactions[index];
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
                                  '${index + 1}. ${transaction['title'] ?? transaction['description'] ?? 'Unknown'}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'المبلغ: ${transaction['amount']} | الفئة: ${transaction['category']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                if (transaction['date'] != null)
                                  Text(
                                    'التاريخ: ${transaction['date']}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                if (transaction['userId'] != null)
                                  Text(
                                    'المستخدم: ${transaction['userId']}',
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

            // Response Details
            if (_response.isNotEmpty) ...[
              const SizedBox(height: 16),
              ExpansionTile(
                title: const Text('تفاصيل الاستجابة'),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _response,
                      style: const TextStyle(
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}