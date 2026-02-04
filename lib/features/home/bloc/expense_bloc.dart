import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/expense.dart';
import '../../../services/shared_database_service.dart';
import '../../../core/storage/simple_storage.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  static const String _storageKey = 'expenses_data';
  final SharedDatabaseService _sharedDB = SharedDatabaseService();
  final SimpleStorage _storage = SimpleStorage();
  
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
    final jsonList = expenses.map((e) => e.toMap()).toList();
    await _storage.write(_storageKey, jsonEncode(jsonList));
  }

  Future<List<Expense>> _loadExpensesFromStorage() async {
    final jsonString = await _storage.read(_storageKey);
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
      
      // Update UI immediately (optimistic update)
      emit(ExpenseLoaded(updatedExpenses));
      
      // Save to backend database FIRST (for backend team to see)
      try {
        final success = await _sharedDB.addExpenseToSharedDB(event.expense);
        if (success) {
          print('✅ تم حفظ المصروف في سيرفر الباك اند: ${event.expense.title}');
          print('📊 الباك اند team يقدروا يشوفوا البيانات دلوقتي في الداتا بيز');
        } else {
          print('❌ فشل في حفظ المصروف في سيرفر الباك اند: ${event.expense.title}');
        }
      } catch (e) {
        print('❌ خطأ في حفظ المصروف في سيرفر الباك اند: $e');
      }
      
      // Save locally as backup
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
      
      // Save to secure storage
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
      
      // Save to secure storage
      await _saveExpenses(updatedExpenses);
    }
  }

  Future<void> _onLoadExpenses(LoadExpenses event, Emitter<ExpenseState> emit) async {
    emit(const ExpenseLoading());
    try {
      // Load from shared database first (to get latest data from all users)
      List<Expense> expenses = [];
      
      try {
        expenses = await _sharedDB.getAllExpensesFromSharedDB();
        if (expenses.isNotEmpty) {
          print('✅ تم جلب ${expenses.length} مصروف من الداتا بيز المشتركة');
          // Save to local storage as backup
          await _saveExpenses(expenses);
        } else {
          print('📭 لا توجد مصاريف في الداتا بيز المشتركة، جاري الجلب محلياً');
          // Fallback to local storage if no data in shared database
          expenses = await _loadExpensesFromStorage();
        }
      } catch (e) {
        print('⚠️ فشل في جلب البيانات من الداتا بيز المشتركة، جاري الجلب محلياً: $e');
        // Fallback to local storage if shared database fails
        expenses = await _loadExpensesFromStorage();
      }
      
      emit(ExpenseLoaded(expenses));
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> _onClearAllExpenses(ClearAllExpenses event, Emitter<ExpenseState> emit) async {
    emit(const ExpenseLoaded([]));
    // Clear from secure storage
    await _storage.delete(_storageKey);
  }

  // Helper method to refresh expenses from shared database
  void refreshExpenses() {
    add(const LoadExpenses());
  }

  // Helper method to call from UI
  void clearAllExpenses() {
    add(ClearAllExpenses());
  }
}



