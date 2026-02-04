import 'package:flutter/material.dart';
import '../../services/voice_api_direct_service.dart';

/// Voice to Server Dialog - يرسل الصوت مباشرة للسيرفر
Future<String?> showVoiceToServerDialog(BuildContext context) async {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const VoiceToServerDialog(),
  );
}

class VoiceToServerDialog extends StatefulWidget {
  const VoiceToServerDialog({super.key});

  @override
  State<VoiceToServerDialog> createState() => _VoiceToServerDialogState();
}

class _VoiceToServerDialogState extends State<VoiceToServerDialog> {
  final VoiceApiDirectService _voiceService = VoiceApiDirectService();
  bool _isListening = false;
  bool _isProcessing = false;
  String _recognizedText = '';
  String _status = 'اضغط على المايك للبدء';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D5DB8).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.cloud_upload,
                    color: Color(0xFF0D5DB8),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'تسجيل صوتي',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isListening 
                  ? const Color(0xFF45F36B).withValues(alpha: 0.1)
                  : _isProcessing
                    ? const Color(0xFF00CCFF).withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isListening 
                    ? const Color(0xFF45F36B).withValues(alpha: 0.3)
                    : _isProcessing
                      ? const Color(0xFF00CCFF).withValues(alpha: 0.3)
                      : Colors.grey.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                _status,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: _isListening 
                    ? const Color(0xFF45F36B)
                    : _isProcessing
                      ? const Color(0xFF00CCFF)
                      : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Recognized Text
            if (_recognizedText.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: Text(
                  _recognizedText,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
            ],
            
            // Voice Button
            GestureDetector(
              onTap: _isProcessing ? null : _toggleListening,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _isListening
                      ? [const Color(0xFF45F36B), const Color(0xFF2ECC71)]
                      : _isProcessing
                        ? [const Color(0xFF00CCFF), const Color(0xFF0099CC)]
                        : [const Color(0xFF0D5DB8), const Color(0xFF1976D2)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_isListening 
                        ? const Color(0xFF45F36B) 
                        : const Color(0xFF0D5DB8)).withValues(alpha: 0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  _isListening 
                    ? Icons.stop 
                    : _isProcessing 
                      ? Icons.hourglass_empty 
                      : Icons.mic,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'إلغاء',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _recognizedText.isNotEmpty && !_isProcessing
                      ? () => Navigator.pop(context, _recognizedText)
                      : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D5DB8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'تأكيد',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _toggleListening() async {
    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    setState(() {
      _isListening = true;
      _status = 'جاري الاستماع... تحدث الآن';
      _recognizedText = '';
    });

    try {
      final result = await _voiceService.processVoiceInput();
      
      if (mounted) {
        setState(() {
          _isListening = false;
          _isProcessing = false;
          if (result != null && result.isNotEmpty) {
            _recognizedText = result;
            _status = 'تم التعرف على الصوت بنجاح';
          } else {
            _status = 'لم يتم التعرف على أي صوت';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isListening = false;
          _isProcessing = false;
          _status = 'خطأ في التسجيل: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _stopListening() async {
    setState(() {
      _isListening = false;
      _isProcessing = true;
      _status = 'جاري معالجة الصوت...';
    });
  }
}