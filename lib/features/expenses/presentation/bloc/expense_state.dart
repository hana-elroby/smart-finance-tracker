// Expense State - حالات المصاريف
// States for expense management

import 'package:equatable/equatable.dart';
import '../../../../core/models/expense_model.dart';

enum ExpenseStatus {
  initial,
  loading,
  loaded,
  error,
}

class ExpenseState extends Equatable {
  final ExpenseStatus status;
  final List<Expense> expenses;
  final List<Expense> filteredExpenses;
  final double totalAmount;
  final Map<String, double> categoryTotals;
  final String? selectedCategory;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;
  final int unsyncedCount;
  final bool isSyncing;
  final String? errorMessage;
  final String? successMessage;

  const ExpenseState({
    this.status = ExpenseStatus.initial,
    this.expenses = const [],
    this.filteredExpenses = const [],
    this.totalAmount = 0,
    this.categoryTotals = const {},
    this.selectedCategory,
    this.startDate,
    this.endDate,
    this.searchQuery,
    this.unsyncedCount = 0,
    this.isSyncing = false,
    this.errorMessage,
    this.successMessage,
  });

  ExpenseState copyWith({
    ExpenseStatus? status,
    List<Expense>? expenses,
    List<Expense>? filteredExpenses,
    double? totalAmount,
    Map<String, double>? categoryTotals,
    String? selectedCategory,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    int? unsyncedCount,
    bool? isSyncing,
    String? errorMessage,
    String? successMessage,
  }) {
    return ExpenseState(
      status: status ?? this.status,
      expenses: expenses ?? this.expenses,
      filteredExpenses: filteredExpenses ?? this.filteredExpenses,
      totalAmount: totalAmount ?? this.totalAmount,
      categoryTotals: categoryTotals ?? this.categoryTotals,
      selectedCategory: selectedCategory,
      startDate: startDate,
      endDate: endDate,
      searchQuery: searchQuery,
      unsyncedCount: unsyncedCount ?? this.unsyncedCount,
      isSyncing: isSyncing ?? this.isSyncing,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  // Helper getters
  bool get isLoading => status == ExpenseStatus.loading;
  bool get hasExpenses => expenses.isNotEmpty;
  bool get hasFilters =>
      selectedCategory != null ||
      startDate != null ||
      endDate != null ||
      searchQuery != null;

  // Get today's expenses
  List<Expense> get todayExpenses {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return expenses.where((e) {
      final date = DateTime.tryParse(e.date);
      if (date == null) return false;
      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    }).toList();
  }

  // Get today's total
  double get todayTotal {
    return todayExpenses.fold<double>(0, (sum, e) => sum + e.amount);
  }

  // Get this week's total
  double get weekTotal {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    return expenses.where((e) {
      final date = DateTime.tryParse(e.date);
      if (date == null) return false;
      return date.isAfter(start.subtract(const Duration(days: 1)));
    }).fold<double>(0, (sum, e) => sum + e.amount);
  }

  // Get this month's total
  double get monthTotal {
    final now = DateTime.now();
    return expenses.where((e) {
      final date = DateTime.tryParse(e.date);
      if (date == null) return false;
      return date.year == now.year && date.month == now.month;
    }).fold<double>(0, (sum, e) => sum + e.amount);
  }

  @override
  List<Object?> get props => [
        status,
        expenses,
        filteredExpenses,
        totalAmount,
        categoryTotals,
        selectedCategory,
        startDate,
        endDate,
        searchQuery,
        unsyncedCount,
        isSyncing,
        errorMessage,
        successMessage,
      ];
}
