// Transaction Events - أحداث المعاملات
// Events for transaction management

import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

// Load transactions
class LoadTransactions extends TransactionEvent {
  const LoadTransactions();
}

// Load more transactions (pagination)
class LoadMoreTransactions extends TransactionEvent {
  const LoadMoreTransactions();
}

// Create transaction with text
class CreateTextTransaction extends TransactionEvent {
  final String text;
  final double price;
  final List<String>? categoryIds;

  const CreateTextTransaction({
    required this.text,
    required this.price,
    this.categoryIds,
  });

  @override
  List<Object?> get props => [text, price, categoryIds];
}

// Create transaction with voice
class CreateVoiceTransaction extends TransactionEvent {
  final File voiceFile;
  final double price;
  final List<String>? categoryIds;

  const CreateVoiceTransaction({
    required this.voiceFile,
    required this.price,
    this.categoryIds,
  });

  @override
  List<Object?> get props => [voiceFile, price, categoryIds];
}

// Create transaction with OCR (receipt image)
class CreateOcrTransaction extends TransactionEvent {
  final File imageFile;
  final double price;
  final List<String>? categoryIds;

  const CreateOcrTransaction({
    required this.imageFile,
    required this.price,
    this.categoryIds,
  });

  @override
  List<Object?> get props => [imageFile, price, categoryIds];
}

// Delete transaction
class DeleteTransaction extends TransactionEvent {
  final String id;

  const DeleteTransaction(this.id);

  @override
  List<Object?> get props => [id];
}

// Analyze text with AI
class AnalyzeText extends TransactionEvent {
  final String text;

  const AnalyzeText(this.text);

  @override
  List<Object?> get props => [text];
}

// Analyze voice with AI
class AnalyzeVoice extends TransactionEvent {
  final File voiceFile;

  const AnalyzeVoice(this.voiceFile);

  @override
  List<Object?> get props => [voiceFile];
}

// Analyze image with AI
class AnalyzeImage extends TransactionEvent {
  final File imageFile;

  const AnalyzeImage(this.imageFile);

  @override
  List<Object?> get props => [imageFile];
}

// Clear AI analysis
class ClearAnalysis extends TransactionEvent {
  const ClearAnalysis();
}

// Search transactions
class SearchTransactions extends TransactionEvent {
  final String query;

  const SearchTransactions(this.query);

  @override
  List<Object?> get props => [query];
}
