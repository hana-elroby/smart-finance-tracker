// Export API Service - خدمة التصدير
// Handles exporting transactions to PDF, CSV, JSON

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'api_service.dart';

class ExportApiService {
  static final ExportApiService instance = ExportApiService._internal();
  ExportApiService._internal();
  factory ExportApiService() => instance;

  final ApiService _api = ApiService();

  // Export to PDF
  Future<ExportResult> exportToPdf({
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
  }) async {
    return _export('pdf', startDate: startDate, endDate: endDate, categoryId: categoryId);
  }

  // Export to CSV
  Future<ExportResult> exportToCsv({
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
  }) async {
    return _export('csv', startDate: startDate, endDate: endDate, categoryId: categoryId);
  }

  // Export to JSON
  Future<ExportResult> exportToJson({
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
  }) async {
    return _export('json', startDate: startDate, endDate: endDate, categoryId: categoryId);
  }

  // Generic export method
  Future<ExportResult> _export(
    String format, {
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String().split('T')[0];
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String().split('T')[0];
      if (categoryId != null) queryParams['categoryId'] = categoryId;

      final query = queryParams.isNotEmpty 
          ? '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}'
          : '';

      final response = await _api.getFile('/export/$format$query');

      if (response.isSuccess && response.fileBytes != null) {
        // Save file to downloads directory
        final directory = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'transactions_$timestamp.$format';
        final filePath = '${directory.path}/$fileName';
        
        final file = File(filePath);
        await file.writeAsBytes(response.fileBytes!);

        return ExportResult.success(
          filePath: filePath,
          fileName: fileName,
          message: 'Exported successfully',
        );
      }

      return ExportResult.failure(message: response.message ?? 'Export failed');
    } catch (e) {
      return ExportResult.failure(message: 'Export failed: $e');
    }
  }
}

// Export Result
class ExportResult {
  final bool isSuccess;
  final String? filePath;
  final String? fileName;
  final String? message;

  ExportResult._({
    required this.isSuccess,
    this.filePath,
    this.fileName,
    this.message,
  });

  factory ExportResult.success({
    required String filePath,
    required String fileName,
    String? message,
  }) {
    return ExportResult._(
      isSuccess: true,
      filePath: filePath,
      fileName: fileName,
      message: message,
    );
  }

  factory ExportResult.failure({required String message}) {
    return ExportResult._(isSuccess: false, message: message);
  }
}
