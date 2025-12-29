// AI API Service - خدمة الذكاء الاصطناعي
// Handles AI analysis API calls (text, voice, OCR)

import 'dart:io';
import 'api_service.dart';

class AiApiService {
  static final AiApiService instance = AiApiService._internal();
  AiApiService._internal();
  factory AiApiService() => instance;

  final ApiService _api = ApiService();

  // Analyze text for financial data extraction
  Future<AiAnalysisResult> analyzeText(String text) async {
    final response = await _api.postMultipart(
      '/ai/analyze',
      fields: {'text': text},
    );

    if (response.isSuccess) {
      final analysisData = response.getData<List>('analysis') ?? [];
      final extractedText = response.getData<String>('text');

      final analyses = analysisData
          .map((item) => AiAnalysis.fromMap(item as Map<String, dynamic>))
          .toList();

      return AiAnalysisResult.success(
        analyses: analyses,
        extractedText: extractedText,
        message: response.message,
      );
    }

    return AiAnalysisResult.failure(message: response.message ?? 'Failed to analyze text');
  }

  // Analyze image (OCR) for financial data extraction
  Future<AiAnalysisResult> analyzeImage(File imageFile) async {
    final response = await _api.postMultipart(
      '/ai/analyze',
      files: {'OCR_path': imageFile},
    );

    if (response.isSuccess) {
      final analysisData = response.getData<List>('analysis') ?? [];
      final extractedText = response.getData<String>('text');

      final analyses = analysisData
          .map((item) => AiAnalysis.fromMap(item as Map<String, dynamic>))
          .toList();

      return AiAnalysisResult.success(
        analyses: analyses,
        extractedText: extractedText,
        message: response.message,
      );
    }

    return AiAnalysisResult.failure(message: response.message ?? 'Failed to analyze image');
  }

  // Analyze voice for financial data extraction
  Future<AiAnalysisResult> analyzeVoice(File voiceFile) async {
    final response = await _api.postMultipart(
      '/ai/voice',
      files: {'voice_path': voiceFile},
    );

    if (response.isSuccess) {
      final analysisData = response.getData<List>('analysis') ?? [];
      final extractedText = response.getData<String>('text');

      final analyses = analysisData
          .map((item) => AiAnalysis.fromMap(item as Map<String, dynamic>))
          .toList();

      return AiAnalysisResult.success(
        analyses: analyses,
        extractedText: extractedText,
        message: response.message,
      );
    }

    return AiAnalysisResult.failure(message: response.message ?? 'Failed to analyze voice');
  }
}

// AI Analysis model
class AiAnalysis {
  final double amount;
  final String category;
  final String? place;
  final String type; // 'expense' or 'income'

  AiAnalysis({
    required this.amount,
    required this.category,
    this.place,
    required this.type,
  });

  factory AiAnalysis.fromMap(Map<String, dynamic> map) {
    return AiAnalysis(
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      category: map['category'] ?? 'other',
      place: map['place'],
      type: map['type'] ?? 'expense',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'category': category,
      'place': place,
      'type': type,
    };
  }

  // Aliases for UI compatibility
  double get price => amount;
  String get item => place ?? category;

  bool get isExpense => type == 'expense';
  bool get isIncome => type == 'income';
}

// AI Analysis Result
class AiAnalysisResult {
  final bool isSuccess;
  final List<AiAnalysis> analyses;
  final String? extractedText;
  final String? message;

  AiAnalysisResult._({
    required this.isSuccess,
    this.analyses = const [],
    this.extractedText,
    this.message,
  });

  factory AiAnalysisResult.success({
    required List<AiAnalysis> analyses,
    String? extractedText,
    String? message,
  }) {
    return AiAnalysisResult._(
      isSuccess: true,
      analyses: analyses,
      extractedText: extractedText,
      message: message,
    );
  }

  factory AiAnalysisResult.failure({required String message}) {
    return AiAnalysisResult._(
      isSuccess: false,
      message: message,
    );
  }

  // Get first analysis (most common use case)
  AiAnalysis? get firstAnalysis => analyses.isNotEmpty ? analyses.first : null;

  // Get total amount from all analyses
  double get totalAmount => analyses.fold(0, (sum, a) => sum + a.amount);
}
