import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'lib/core/models/expense.dart';
import 'lib/features/home/bloc/expense_bloc.dart';
import 'lib/features/home/bloc/expense_event.dart';
import 'lib/features/home/bloc/expense_state.dart';
import 'lib/services/shared_database_service.dart';

/// اختبار يحاكي سلوك التطبيق بالضبط
/// يضيف مصروف ويتحقق من وصوله للباك اند
void main() {
  runApp(const TestExactAppBehaviorApp());
}

class TestExactAppBehaviorApp extends StatelessWidget {
  const TestExactAppBehaviorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Exact App Behavior',
      home: BlocProvider(
        create: (context) => ExpenseBloc(),
        child: const TestExactAppBehaviorPage(),
      ),
    );
  }
}

class TestExactAppBehaviorPage extends StatefulWidget {
  const TestExactAppBehaviorPage({super.key});

  @override
  State<TestExactAppBehaviorPage> createState() => _TestExactAppBehaviorPageState();
}

class _TestExactAppBehaviorPageState extends State<TestExactAppBehaviorPage> {
  final SharedDatabaseService _sharedDB = SharedDatabaseService();
  String _status = 'جاهز لمحاكاة سلوك التطبيق';
  List<String> _logs = [];
  bool _isLoading = false;

  void _addLog(String message) {
    setState(() {
      _logs.insert(0, '${DateTime.now().toString().substring(11, 19)}: $message');
    });
    print(message);
  }

  Future<void> _testExactBehavior() async {
    setState(() {
      _isLoading = true;
      _status = 'جاري محاكاة إضافة مصروف...';
      _logs.clear();
    });

    _addLog('🚀 بدء محاكاة سلوك التطبيق');

    try {
      // 1. إنشاء مصروف بنفس الطريقة اللي في التطبيق
      final expense = Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: 35.0,
        category: 'food',
        title: 'قهوة محاكاة ${DateTime.now().hour}:${DateTime.now().minute}',
        date: DateTime.now(),
        isVoiceInput: false,
        quantity: 1,
      );

      _addLog('📝 تم إنشاء المصروف: ${expense.title}');
      _addLog('💰 المبلغ: ${expense.amount} جنيه');
      _addLog('📂 الفئة: ${expense.category}');

      // 2. إضافة للـ ExpenseBloc (بنفس الطريقة اللي في التطبيق)
      _addLog('📤 إضافة للـ ExpenseBloc...');
      
      if (mounted && context.mounted) {
        try {
          context.read<ExpenseBloc>().add(AddExpense(expense));
          _addLog('✅ تم إضافة للـ ExpenseBloc بنجاح');
          
          // انتظار قليل للـ BLoC يعالج الطلب
          await Future.delayed(const Duration(seconds: 2));
          
          // 3. اختبار مباشر للـ SharedDatabaseService
          _addLog('🔄 اختبار مباشر للـ SharedDatabaseService...');
          
          final success = await _sharedDB.addExpenseToSharedDB(expense);
          
          if (success) {
            _addLog('✅ SharedDatabaseService نجح في الحفظ');
            setState(() {
              _status = '✅ المحاكاة نجحت! البيانات وصلت للباك اند';
            });
          } else {
            _addLog('❌ SharedDatabaseService فشل في الحفظ');
            setState(() {
              _status = '❌ المحاكاة فشلت - مشكلة في الحفظ';
            });
          }
          
        } catch (e) {
          _addLog('❌ خطأ في ExpenseBloc: $e');
          setState(() {
            _status = '❌ خطأ في ExpenseBloc';
          });
        }
      }

    } catch (e) {
      _addLog('❌ خطأ عام في المحاكاة: $e');
      setState(() {
        _status = '❌ خطأ عام في المحاكاة';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testDirectAPI() async {
    setState(() {
      _isLoading = true;
      _status = 'جاري اختبار الـ API مباشرة...';
    });

    _addLog('🔍 اختبار الـ API مباشرة...');

    try {
      final success = await _sharedDB.testSharedDBConnection();
      
      if (success) {
        _addLog('✅ اختبار الاتصال نجح');
        
        // اختبار إضافة معاملة مباشرة
        final expense = Expense(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          amount: 25.0,
          category: 'food',
          title: 'اختبار مباشر ${DateTime.now().millisecondsSinceEpoch}',
          date: DateTime.now(),
          isVoiceInput: false,
          quantity: 1,
        );

        final addSuccess = await _sharedDB.addExpenseToSharedDB(expense);
        
        if (addSuccess) {
          _addLog('✅ إضافة المعاملة نجحت مباشرة');
          setState(() {
            _status = '✅ الـ API يعمل! المشكلة في مكان آخر';
          });
        } else {
          _addLog('❌ إضافة المعاملة فشلت');
          setState(() {
            _status = '❌ مشكلة في الـ API أو البيانات';
          });
        }
      } else {
        _addLog('❌ اختبار الاتصال فشل');
        setState(() {
          _status = '❌ مشكلة في الاتصال بالسيرفر';
        });
      }
    } catch (e) {
      _addLog('❌ خطأ في اختبار الـ API: $e');
      setState(() {
        _status = '❌ خطأ في اختبار الـ API';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkBackendData() async {
    setState(() {
      _isLoading = true;
      _status = 'جاري فحص بيانات الباك اند...';
    });

    _addLog('📊 فحص البيانات في الباك اند...');

    try {
      final expenses = await _sharedDB.getAllExpensesFromSharedDB();
      
      _addLog('📥 تم جلب ${expenses.length} معاملة من الباك اند');
      
      if (expenses.isNotEmpty) {
        _addLog('✅ يوجد بيانات في الباك اند:');
        for (int i = 0; i < expenses.length && i < 3; i++) {
          final expense = expenses[i];
          _addLog('   ${i + 1}. ${expense.title} - ${expense.amount} جنيه');
        }
        setState(() {
          _status = '✅ يوجد ${expenses.length} معاملة في الباك اند';
        });
      } else {
        _addLog('📭 لا توجد معاملات في الباك اند');
        setState(() {
          _status = '📭 لا توجد معاملات في الباك اند';
        });
      }
    } catch (e) {
      _addLog('❌ خطأ في فحص البيانات: $e');
      setState(() {
        _status = '❌ خطأ في فحص البيانات';
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
        title: const Text('اختبار سلوك التطبيق'),
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
                    onPressed: _isLoading ? null : _testExactBehavior,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D5DB8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('محاكاة التطبيق'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testDirectAPI,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('اختبار API'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _checkBackendData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('فحص البيانات'),
                  ),
                ),
              ],
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

            // Instructions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'التعليمات:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '1. محاكاة التطبيق: يحاكي إضافة مصروف بنفس طريقة التطبيق\n'
                    '2. اختبار API: يختبر الـ API مباشرة\n'
                    '3. فحص البيانات: يتحقق من وجود بيانات في الباك اند',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}