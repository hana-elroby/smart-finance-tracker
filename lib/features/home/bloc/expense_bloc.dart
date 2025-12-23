import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/expense.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  static const String _storageKey = 'expenses_data';
  
  ExpenseBloc() : super(const ExpenseLoaded([])) {
    on<AddExpense>(_onAddExpense);
    on<DeleteExpense>(_onDeleteExpense);
    on<UpdateExpense>(_onUpdateExpense);
    on<LoadExpenses>(_onLoadExpenses);
    on<ClearAllExpenses>(_onClearAllExpenses);
    
    // Auto-load expenses on creation
    add(const LoadExpenses());
  }

  Future<void> _saveExpenses(List<Expense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = expenses.map((e) => e.toMap()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  Future<List<Expense>> _loadExpensesFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((e) => Expense.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<void> _onAddExpense(AddExpense event, Emitter<ExpenseState> emit) async {
    if (state is ExpenseLoaded) {
      final currentState = state as ExpenseLoaded;
      final updatedExpenses = List<Expense>.from(currentState.expenses)
        ..add(event.expense);
      emit(ExpenseLoaded(updatedExpenses));
      
      // Save to SharedPreferences
      await _saveExpenses(updatedExpenses);
    }
  }

  Future<void> _onDeleteExpense(DeleteExpense event, Emitter<ExpenseState> emit) async {
    if (state is ExpenseLoaded) {
      final currentState = state as ExpenseLoaded;
      final updatedExpenses = currentState.expenses
          .where((expense) => expense.id != event.expenseId)
          .toList();
      emit(ExpenseLoaded(updatedExpenses));
      
      // Save to SharedPreferences
      await _saveExpenses(updatedExpenses);
    }
  }

  Future<void> _onUpdateExpense(UpdateExpense event, Emitter<ExpenseState> emit) async {
    if (state is ExpenseLoaded) {
      final currentState = state as ExpenseLoaded;
      final updatedExpenses = currentState.expenses.map((expense) {
        return expense.id == event.expense.id ? event.expense : expense;
      }).toList();
      emit(ExpenseLoaded(updatedExpenses));
      
      // Save to SharedPreferences
      await _saveExpenses(updatedExpenses);
    }
  }

  Future<void> _onLoadExpenses(LoadExpenses event, Emitter<ExpenseState> emit) async {
    emit(const ExpenseLoading());
    try {
      // Load from SharedPreferences
      final expenses = await _loadExpensesFromStorage();
      emit(ExpenseLoaded(expenses));
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> _onClearAllExpenses(ClearAllExpenses event, Emitter<ExpenseState> emit) async {
    emit(const ExpenseLoaded([]));
    // Clear from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  // Helper method to call from UI
  void clearAllExpenses() {
    add(ClearAllExpenses());
  }
}



