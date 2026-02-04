import 'package:flutter/material.dart';
import 'lib/core/database/database_helper.dart';
import 'lib/core/services/sync_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Database Test - Chrome',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const DatabaseTestPage(),
    );
  }
}

class DatabaseTestPage extends StatefulWidget {
  const DatabaseTestPage({super.key});

  @override
  State<DatabaseTestPage> createState() => _DatabaseTestPageState();
}

class _DatabaseTestPageState extends State<DatabaseTestPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final SyncService _syncService = SyncService();
  List<Map<String, dynamic>> _expenses = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    setState(() => _isLoading = true);
    try {
      List<Map<String, dynamic>> expensesMap = await _dbHelper.getExpenses();
      setState(() {
        _expenses = expensesMap;
        _isLoading = false;
      });

      // عرض إحصائيات
      int synced = _expenses.where((e) => (e['isSynced'] ?? 0) == 1).length;
      int notSynced = _expenses.where((e) => (e['isSynced'] ?? 0) == 0).length;
      debugPrint('📊 Stats: $synced synced, $notSynced waiting to sync');
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('❌ Error loading expenses: $e');
      _showMessage('Error loading expenses: $e');
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
      debugPrint('➕ Added expense #$id');
      _showMessage('✅ Added expense #$id');

      // فحص النت وعمل sync
      bool hasNet = await _syncService.hasInternet();
      if (hasNet) {
        debugPrint('📶 Internet available - Syncing now...');
        await _syncService.syncExpenses();
        _showMessage('📶 Synced with server');
      } else {
        debugPrint('📵 No internet - Will sync later');
        _showMessage('📵 No internet - Will sync later');
      }

      _loadExpenses();
    } catch (e) {
      debugPrint('❌ Error adding expense: $e');
      _showMessage('❌ Error: $e');
    }
  }

  Future<void> _deleteExpense(int id) async {
    try {
      await _dbHelper.deleteExpense(id);
      debugPrint('✅ Deleted expense #$id');
      _showMessage('✅ Deleted expense #$id');
      _loadExpenses();
    } catch (e) {
      debugPrint('❌ Error deleting expense: $e');
      _showMessage('❌ Error: $e');
    }
  }

  Future<void> _clearAll() async {
    try {
      await _dbHelper.clearAllData();
      debugPrint('✅ Cleared all data');
      _showMessage('✅ Cleared all data');
      _loadExpenses();
    } catch (e) {
      debugPrint('❌ Error clearing data: $e');
      _showMessage('❌ Error: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Test - Chrome Ready'),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadExpenses,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearAll,
            tooltip: 'Clear All',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Stats
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.blue.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Text(
                  '💾 Database Test',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total: ${_expenses.length} expenses',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard(
                      'Synced',
                      _expenses.where((e) => (e['isSynced'] ?? 0) == 1).length,
                      Colors.green,
                      Icons.cloud_done,
                    ),
                    _buildStatCard(
                      'Pending',
                      _expenses.where((e) => (e['isSynced'] ?? 0) == 0).length,
                      Colors.orange,
                      Icons.cloud_off,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading expenses...'),
                      ],
                    ),
                  )
                : _expenses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No expenses found',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the + button to add a test expense',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _expenses.length,
                        itemBuilder: (context, index) {
                          final expense = _expenses[index];
                          final isSynced = (expense['isSynced'] ?? 0) == 1;
                          
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            elevation: 2,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isSynced ? Colors.green : Colors.orange,
                                child: Icon(
                                  isSynced ? Icons.cloud_done : Icons.cloud_off,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                expense['title'] ?? 'No Title',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    '💰 ${expense['amount']} EGP',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '📂 ${expense['category'] ?? 'N/A'}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    isSynced ? "✅ Synced" : "⏳ Pending sync",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isSynced ? Colors.green : Colors.orange,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteExpense(expense['id']),
                                tooltip: 'Delete expense',
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTestExpense,
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Test Expense'),
      ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}