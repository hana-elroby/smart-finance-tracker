import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'lib/core/models/expense.dart';
import 'lib/features/home/bloc/expense_bloc.dart';
import 'lib/features/home/bloc/expense_event.dart';
import 'lib/features/home/bloc/expense_state.dart';
import 'lib/features/items/items_page.dart';
import 'lib/widgets/dialogs/manual_entry_dialog.dart';

/// Test app to verify quantity functionality
/// Tests:
/// 1. Manual entry with quantity (e.g., 2 coffee for 60 EGP = 2x coffee)
/// 2. Chart shows total quantities, not entry counts
/// 3. Voice input processes quantity correctly
void main() {
  runApp(const QuantityTestApp());
}

class QuantityTestApp extends StatelessWidget {
  const QuantityTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quantity Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BlocProvider(
        create: (context) => ExpenseBloc(),
        child: const QuantityTestPage(),
      ),
    );
  }
}

class QuantityTestPage extends StatelessWidget {
  const QuantityTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quantity Functionality Test'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test Scenarios:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Test 1: Add sample expenses with quantities
            ElevatedButton(
              onPressed: () => _addSampleExpenses(context),
              child: const Text('1. Add Sample Expenses with Quantities'),
            ),
            const SizedBox(height: 12),
            
            // Test 2: Open manual entry dialog
            ElevatedButton(
              onPressed: () => _testManualEntry(context),
              child: const Text('2. Test Manual Entry (Quantity Input)'),
            ),
            const SizedBox(height: 12),
            
            // Test 3: Open Items page to see chart
            ElevatedButton(
              onPressed: () => _openItemsPage(context),
              child: const Text('3. View Items Chart (Should Show Quantities)'),
            ),
            const SizedBox(height: 20),
            
            const Text(
              'Expected Results:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Chart should show total quantities (e.g., "5x" for coffee)\n'
              '• Not entry counts (e.g., "2 times purchased")\n'
              '• Manual entry allows quantity input\n'
              '• Total = Unit Price × Quantity',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            
            // Current expenses display
            Expanded(
              child: BlocBuilder<ExpenseBloc, ExpenseState>(
                builder: (context, state) {
                  if (state is ExpenseLoaded) {
                    final foodExpenses = state.getExpensesByCategory('Food & Drink');
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Food & Drink Expenses (${foodExpenses.length}):',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            itemCount: foodExpenses.length,
                            itemBuilder: (context, index) {
                              final expense = foodExpenses[index];
                              return Card(
                                child: ListTile(
                                  title: Text('${expense.quantity}x ${expense.title}'),
                                  subtitle: Text(
                                    'Unit: ${(expense.amount / expense.quantity).toStringAsFixed(2)} EGP\n'
                                    'Total: ${expense.amount.toStringAsFixed(2)} EGP',
                                  ),
                                  trailing: Text(
                                    'Qty: ${expense.quantity}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }
                  return const Center(child: Text('No expenses yet'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addSampleExpenses(BuildContext context) {
    final bloc = context.read<ExpenseBloc>();
    
    // Add sample expenses with different quantities
    final sampleExpenses = [
      Expense(
        id: '1',
        title: 'Coffee',
        amount: 60.0, // 2 coffee × 30 EGP each
        quantity: 2,
        category: 'Food & Drink',
        date: DateTime.now(),
      ),
      Expense(
        id: '2',
        title: 'Coffee',
        amount: 90.0, // 3 coffee × 30 EGP each
        quantity: 3,
        category: 'Food & Drink',
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Expense(
        id: '3',
        title: 'Bread',
        amount: 15.0, // 3 bread × 5 EGP each
        quantity: 3,
        category: 'Food & Drink',
        date: DateTime.now(),
      ),
      Expense(
        id: '4',
        title: 'Water',
        amount: 20.0, // 4 water × 5 EGP each
        quantity: 4,
        category: 'Food & Drink',
        date: DateTime.now(),
      ),
    ];

    for (final expense in sampleExpenses) {
      bloc.add(AddExpense(expense));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Added sample expenses:\n'
            '• Coffee: 5x total (2x + 3x)\n'
            '• Bread: 3x\n'
            '• Water: 4x'),
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _testManualEntry(BuildContext context) async {
    final result = await showManualEntryDialog(
      context,
      initialCategory: 'Food & Drink',
    );
    
    if (result != null) {
      final expense = Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: result['title'] as String,
        amount: result['amount'] as double,
        category: result['category'] as String,
        date: result['date'] as DateTime,
        quantity: result['quantity'] as int? ?? 1,
      );
      
      context.read<ExpenseBloc>().add(AddExpense(expense));
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Added: ${expense.quantity}x ${expense.title}\n'
            'Unit: ${(expense.amount / expense.quantity).toStringAsFixed(2)} EGP\n'
            'Total: ${expense.amount.toStringAsFixed(2)} EGP',
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _openItemsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ItemsPage(
          categoryName: 'Food & Drink',
          categoryIcon: Icons.restaurant,
          categoryColor: Colors.orange,
        ),
      ),
    );
  }
}