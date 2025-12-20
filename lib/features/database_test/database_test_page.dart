import 'package:flutter/material.dart';
import '../../core/database/database_helper.dart';
import '../../core/models/expense_model.dart';
import '../../core/services/sync_service.dart';

class DatabaseTestPage extends StatefulWidget {
  const DatabaseTestPage({super.key});

  @override
  State<DatabaseTestPage> createState() => _DatabaseTestPageState();
}

class _DatabaseTestPageState extends State<DatabaseTestPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final SyncService _syncService = SyncService();
  List<Expense> _expenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    List<Map<String, dynamic>> expensesMap = await _dbHelper.getExpenses();
    setState(() {
      _expenses = expensesMap.map((e) => Expense.fromMap(e)).toList();
    });

    // عرض إحصائيات
    int synced = _expenses.where((e) => e.isSynced == 1).length;
    int notSynced = _expenses.where((e) => e.isSynced == 0).length;
    debugPrint('📊 Stats: $synced synced, $notSynced waiting to sync');
  }

  Future<void> _addTestExpense() async {
    Expense expense = Expense(
      title: "Test ${DateTime.now().millisecond}",
      amount: 50.0 + (DateTime.now().millisecond % 100),
      category: "Food",
      date: DateTime.now().toString(),
      createdAt: DateTime.now().toString(),
    );
    int id = await _dbHelper.addExpense(expense.toMap());
    debugPrint('➕ Added expense #$id');

    // فحص النت وعمل sync
    bool hasNet = await _syncService.hasInternet();
    if (hasNet) {
      debugPrint('📶 Internet available - Syncing now...');
      await _syncService.syncExpenses();
    } else {
      debugPrint('📵 No internet - Will sync later');
    }

    _loadExpenses();
  }

  Future<void> _deleteExpense(int id) async {
    await _dbHelper.deleteExpense(id);
    _loadExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Test'),
        backgroundColor: const Color(0xFF0D47A1),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total: ${_expenses.length} expenses',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _expenses.isEmpty
                ? const Center(child: Text('No expenses\nTap + to add'))
                : ListView.builder(
                    itemCount: _expenses.length,
                    itemBuilder: (context, index) {
                      final expense = _expenses[index];
                      return ListTile(
                        leading: Icon(
                          expense.isSynced == 1
                              ? Icons.cloud_done
                              : Icons.cloud_off,
                          color: expense.isSynced == 1
                              ? Colors.green
                              : Colors.orange,
                        ),
                        title: Text(expense.title),
                        subtitle: Text(
                          '${expense.amount} EGP - ${expense.isSynced == 1 ? "Synced ✅" : "Not synced ⏳"}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteExpense(expense.id!),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTestExpense,
        child: const Icon(Icons.add),
      ),
    );
  }
}
