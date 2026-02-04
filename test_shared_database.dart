import 'package:flutter/material.dart';
import 'lib/services/shared_database_service.dart';
import 'lib/core/models/expense.dart';

/// اختبار الداتا بيز المشتركة
/// يختبر حفظ وجلب البيانات من سيرفر الباك اند
void main() {
  runApp(const TestSharedDatabaseApp());
}

class TestSharedDatabaseApp extends StatelessWidget {
  const TestSharedDatabaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Shared Database',
      home: const TestSharedDatabasePage(),
    );
  }
}

class TestSharedDatabasePage extends StatefulWidget {
  const TestSharedDatabasePage({super.key});

  @override
  State<TestSharedDatabasePage> createState() => _TestSharedDatabasePageState();
}

class _TestSharedDatabasePageState extends State<TestSharedDatabasePage> {
  final SharedDatabaseService _sharedDB = SharedDatabaseService();
  String _status = 'جاهز للاختبار';
  List<Expense> _expenses = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _status = 'جاري اختبار الاتصال...';
    });

    final isConnected = await _sharedDB.testSharedDBConnection();
    
    setState(() {
      _isLoading = false;
      _status = isConnected 
          ? '✅ متصل بالداتا بيز المشتركة'
          : '❌ فشل في الاتصال بالداتا بيز المشتركة';
    });

    if (isConnected) {
      await _loadExpenses();
    }
  }

  Future<void> _loadExpenses() async {
    setState(() {
      _isLoading = true;
      _status = 'جاري جلب البيانات...';
    });

    final expenses = await _sharedDB.getAllExpensesFromSharedDB();
    
    setState(() {
      _isLoading = false;
      _expenses = expenses;
      _status = expenses.isNotEmpty 
          ? '✅ تم جلب ${expenses.length} مصروف من الداتا بيز المشتركة'
          : '📭 لا توجد مصاريف في الداتا بيز المشتركة';
    });
  }

  Future<void> _addTestExpense() async {
    setState(() {
      _isLoading = true;
      _status = 'جاري إضافة مصروف تجريبي...';
    });

    final testExpense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: 25.0,
      category: 'food',
      title: 'خبز تجريبي',
      date: DateTime.now(),
      isVoiceInput: false,
      quantity: 2,
    );

    final success = await _sharedDB.addExpenseToSharedDB(testExpense);
    
    setState(() {
      _isLoading = false;
      _status = success 
          ? '✅ تم إضافة المصروف التجريبي بنجاح'
          : '❌ فشل في إضافة المصروف التجريبي';
    });

    if (success) {
      await _loadExpenses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختبار الداتا بيز المشتركة'),
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
                    'الداتا بيز المشتركة:',
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
                    'هنا هتتحفظ كل البيانات عشان كل الناس تشوفها',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
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

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testConnection,
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
                    onPressed: _isLoading ? null : _addTestExpense,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('إضافة مصروف تجريبي'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Expenses List
            const Text(
              'المصاريف في الداتا بيز المشتركة:',
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
                child: _expenses.isEmpty
                    ? const Center(
                        child: Text(
                          'لا توجد مصاريف\nجرب إضافة مصروف تجريبي أعلاه',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _expenses.length,
                        itemBuilder: (context, index) {
                          final expense = _expenses[index];
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
                                  '${index + 1}. ${expense.title} (${expense.quantity}x)',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'المبلغ: ${expense.amount} جنيه | الفئة: ${expense.category}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  'التاريخ: ${expense.date.toString().substring(0, 19)}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                if (expense.isVoiceInput)
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      '🎤 Voice Input',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),

            // Refresh Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isLoading ? null : _loadExpenses,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0D5DB8),
                  side: const BorderSide(color: Color(0xFF0D5DB8)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'تحديث البيانات (${_expenses.length})',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}