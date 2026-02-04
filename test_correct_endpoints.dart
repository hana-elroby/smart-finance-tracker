import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'lib/core/models/expense.dart';
import 'lib/features/home/bloc/expense_bloc.dart';
import 'lib/features/home/bloc/expense_event.dart';
import 'lib/features/home/bloc/expense_state.dart';
import 'lib/services/shared_database_service.dart';

/// اختبار الـ endpoints الصحيحة من الـ Postman collection
/// يستخدم /transactions/createWithText بدلاً من /transactions
void main() {
  runApp(const TestCorrectEndpointsApp());
}

class TestCorrectEndpointsApp extends StatelessWidget {
  const TestCorrectEndpointsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Correct Endpoints',
      home: BlocProvider(
        create: (context) => ExpenseBloc(),
        child: const TestCorrectEndpointsPage(),
      ),
    );
  }
}

class TestCorrectEndpointsPage extends StatefulWidget {
  const TestCorrectEndpointsPage({super.key});

  @override
  State<TestCorrectEndpointsPage> createState() => _TestCorrectEndpointsPageState();
}

class _TestCorrectEndpointsPageState extends State<TestCorrectEndpointsPage> {
  final SharedDatabaseService _sharedDB = SharedDatabaseService();
  String _status = 'جاهز لاختبار الـ endpoints الصحيحة';
  List<String> _logs = [];
  bool _isLoading = false;

  void _addLog(String message) {
    setState(() {
      _logs.insert(0, '${DateTime.now().toString().substring(11, 19)}: $message');
    });
    print(message);
  }

  Future<void> _testCorrectEndpoints() async {
    setState(() {
      _isLoading = true;
      _status = 'جاري اختبار الـ endpoints الصحيحة...';
      _logs.clear();
    });

    _addLog('🚀 بدء اختبار الـ endpoints الصحيحة من الـ Postman');

    try {
      // 1. إنشاء مصروف تجريبي
      final expense = Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: 45.0,
        category: 'food',
        title: 'اختبار endpoint صحيح ${DateTime.now().hour}:${DateTime.now().minute}',
        date: DateTime.now(),
        isVoiceInput: false,
        quantity: 1,
      );

      _addLog('📝 تم إنشاء المصروف: ${expense.title}');
      _addLog('💰 المبلغ: ${expense.amount} جنيه');
      _addLog('📂 الفئة: ${expense.category}');

      // 2. اختبار الـ endpoint الجديد (/transactions/createWithText)
      _addLog('📤 اختبار POST /transactions/createWithText...');
      
      final success = await _sharedDB.addExpenseToSharedDB(expense);
      
      if (success) {
        _addLog('✅ نجح في الحفظ باستخدام /transactions/createWithText');
        
        // 3. اختبار جلب البيانات
        _addLog('📥 اختبار GET /transactions...');
        
        final expenses = await _sharedDB.getAllExpensesFromSharedDB();
        
        if (expenses.isNotEmpty) {
          _addLog('✅ تم جلب ${expenses.length} معاملة من الباك اند');
          _addLog('📊 آخر معاملة: ${expenses.first.title}');
          
          setState(() {
            _status = '✅ الـ endpoints الصحيحة تعمل! البيانات وصلت للباك اند';
          });
        } else {
          _addLog('📭 لا توجد معاملات في الباك اند');
          setState(() {
            _status = '⚠️ الحفظ نجح لكن الجلب فارغ';
          });
        }
        
        // 4. اختبار ExpenseBloc
        _addLog('🔄 اختبار ExpenseBloc...');
        
        if (mounted && context.mounted) {
          try {
            context.read<ExpenseBloc>().add(AddExpense(expense));
            _addLog('✅ ExpenseBloc يعمل بشكل صحيح');
          } catch (e) {
            _addLog('❌ خطأ في ExpenseBloc: $e');
          }
        }
        
      } else {
        _addLog('❌ فشل في الحفظ - تحقق من الـ endpoint أو البيانات');
        setState(() {
          _status = '❌ فشل في الحفظ - مشكلة في الـ API';
        });
      }

    } catch (e) {
      _addLog('❌ خطأ عام في الاختبار: $e');
      setState(() {
        _status = '❌ خطأ عام في الاختبار';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testHealthCheck() async {
    setState(() {
      _isLoading = true;
      _status = 'جاري اختبار Health Check...';
    });

    _addLog('🔍 اختبار GET /api (Health Check)...');

    try {
      final success = await _sharedDB.testSharedDBConnection();
      
      if (success) {
        _addLog('✅ Health Check نجح - السيرفر يعمل');
        setState(() {
          _status = '✅ السيرفر يعمل بشكل طبيعي';
        });
      } else {
        _addLog('❌ Health Check فشل - السيرفر لا يستجيب');
        setState(() {
          _status = '❌ السيرفر لا يستجيب';
        });
      }
    } catch (e) {
      _addLog('❌ خطأ في Health Check: $e');
      setState(() {
        _status = '❌ خطأ في الاتصال بالسيرفر';
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
        title: const Text('اختبار الـ Endpoints الصحيحة'),
        backgroundColor: const Color(0xFF0D5DB8),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _status.contains('✅') 
                    ? Colors.green.withOpacity(0.1)
                    : _status.contains('❌')
                        ? Colors.red.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
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
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(
                      _status.contains('✅') ? Icons.check_circle : 
                      _status.contains('❌') ? Icons.error : Icons.info,
                      color: _status.contains('✅') ? Colors.green : 
                             _status.contains('❌') ? Colors.red : Colors.blue,
                      size: 20,
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _status,
                      style: TextStyle(
                        fontSize: 14,
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

            // Test Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testHealthCheck,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D5DB8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Health Check'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testCorrectEndpoints,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('اختبار الـ APIs'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Info Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'الـ Endpoints المستخدمة:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D5DB8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '✅ POST /transactions/createWithText - إضافة معاملة\n'
                    '✅ GET /transactions - جلب المعاملات\n'
                    '✅ GET /api - Health check\n\n'
                    'هذه هي الـ endpoints الصحيحة من الـ Postman collection',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF0D5DB8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Logs
            const Text(
              'سجل العمليات:',
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
                child: _logs.isEmpty
                    ? const Center(
                        child: Text(
                          'لا توجد عمليات بعد\nاضغط على أحد الأزرار أعلاه',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          final log = _logs[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: log.contains('✅') 
                                  ? Colors.green.withOpacity(0.1)
                                  : log.contains('❌')
                                      ? Colors.red.withOpacity(0.1)
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              log,
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                                color: log.contains('✅') ? Colors.green[700] : 
                                       log.contains('❌') ? Colors.red[700] : Colors.black87,
                              ),
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