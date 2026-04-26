import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/expense.dart';
import '../../../core/services/transaction_api_service.dart';
import '../../../core/services/item_api_service.dart';
import '../../../core/services/category_api_service.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_api_service.dart';
import '../../../core/storage/simple_storage.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  static const String _storageKey = 'expenses_data';
  final SimpleStorage _storage = SimpleStorage();
  final TransactionApiService _transactionApi = TransactionApiService.instance;
  final ApiService _api = ApiService();

  ExpenseBloc() : super(const ExpenseLoaded([])) {
    on<AddExpense>(_onAddExpense);
    on<DeleteExpense>(_onDeleteExpense);
    on<UpdateExpense>(_onUpdateExpense);
    on<LoadExpenses>(_onLoadExpenses);
    on<ClearAllExpenses>(_onClearAllExpenses);

    // Auto-load on creation
    add(const LoadExpenses());
  }

  // ─── Persistence helpers ───────────────────────────────────────────────────

  Future<void> _saveLocal(List<Expense> expenses) async {
    final jsonList = expenses.map((e) => e.toMap()).toList();
    await _storage.write(_storageKey, jsonEncode(jsonList));
  }

  Future<List<Expense>> _loadLocal() async {
    final jsonString = await _storage.read(_storageKey);
    if (jsonString == null || jsonString.isEmpty) return [];
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList
        .map((e) => Expense.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Mirror a new expense into TransactionBloc's local storage
  /// so Transactions page shows it immediately
  Future<void> _mirrorToTransactions(Expense expense) async {
    try {
      const txKey = 'local_transactions';
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getString(txKey);
      final List list = existing != null ? jsonDecode(existing) as List : [];

      final txMap = {
        'id': expense.id,
        'title': expense.title,
        'description': expense.notes ?? '',
        'amount': expense.amount,
        'category': expense.category,
        'type': 'expense',
        'date': expense.date.toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Add at the beginning (newest first)
      list.insert(0, txMap);
      await prefs.setString(txKey, jsonEncode(list));
    } catch (e) {
      print('⚠️ Mirror to transactions failed: $e');
    }
  }

  /// Remove expense from TransactionBloc's local storage
  Future<void> _removeFromTransactions(String expenseId) async {
    try {
      const txKey = 'local_transactions';
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getString(txKey);
      if (existing == null) return;
      final list = jsonDecode(existing) as List;
      list.removeWhere((e) => e['id'] == expenseId);
      await prefs.setString(txKey, jsonEncode(list));
    } catch (_) {}
  }

  // ─── Event handlers ────────────────────────────────────────────────────────

  Future<void> _onAddExpense(
      AddExpense event, Emitter<ExpenseState> emit) async {
    if (state is! ExpenseLoaded) return;
    final current = state as ExpenseLoaded;

    // Optimistic update — show immediately in UI
    final updated = List<Expense>.from(current.expenses)..add(event.expense);
    emit(ExpenseLoaded(updated));
    await _saveLocal(updated);

    // Mirror to TransactionBloc storage so Transactions page sees it
    await _mirrorToTransactions(event.expense);

    // Send to backend if logged in
    final isLoggedIn = await AuthApiService.instance.isAuthenticated();
    if (!isLoggedIn) return;

    try {
      // Step 1: Find or create category on backend first
      final categoryResult = await CategoryApiService.instance.getCategories();
      String? categoryId;
      if (categoryResult.isSuccess) {
        final match = categoryResult.categories
            .where((c) => c.name.toLowerCase() == event.expense.category.toLowerCase())
            .firstOrNull;
        categoryId = match?.id;
      }

      // Create category if not found
      if (categoryId == null) {
        final newCat = await CategoryApiService.instance.createCategory(
          name: event.expense.category,
          icon: 'category',
          color: '#1976D2',
        );
        if (newCat.isSuccess && newCat.category != null) {
          categoryId = newCat.category!.id;
          print('✅ New category created: ${event.expense.category}');
        }
      }

      if (categoryId == null) {
        print('⚠️ Could not find or create category');
        return;
      }

      // Step 2: Create item linked to category
      final itemResult = await ItemApiService.instance.createItem(
        name: event.expense.title,
        categoryId: categoryId,
        price: event.expense.amount,
      );

      if (!itemResult.isSuccess || itemResult.item == null) {
        print('⚠️ Failed to create item: ${itemResult.message}');
        return;
      }

      final itemId = itemResult.item!.id;
      print('✅ Item created: ${event.expense.title} (id: $itemId)');

      final body = {
        'text': event.expense.title,
        'price': event.expense.amount,
        'categoryId': categoryId,   // direct category reference
        'items': [itemId],          // plain string IDs
      };

      print('🚀 Sending transaction body: ${jsonEncode(body)}');
      final result = await _api.post('/transactions/createWithText', body: body);
      if (result.isSuccess) {
        print('✅ Transaction synced to backend: ${event.expense.title}');
        // Refresh from backend so UI shows the saved data
        add(const LoadExpenses());
      } else {
        print('⚠️ Transaction sync failed: ${result.message}');
      }
    } catch (e) {
      print('⚠️ Backend sync error: $e');
    }
  }

  Future<void> _onDeleteExpense(
      DeleteExpense event, Emitter<ExpenseState> emit) async {
    if (state is! ExpenseLoaded) return;
    final current = state as ExpenseLoaded;

    final updated =
        current.expenses.where((e) => e.id != event.expenseId).toList();
    emit(ExpenseLoaded(updated));
    await _saveLocal(updated);

    // Remove from TransactionBloc storage too
    await _removeFromTransactions(event.expenseId);

    // Delete from backend if logged in
    final isLoggedIn = await AuthApiService.instance.isAuthenticated();
    if (!isLoggedIn) return;

    // Use syncId (backend _id) if available, otherwise skip
    // The Expense model doesn't have syncId yet — we'll use the local id as fallback
    try {
      final result = await _transactionApi.deleteTransaction(event.expenseId);
      if (result.isSuccess) {
        print('✅ Expense deleted from backend: ${event.expenseId}');
      } else {
        print('⚠️ Backend delete failed (may not exist on backend): ${result.message}');
      }
    } catch (e) {
      print('⚠️ Backend delete error: $e');
    }
  }

  Future<void> _onUpdateExpense(
      UpdateExpense event, Emitter<ExpenseState> emit) async {
    if (state is! ExpenseLoaded) return;
    final current = state as ExpenseLoaded;
    final updated = current.expenses
        .map((e) => e.id == event.expense.id ? event.expense : e)
        .toList();
    emit(ExpenseLoaded(updated));
    await _saveLocal(updated);
  }

  Future<void> _onLoadExpenses(
      LoadExpenses event, Emitter<ExpenseState> emit) async {
    emit(const ExpenseLoading());

    try {
      final isLoggedIn = await AuthApiService.instance.isAuthenticated();

      if (isLoggedIn) {
        // Try to load from backend first
        try {
          final result = await _transactionApi.getMyTransactions(limit: 100);
          print('📡 Backend response: success=${result.isSuccess}, count=${result.transactions.length}, msg=${result.message}');
          if (result.isSuccess && result.transactions.isNotEmpty) {
            // Convert backend TransactionModel → local Expense
            final expenses = result.transactions.map((t) {
              return Expense(
                id: t.id,
                title: t.displayText,
                amount: t.price,
                category: t.categoryName ?? 'Other',
                date: t.createdAt,
                isVoiceInput: t.type.name == 'voice',
              );
            }).toList();

            emit(ExpenseLoaded(expenses));
            await _saveLocal(expenses);
            print('✅ Loaded ${expenses.length} expenses from backend');
            return;
          }
        } catch (e) {
          print('⚠️ Backend load failed, falling back to local: $e');
        }
      }

      // Fallback to local storage
      final local = await _loadLocal();
      emit(ExpenseLoaded(local));
      print('📦 Loaded ${local.length} expenses from local storage');
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> _onClearAllExpenses(
      ClearAllExpenses event, Emitter<ExpenseState> emit) async {
    emit(const ExpenseLoaded([]));
    await _storage.delete(_storageKey);
  }

  void refreshExpenses() => add(const LoadExpenses());
  void clearAllExpenses() => add(ClearAllExpenses());
}
