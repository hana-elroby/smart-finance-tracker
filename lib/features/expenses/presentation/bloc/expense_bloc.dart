// Expense Bloc - منطق المصاريف
// Handles all expense-related business logic

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/expense_model.dart';
import '../../../../core/repositories/expense_repository.dart';
import '../../../../core/services/sync_service.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseRepository _repository = ExpenseRepository();
  final SyncService _syncService = SyncService();

  ExpenseBloc() : super(const ExpenseState()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<AddExpense>(_onAddExpense);
    on<UpdateExpense>(_onUpdateExpense);
    on<DeleteExpense>(_onDeleteExpense);
    on<FilterByCategory>(_onFilterByCategory);
    on<FilterByDateRange>(_onFilterByDateRange);
    on<ClearFilter>(_onClearFilter);
    on<SyncExpenses>(_onSyncExpenses);
    on<SearchExpenses>(_onSearchExpenses);
  }

  // Load all expenses
  Future<void> _onLoadExpenses(
    LoadExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(state.copyWith(status: ExpenseStatus.loading));

    try {
      final expenses = await _repository.getExpenses();
      final totalAmount = await _repository.getTotalAmount();
      final categoryTotals = await _repository.getTotalByCategory();
      final unsyncedCount = await _repository.getUnsyncedCount();

      emit(state.copyWith(
        status: ExpenseStatus.loaded,
        expenses: expenses,
        filteredExpenses: expenses,
        totalAmount: totalAmount,
        categoryTotals: categoryTotals,
        unsyncedCount: unsyncedCount,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ExpenseStatus.error,
        errorMessage: 'Failed to load expenses: $e',
      ));
    }
  }

  // Add new expense
  Future<void> _onAddExpense(
    AddExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(state.copyWith(status: ExpenseStatus.loading));

    try {
      final expense = Expense(
        title: event.title,
        amount: event.amount,
        category: event.category,
        date: event.date.toIso8601String(),
        description: event.description,
        createdAt: DateTime.now().toIso8601String(),
      );

      final savedExpense = await _repository.addExpense(expense);

      if (savedExpense != null) {
        final updatedExpenses = [savedExpense, ...state.expenses];
        final totalAmount = state.totalAmount + event.amount;

        emit(state.copyWith(
          status: ExpenseStatus.loaded,
          expenses: updatedExpenses,
          filteredExpenses: updatedExpenses,
          totalAmount: totalAmount,
          successMessage: 'Expense added successfully',
        ));

        // Reload to get updated stats
        add(const LoadExpenses());
      } else {
        emit(state.copyWith(
          status: ExpenseStatus.error,
          errorMessage: 'Failed to add expense',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ExpenseStatus.error,
        errorMessage: 'Failed to add expense: $e',
      ));
    }
  }

  // Update expense
  Future<void> _onUpdateExpense(
    UpdateExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(state.copyWith(status: ExpenseStatus.loading));

    try {
      final success = await _repository.updateExpense(event.expense);

      if (success) {
        add(const LoadExpenses());
      } else {
        emit(state.copyWith(
          status: ExpenseStatus.error,
          errorMessage: 'Failed to update expense',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ExpenseStatus.error,
        errorMessage: 'Failed to update expense: $e',
      ));
    }
  }

  // Delete expense
  Future<void> _onDeleteExpense(
    DeleteExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      final success = await _repository.deleteExpense(
        event.id,
        firestoreId: event.firestoreId,
      );

      if (success) {
        final updatedExpenses =
            state.expenses.where((e) => e.id != event.id).toList();

        emit(state.copyWith(
          expenses: updatedExpenses,
          filteredExpenses: updatedExpenses,
          successMessage: 'Expense deleted',
        ));

        // Reload to get updated stats
        add(const LoadExpenses());
      }
    } catch (e) {
      emit(state.copyWith(
        status: ExpenseStatus.error,
        errorMessage: 'Failed to delete expense: $e',
      ));
    }
  }

  // Filter by category
  void _onFilterByCategory(
    FilterByCategory event,
    Emitter<ExpenseState> emit,
  ) {
    if (event.category == null) {
      emit(state.copyWith(
        filteredExpenses: state.expenses,
        selectedCategory: null,
      ));
    } else {
      final filtered = state.expenses
          .where((e) => e.category == event.category)
          .toList();

      emit(state.copyWith(
        filteredExpenses: filtered,
        selectedCategory: event.category,
      ));
    }
  }

  // Filter by date range
  void _onFilterByDateRange(
    FilterByDateRange event,
    Emitter<ExpenseState> emit,
  ) {
    final filtered = state.expenses.where((e) {
      final date = DateTime.tryParse(e.date);
      if (date == null) return false;
      return date.isAfter(event.startDate.subtract(const Duration(days: 1))) &&
          date.isBefore(event.endDate.add(const Duration(days: 1)));
    }).toList();

    emit(state.copyWith(
      filteredExpenses: filtered,
      startDate: event.startDate,
      endDate: event.endDate,
    ));
  }

  // Clear all filters
  void _onClearFilter(ClearFilter event, Emitter<ExpenseState> emit) {
    emit(state.copyWith(
      filteredExpenses: state.expenses,
      selectedCategory: null,
      startDate: null,
      endDate: null,
      searchQuery: null,
    ));
  }

  // Sync expenses
  Future<void> _onSyncExpenses(
    SyncExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(state.copyWith(isSyncing: true));

    try {
      final result = await _syncService.manualSync();

      if (result.success) {
        emit(state.copyWith(
          isSyncing: false,
          unsyncedCount: 0,
          successMessage: result.message,
        ));
        add(const LoadExpenses());
      } else {
        emit(state.copyWith(
          isSyncing: false,
          errorMessage: result.message,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isSyncing: false,
        errorMessage: 'Sync failed: $e',
      ));
    }
  }

  // Search expenses
  void _onSearchExpenses(SearchExpenses event, Emitter<ExpenseState> emit) {
    if (event.query.isEmpty) {
      emit(state.copyWith(
        filteredExpenses: state.expenses,
        searchQuery: null,
      ));
    } else {
      final query = event.query.toLowerCase();
      final filtered = state.expenses.where((e) {
        return e.title.toLowerCase().contains(query) ||
            (e.description?.toLowerCase().contains(query) ?? false) ||
            (e.category?.toLowerCase().contains(query) ?? false);
      }).toList();

      emit(state.copyWith(
        filteredExpenses: filtered,
        searchQuery: event.query,
      ));
    }
  }
}
