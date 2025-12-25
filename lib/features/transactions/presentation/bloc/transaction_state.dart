// Transaction State - حالات المعاملات
// States for transaction management

import 'package:equatable/equatable.dart';
import '../../../../core/models/transaction_model.dart';
import '../../../../core/services/ai_api_service.dart';

enum TransactionStatus {
  initial,
  loading,
  loaded,
  creating,
  error,
}

class TransactionState extends Equatable {
  final TransactionStatus status;
  final List<TransactionModel> transactions;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final bool hasMore;
  final bool isLoadingMore;
  final String? searchQuery;
  final bool isAnalyzing;
  final List<AiAnalysis> aiAnalyses;
  final String? extractedText;
  final String? errorMessage;
  final String? successMessage;

  const TransactionState({
    this.status = TransactionStatus.initial,
    this.transactions = const [],
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalCount = 0,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.searchQuery,
    this.isAnalyzing = false,
    this.aiAnalyses = const [],
    this.extractedText,
    this.errorMessage,
    this.successMessage,
  });

  TransactionState copyWith({
    TransactionStatus? status,
    List<TransactionModel>? transactions,
    int? currentPage,
    int? totalPages,
    int? totalCount,
    bool? hasMore,
    bool? isLoadingMore,
    String? searchQuery,
    bool? isAnalyzing,
    List<AiAnalysis>? aiAnalyses,
    String? extractedText,
    String? errorMessage,
    String? successMessage,
  }) {
    return TransactionState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchQuery: searchQuery,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      aiAnalyses: aiAnalyses ?? this.aiAnalyses,
      extractedText: extractedText,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  // Helper getters
  bool get isLoading => status == TransactionStatus.loading;
  bool get isCreating => status == TransactionStatus.creating;
  bool get hasTransactions => transactions.isNotEmpty;
  bool get hasAnalysis => aiAnalyses.isNotEmpty;

  // Get total amount from transactions
  double get totalAmount {
    return transactions.fold<double>(0, (sum, t) => sum + t.price);
  }

  // Get today's transactions
  List<TransactionModel> get todayTransactions {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return transactions.where((t) {
      final date = DateTime(t.createdAt.year, t.createdAt.month, t.createdAt.day);
      return date == today;
    }).toList();
  }

  // Get today's total
  double get todayTotal {
    return todayTransactions.fold<double>(0, (sum, t) => sum + t.price);
  }

  @override
  List<Object?> get props => [
        status,
        transactions,
        currentPage,
        totalPages,
        totalCount,
        hasMore,
        isLoadingMore,
        searchQuery,
        isAnalyzing,
        aiAnalyses,
        extractedText,
        errorMessage,
        successMessage,
      ];
}
