// Expense Repository - مستودع المصاريف
// Handles data operations for expenses (local + remote)

import '../database/database_helper.dart';
import '../models/expense_model.dart';
import '../services/firestore_service.dart';
import '../services/sync_service.dart';

class ExpenseRepository {
  static final ExpenseRepository instance = ExpenseRepository._internal();
  ExpenseRepository._internal();
  factory ExpenseRepository() => instance;

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final FirestoreService _firestoreService = FirestoreService();
  final SyncService _syncService = SyncService();

  // Add expense (saves locally first, then syncs)
  Future<Expense?> addExpense(Expense expense) async {
    try {
      // Save to local database
      final id = await _dbHelper.addExpense(expense.toMap());
      final savedExpense = expense.copyWith(id: id);

      // Try to sync immediately if online
      final hasNet = await _syncService.hasInternet();
      if (hasNet) {
        final firestoreId = await _firestoreService.addExpense(savedExpense);
        if (firestoreId != null) {
          await _dbHelper.markExpenseAsSynced(id);
          return savedExpense.copyWith(isSynced: 1, firestoreId: firestoreId);
        }
      }

      return savedExpense;
    } catch (e) {
      print('❌ Error adding expense: $e');
      return null;
    }
  }

  // Get all expenses from local database
  Future<List<Expense>> getExpenses() async {
    try {
      final expensesMap = await _dbHelper.getExpenses();
      return expensesMap.map((e) => Expense.fromMap(e)).toList();
    } catch (e) {
      print('❌ Error getting expenses: $e');
      return [];
    }
  }

  // Get expense by ID
  Future<Expense?> getExpenseById(int id) async {
    try {
      final expenses = await getExpenses();
      return expenses.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  // Update expense
  Future<bool> updateExpense(Expense expense) async {
    try {
      if (expense.id == null) return false;

      final updatedExpense = expense.copyWith(
        updatedAt: DateTime.now().toIso8601String(),
        isSynced: 0, // Mark as unsynced after update
      );

      await _dbHelper.updateExpense(expense.id!, updatedExpense.toMap());

      // Try to sync
      final hasNet = await _syncService.hasInternet();
      if (hasNet && expense.firestoreId != null) {
        await _firestoreService.updateExpense(
          expense.firestoreId!,
          updatedExpense,
        );
        await _dbHelper.markExpenseAsSynced(expense.id!);
      }

      return true;
    } catch (e) {
      print('❌ Error updating expense: $e');
      return false;
    }
  }

  // Delete expense
  Future<bool> deleteExpense(int id, {String? firestoreId}) async {
    try {
      await _dbHelper.deleteExpense(id);

      // Delete from Firestore if synced
      if (firestoreId != null) {
        final hasNet = await _syncService.hasInternet();
        if (hasNet) {
          await _firestoreService.deleteExpense(firestoreId);
        }
      }

      return true;
    } catch (e) {
      print('❌ Error deleting expense: $e');
      return false;
    }
  }

  // Get expenses by category
  Future<List<Expense>> getExpensesByCategory(String category) async {
    final expenses = await getExpenses();
    return expenses.where((e) => e.category == category).toList();
  }

  // Get expenses by date range
  Future<List<Expense>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final expenses = await getExpenses();
    return expenses.where((e) {
      final date = DateTime.tryParse(e.date);
      if (date == null) return false;
      return date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  // Get today's expenses
  Future<List<Expense>> getTodayExpenses() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getExpensesByDateRange(startOfDay, endOfDay);
  }

  // Get this week's expenses
  Future<List<Expense>> getThisWeekExpenses() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return getExpensesByDateRange(
      DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
      now,
    );
  }

  // Get this month's expenses
  Future<List<Expense>> getThisMonthExpenses() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return getExpensesByDateRange(startOfMonth, now);
  }

  // Get total amount
  Future<double> getTotalAmount() async {
    final expenses = await getExpenses();
    return expenses.fold<double>(0, (sum, e) => sum + e.amount);
  }

  // Get total by category
  Future<Map<String, double>> getTotalByCategory() async {
    final expenses = await getExpenses();
    final Map<String, double> totals = {};

    for (final expense in expenses) {
      final category = expense.category ?? 'Other';
      totals[category] = (totals[category] ?? 0) + expense.amount;
    }

    return totals;
  }

  // Get unsynced count
  Future<int> getUnsyncedCount() async {
    final unsynced = await _dbHelper.getUnsyncedExpenses();
    return unsynced.length;
  }

  // Sync all unsynced expenses
  Future<void> syncAll() async {
    await _syncService.syncExpenses();
  }

  // Clear all local data
  Future<void> clearAll() async {
    await _dbHelper.clearAllData();
  }
}
