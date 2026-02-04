import 'package:flutter/material.dart';
import 'lib/services/shared_database_service.dart';
import 'lib/core/models/expense.dart';

/// اختبار المزامنة مع الأصدقاء
/// يختبر إضافة مصروف ومشاهدة البيانات من الداتا بيز المشتركة
void main() {
  runApp(const TestSyncWithFriendsApp());
}

class TestSyncWithFriendsApp extends StatelessWidget {
  const TestSyncWithFriendsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Sync with Friends',
      home: const TestSyncWithFriendsPage(),
    );
  }
}

class TestSyncWithFriendsPage extends StatefulWidget {
  const TestSyncWithFriendsPage({super.key});

  @override
  State<TestSyncWithFriendsPage> createState() => _TestSyncWithFriendsPageState();
}

class _TestSyncWithFriendsPageState extends State<TestSyncWithFriendsPage> {
  final SharedDatabaseService _sharedDB = SharedDatabaseService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  
  String _status = 'جاهز للاختبار مع الأصدقاء';
  List<Expense> _allExpenses = [];
  bool _isLoading = false;
  int _refreshCount = 0;

  @override
  void initState() {
    super.initState();
    _loadAllExpenses();
  }

  Future<void> _loadAllExpenses() async {
    setState(() {
      _isLoading = true;
      _status = 'جاري جلب البيانات من الداتا بيز المشتركة...';
    });

    try {
      final expenses = await _sharedDB.getAllExpensesFromSharedDB();
      setState(() {
        _allExpenses = expenses;
        _refreshCount++;
        _status = expenses.isNotEmpty 
            ? '✅ تم جلب ${expenses.length} مصروف من الداتا بيز المشتركة'
            : '📭 لا توجد مصاريف في الداتا بيز المشتركة بعد';
      });
    } catch (e) {
      setState(() {
        _status = '❌ فشل في جلب البيانات: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addQuickExpense() async {
    final name = _nameController.text.trim();
    final amountText = _amountController.text.trim();
    
    if (name.isEmpty || amountText.isEmpty) {
      setState(() {
        _status = '❌ يرجى إدخال الاسم والمبلغ';
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
      _status = 'جاري إضافة المصروف...';
    });

    try {
      final expense = Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount,
        category: 'test',
        title: name,
        date: DateTime.now(),
        isVoiceInput: false,
        quantity: 1,
      );

      final success = await _sharedDB.addExpenseToSharedDB(expense);
      
      if (success) {
        setState(() {
          _status = '✅ تم إضافة "$name" بمبلغ $amount جنيه';
          _nameController.clear();
          _amountController.clear();
        });
        
        // Refresh the list
        await _loadAllExpenses();
      } else {
        setState(() {
          _status = '❌ فشل في إضافة المصروف';
        });
      }
    } catch (e) {
      setState(() {
        _status = '❌ خطأ في إضافة المصروف: $e';
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
        title: const Text('اختبار المزامنة مع الأصدقاء'),
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
                    '👥 اختبار مع الأصدقاء:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D5DB8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1. كل واحد يضيف مصروف من جهازه\n'
                    '2. اضغط "تحديث البيانات" عشان تشوف اللي ضافوه الآخرين\n'
                    '3. لازم تشوف كل المصاريف من كل الأجهزة\n'
                    '4. ده معناه إن الداتا بيز مشتركة وشغالة',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF374151),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Quick Add Section
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
                    'إضافة مصروف سريع:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'اسم المصروف',
                            hintStyle: const TextStyle(fontSize: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'المبلغ',
                            hintStyle: const TextStyle(fontSize: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _addQuickExpense,
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
                              'إضافة للداتا بيز المشتركة',
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

            // Refresh Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isLoading ? null : _loadAllExpenses,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0D5DB8),
                  side: const BorderSide(color: Color(0xFF0D5DB8)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'تحديث البيانات (${_allExpenses.length}) - مرة #$_refreshCount',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Expenses List
            const Text(
              'كل المصاريف من كل الأجهزة:',
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
                child: _allExpenses.isEmpty
                    ? const Center(
                        child: Text(
                          'لا توجد مصاريف بعد\n\nكل واحد يضيف مصروف من جهازه\nوبعدين اضغط "تحديث البيانات"',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _allExpenses.length,
                        itemBuilder: (context, index) {
                          final expense = _allExpenses[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              children: [
                                // Index
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0D5DB8),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                
                                // Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${expense.title} (${expense.quantity}x)',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF374151),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${expense.amount} جنيه | ${expense.category}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        expense.date.toString().substring(5, 19),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Voice indicator
                                if (expense.isVoiceInput)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      '🎤',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}