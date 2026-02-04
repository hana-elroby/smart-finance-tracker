import 'package:flutter/material.dart';
import '../../core/database/database_helper.dart';

class SimpleDatabaseTestPage extends StatefulWidget {
  const SimpleDatabaseTestPage({super.key});

  @override
  State<SimpleDatabaseTestPage> createState() => _SimpleDatabaseTestPageState();
}

class _SimpleDatabaseTestPageState extends State<SimpleDatabaseTestPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _expenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    try {
      List<Map<String, dynamic>> expensesMap = await _dbHelper.getExpenses();
      setState(() {
        _expenses = expensesMap;
      });
      debugPrint('✅ Loaded ${_expenses.length} expenses');
    } catch (e) {
      debugPrint('❌ Error loading expenses: $e');
    }
  }

  Future<void> _addTestExpense() async {
    try {
      Map<String, dynamic> expenseMap = {
        'title': "Test Expense ${DateTime.now().millisecond}",
        'amount': 50.0 + (DateTime.now().millisecond % 100),
        'category': "Food",
        'date': DateTime.now().toString(),
        'createdAt': DateTime.now().toString(),
        'isSynced': 0,
      };
      
      int id = await _dbHelper.addExpense(expenseMap);
      debugPrint('✅ Added expense #$id');
      _loadExpenses();
    } catch (e) {
      debugPrint('❌ Error adding expense: $e');
    }
  }

  Future<void> _deleteExpense(int id) async {
    try {
      await _dbHelper.deleteExpense(id);
      debugPrint('✅ Deleted expense #$id');
      _loadExpenses();
    } catch (e) {
      debugPrint('❌ Error deleting expense: $e');
    }
  }

  Future<void> _clearAll() async {
    try {
      await _dbHelper.clearAllData();
      debugPrint('✅ Cleared all data');
      _loadExpenses();
    } catch (e) {
      debugPrint('❌ Error clearing data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Test'),
        backgroundColor: const Color(0xFF0D47A1),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearAll,
            tooltip: 'Clear All',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Expenses: ${_expenses.length}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: _loadExpenses,
                  child: const Text('Refresh'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _expenses.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No expenses found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap + to add a test expense',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _expenses.length,
                    itemBuilder: (context, index) {
                      final expense = _expenses[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Text(
                              '${expense['id']}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            expense['title'] ?? 'No Title',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${expense['amount']} EGP',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Category: ${expense['category'] ?? 'N/A'}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                'Synced: ${expense['isSynced'] == 1 ? 'Yes ✅' : 'No ⏳'}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: expense['isSynced'] == 1
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteExpense(expense['id']),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTestExpense,
        backgroundColor: const Color(0xFF0D47A1),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}