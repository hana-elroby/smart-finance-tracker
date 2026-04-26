import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'transaction_event.dart';
import 'transaction_state.dart';
import '../models/transaction_model.dart';
import '../../../core/services/transaction_api_service.dart';
import '../../../core/services/auth_api_service.dart';
import '../../../core/models/transaction_model.dart' as core;

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionApiService _service = TransactionApiService.instance;
  static const String _localKey = 'local_transactions';

  TransactionBloc() : super(const TransactionState()) {
    on<LoadTransactions>(_onLoad);
    on<DeleteTransaction>(_onDelete);
    on<AddTransaction>(_onAdd);
  }

  TransactionModel _convertCore(core.TransactionModel t) {
    return TransactionModel(
      id: t.id,
      title: t.displayText,
      description: t.categoryName ?? '',
      amount: t.price,
      category: t.categoryName ?? t.categoryId ?? '',
      type: 'expense',
      date: t.createdAt,
      createdAt: t.createdAt,
      updatedAt: t.updatedAt ?? t.createdAt,
    );
  }

  Future<List<TransactionModel>> _loadLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_localKey);
      if (json == null) return [];
      final list = jsonDecode(json) as List;
      return list
          .map((e) => TransactionModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveLocal(List<TransactionModel> transactions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _localKey,
        jsonEncode(transactions.map((t) => t.toMap()).toList()),
      );
    } catch (_) {}
  }

  Future<void> _onLoad(
      LoadTransactions event, Emitter<TransactionState> emit) async {
    // 1. Show local data immediately — no loading spinner wait
    final local = await _loadLocal();
    emit(state.copyWith(
      status: TransactionStatus.loaded,
      transactions: local,
    ));

    // 2. Try backend in background (won't block UI)
    final isLoggedIn = AuthApiService.instance.isLoggedIn;
    if (!isLoggedIn) return;

    try {
      final result = await _service.getMyTransactions();
      if (result.isSuccess && result.transactions.isNotEmpty) {
        final transactions = result.transactions.map(_convertCore).toList();
        await _saveLocal(transactions);
        emit(state.copyWith(
          status: TransactionStatus.loaded,
          transactions: transactions,
        ));
      }
    } catch (_) {
      // Backend unavailable — local data already shown, nothing to do
    }
  }

  Future<void> _onDelete(
      DeleteTransaction event, Emitter<TransactionState> emit) async {
    final updated =
        state.transactions.where((t) => t.id != event.transactionId).toList();
    await _saveLocal(updated);
    emit(state.copyWith(
        status: TransactionStatus.loaded, transactions: updated));

    if (AuthApiService.instance.isLoggedIn) {
      try {
        await _service.deleteTransaction(event.transactionId);
      } catch (_) {}
    }
  }

  Future<void> _onAdd(AddTransaction event, Emitter<TransactionState> emit) async {
    final newT = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: event.title,
      description: event.description,
      amount: event.amount,
      category: event.category,
      type: event.type,
      date: event.date,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final updated = [newT, ...state.transactions];
    await _saveLocal(updated);
    emit(state.copyWith(
        status: TransactionStatus.loaded, transactions: updated));

    if (AuthApiService.instance.isLoggedIn) {
      try {
        await _service.createWithText(
            text: event.title, price: event.amount);
      } catch (_) {}
    }
  }
}
