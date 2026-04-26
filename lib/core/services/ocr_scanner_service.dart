import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'transaction_api_service.dart';
import 'auth_api_service.dart';

/// OCR Scanner Service
/// Picks an image from camera or gallery and sends it to the backend
/// for receipt scanning via POST /transactions/createWithOCR
class OcrScannerService {
  static final OcrScannerService instance = OcrScannerService._internal();
  OcrScannerService._internal();
  factory OcrScannerService() => instance;

  final ImagePicker _picker = ImagePicker();

  /// Pick from camera and send to backend
  Future<OcrResult> scanFromCamera({double price = 0}) async {
    return _pickAndSend(ImageSource.camera, price: price);
  }

  /// Pick from gallery and send to backend
  Future<OcrResult> scanFromGallery({double price = 0}) async {
    return _pickAndSend(ImageSource.gallery, price: price);
  }

  Future<OcrResult> _pickAndSend(ImageSource source, {double price = 0}) async {
    try {
      // 1. Pick image
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (picked == null) {
        return OcrResult.cancelled();
      }

      final imageFile = File(picked.path);

      // 2. Check auth
      final isLoggedIn = await AuthApiService.instance.isAuthenticated();
      if (!isLoggedIn) {
        return OcrResult.failure(
          message: 'Please log in to scan receipts',
        );
      }

      // 3. Send to backend
      final result = await TransactionApiService.instance.createWithOcr(
        imageFile: imageFile,
        price: price,
      );

      if (result.isSuccess && result.transaction != null) {
        final t = result.transaction!;
        return OcrResult.success(
          transactionId: t.id,
          text: t.displayText,
          amount: t.price,
          category: t.categoryName,
        );
      }

      return OcrResult.failure(
        message: result.message ?? 'Failed to process receipt',
      );
    } catch (e) {
      return OcrResult.failure(message: 'Error: $e');
    }
  }
}

class OcrResult {
  final OcrStatus status;
  final String? transactionId;
  final String? text;
  final double? amount;
  final String? category;
  final String? message;

  OcrResult._({
    required this.status,
    this.transactionId,
    this.text,
    this.amount,
    this.category,
    this.message,
  });

  factory OcrResult.success({
    required String transactionId,
    required String text,
    required double amount,
    String? category,
  }) {
    return OcrResult._(
      status: OcrStatus.success,
      transactionId: transactionId,
      text: text,
      amount: amount,
      category: category,
    );
  }

  factory OcrResult.failure({required String message}) {
    return OcrResult._(status: OcrStatus.failure, message: message);
  }

  factory OcrResult.cancelled() {
    return OcrResult._(status: OcrStatus.cancelled);
  }

  bool get isSuccess => status == OcrStatus.success;
  bool get isCancelled => status == OcrStatus.cancelled;
}

enum OcrStatus { success, failure, cancelled }
