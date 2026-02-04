import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'lib/core/models/expense.dart';
import 'lib/features/home/bloc/expense_bloc.dart';
import 'lib/features/home/bloc/expense_event.dart';
import 'lib/features/home/bloc/expense_state.dart';
import 'lib/services/shared_database_service.dart';

/// اختبار بسيط للداتا بيز المشتركة
/// يختبر إضافة مصروف ومشاهدته في سيرفر الباك اند
void main() {
  runApp(const TestSimpleBackendApp());
}

class TestSimpleBackendApp extends StatelessWidget {
  const TestSimpleBackendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Simple Backend',
      home: BlocProvider(
        create: (context) => ExpenseBloc(),
        child: const TestSimpleBackendPage(),
      ),
    );
  }
}

class TestSimpleBackendPage extends StatefulWidget {
  const TestSimpleBackendPage({super.key});

  @override
  State<TestSimpleBackendPage> createState() => _TestSimpleBackendPageState();
}

class _TestSimpleBackendPageState extends State<TestSimpleBackendPage> {
  final SharedDatabaseService _sharedDB = SharedDatabaseService();
  String _status = 'جاهز للاختبار';
  bool _isLoading = false;

  Future<void> _testAddExpense() async {
    setState(() {
      _isLoading = true;
      _status = 'جاري إضافة مصروف تجريبي...';
    });

    try {
      // إنشاء مصروف تجريبي
      final expense = Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: 25.0,
        category: 'food',
        title: 'قهوة تجريبية',
        date: DateTime.now(),
        isVoiceInput: false,
        quantity: 1,
      );

      // إضافة للـ ExpenseBloc (هيحفظ في الداتا بيز المشتركة)
      context.read<ExpenseBloc>().add(AddExpense(expense));

      setState(() {
        _status = '✅ تم إضافة المصروف! تحقق من سيرفر الباك اند';
      });

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

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _status = 'جاري اختبار الاتصال...';
    });

    try {
      final isConnected = await _sharedDB.testSharedDBConnection();
      setState(() {
        _status = isConnected 
            ? '✅ الاتصال بسيرفر الباك اند ناجح'
            : '❌ فشل في الاتصال بسيرفر الباك اند';
      });
    } catch (e) {
      setState(() {
        _status = '❌ خطأ في الاتصال: $e';
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
                    'سيرفر الباك اند:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D5DB8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'https://graduation-project-21p3.onrender.com',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'المفروض لما تضيف مصروف هنا، يظهر في الداتا بيز عند الباك اند team',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Test Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _testConnection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D5DB8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'اختبار الاتصال بالسيرفر',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _testAddExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'إضافة مصروف تجريبي',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Status
            Container(
              width: double.infinity,
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

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'التعليمات:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1. اضغط "اختبار الاتصال" للتأكد من أن السيرفر يعمل\n'
                    '2. اضغط "إضافة مصروف تجريبي" لإضافة بيانات\n'
                    '3. اطلب من الباك اند team يتحققوا من الداتا بيز\n'
                    '4. المفروض يشوفوا المصروف الجديد في جدول transactions',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ExpenseBloc State
            BlocBuilder<ExpenseBloc, ExpenseState>(
              builder: (context, state) {
                if (state is ExpenseLoaded) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'المصاريف المحلية: ${state.expenses.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (state.expenses.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'آخر مصروف: ${state.expenses.last.title} - ${state.expenses.last.amount} جنيه',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}