// Transaction Bloc - منطق المعاملات
// Handles all transaction-related business logic with API

import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/transaction_api_service.dart';
import '../../../../core/services/ai_api_service.dart';
import '../../../../core/models/transaction_model.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionApiService _transactionService = TransactionApiService();
  final AiApiService _aiService = AiApiService();

  TransactionBloc() : super(const TransactionState()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<LoadMoreTransactions>(_onLoadMoreTransactions);
    on<CreateTextTransaction>(_onCreateTextTransaction);
    on<CreateVoiceTransaction>(_onCreateVoiceTransaction);
    on<CreateOcrTransaction>(_onCreateOcrTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
    on<AnalyzeText>(_onAnalyzeText);
    on<AnalyzeVoice>(_onAnalyzeVoice);
    on<AnalyzeImage>(_onAnalyzeImage);
    on<ClearAnalysis>(_onClearAnalysis);
    on<SearchTransactions>(_onSearchTransactions);
  }

  // Load transactions
  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(status: TransactionStatus.loading));

    try {
      final result = await _transactionService.getTransactions(
        page: 1,
        limit: 20,
      );

      if (result.isSuccess) {
        emit(state.copyWith(
          status: TransactionStatus.loaded,
          transactions: result.transactions,
          currentPage: result.currentPage,
          totalPages: result.totalPages,
          totalCount: result.totalCount,
          hasMore: result.currentPage < result.totalPages,
        ));
      } else {
        emit(state.copyWith(
          status: TransactionStatus.error,
          errorMessage: result.message,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: TransactionStatus.error,
        errorMessage: 'Failed to load transactions: $e',
      ));
    }
  }

  // Load more transactions (pagination)
  Future<void> _onLoadMoreTransactions(
    LoadMoreTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    if (!state.hasMore || state.isLoadingMore) return;

    emit(state.copyWith(isLoadingMore: true));

    try {
      final result = await _transactionService.getTransactions(
        page: state.currentPage + 1,
        limit: 20,
        search: state.searchQuery,
      );

      if (result.isSuccess) {
        emit(state.copyWith(
          transactions: [...state.transactions, ...result.transactions],
          currentPage: result.currentPage,
          totalPages: result.totalPages,
          hasMore: result.currentPage < result.totalPages,
          isLoadingMore: false,
        ));
      } else {
        emit(state.copyWith(isLoadingMore: false));
      }
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  // Create text transaction
  Future<void> _onCreateTextTransaction(
    CreateTextTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(status: TransactionStatus.creating));

    try {
      final result = await _transactionService.createWithText(
        text: event.text,
        price: event.price,
        itemIds: event.categoryIds,
      );

      if (result.isSuccess && result.transaction != null) {
        emit(state.copyWith(
          status: TransactionStatus.loaded,
          transactions: [result.transaction!, ...state.transactions],
          successMessage: 'Transaction created successfully',
        ));
      } else {
        emit(state.copyWith(
          status: TransactionStatus.loaded,
          errorMessage: result.message,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: TransactionStatus.loaded,
        errorMessage: 'Failed to create transaction: $e',
      ));
    }
  }

  // Create voice transaction
  Future<void> _onCreateVoiceTransaction(
    CreateVoiceTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(status: TransactionStatus.creating));

    try {
      final result = await _transactionService.createWithVoice(
        voiceFile: event.voiceFile,
        price: event.price,
        itemIds: event.categoryIds,
      );

      if (result.isSuccess && result.transaction != null) {
        emit(state.copyWith(
          status: TransactionStatus.loaded,
          transactions: [result.transaction!, ...state.transactions],
          successMessage: 'Voice transaction created successfully',
        ));
      } else {
        emit(state.copyWith(
          status: TransactionStatus.loaded,
          errorMessage: result.message,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: TransactionStatus.loaded,
        errorMessage: 'Failed to create voice transaction: $e',
      ));
    }
  }

  // Create OCR transaction
  Future<void> _onCreateOcrTransaction(
    CreateOcrTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(status: TransactionStatus.creating));

    try {
      final result = await _transactionService.createWithOcr(
        imageFile: event.imageFile,
        price: event.price,
        itemIds: event.categoryIds,
      );

      if (result.isSuccess && result.transaction != null) {
        emit(state.copyWith(
          status: TransactionStatus.loaded,
          transactions: [result.transaction!, ...state.transactions],
          successMessage: 'Receipt scanned successfully',
        ));
      } else {
        emit(state.copyWith(
          status: TransactionStatus.loaded,
          errorMessage: result.message,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: TransactionStatus.loaded,
        errorMessage: 'Failed to scan receipt: $e',
      ));
    }
  }

  // Delete transaction
  Future<void> _onDeleteTransaction(
    DeleteTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      final result = await _transactionService.deleteTransaction(event.id);

      if (result.isSuccess) {
        emit(state.copyWith(
          transactions: state.transactions.where((t) => t.id != event.id).toList(),
          successMessage: 'Transaction deleted',
        ));
      } else {
        emit(state.copyWith(errorMessage: result.message));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to delete transaction: $e'));
    }
  }

  // Analyze text with AI
  Future<void> _onAnalyzeText(
    AnalyzeText event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(isAnalyzing: true));

    try {
      final result = await _aiService.analyzeText(event.text);

      if (result.isSuccess) {
        emit(state.copyWith(
          isAnalyzing: false,
          aiAnalyses: result.analyses,
          extractedText: result.extractedText,
        ));
      } else {
        emit(state.copyWith(
          isAnalyzing: false,
          errorMessage: result.message,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isAnalyzing: false,
        errorMessage: 'Failed to analyze text: $e',
      ));
    }
  }

  // Analyze voice with AI
  Future<void> _onAnalyzeVoice(
    AnalyzeVoice event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(isAnalyzing: true));

    try {
      final result = await _aiService.analyzeVoice(event.voiceFile);

      if (result.isSuccess) {
        emit(state.copyWith(
          isAnalyzing: false,
          aiAnalyses: result.analyses,
          extractedText: result.extractedText,
        ));
      } else {
        emit(state.copyWith(
          isAnalyzing: false,
          errorMessage: result.message,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isAnalyzing: false,
        errorMessage: 'Failed to analyze voice: $e',
      ));
    }
  }

  // Analyze image with AI
  Future<void> _onAnalyzeImage(
    AnalyzeImage event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(isAnalyzing: true));

    try {
      final result = await _aiService.analyzeImage(event.imageFile);

      if (result.isSuccess) {
        emit(state.copyWith(
          isAnalyzing: false,
          aiAnalyses: result.analyses,
          extractedText: result.extractedText,
        ));
      } else {
        emit(state.copyWith(
          isAnalyzing: false,
          errorMessage: result.message,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isAnalyzing: false,
        errorMessage: 'Failed to analyze image: $e',
      ));
    }
  }

  // Clear AI analysis
  void _onClearAnalysis(ClearAnalysis event, Emitter<TransactionState> emit) {
    emit(state.copyWith(
      aiAnalyses: [],
      extractedText: null,
    ));
  }

  // Search transactions
  Future<void> _onSearchTransactions(
    SearchTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(
      status: TransactionStatus.loading,
      searchQuery: event.query,
    ));

    try {
      final result = await _transactionService.getTransactions(
        page: 1,
        limit: 20,
        search: event.query.isEmpty ? null : event.query,
      );

      if (result.isSuccess) {
        emit(state.copyWith(
          status: TransactionStatus.loaded,
          transactions: result.transactions,
          currentPage: result.currentPage,
          totalPages: result.totalPages,
          totalCount: result.totalCount,
          hasMore: result.currentPage < result.totalPages,
        ));
      } else {
        emit(state.copyWith(
          status: TransactionStatus.error,
          errorMessage: result.message,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: TransactionStatus.error,
        errorMessage: 'Search failed: $e',
      ));
    }
  }
}
