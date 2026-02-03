import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/voice_to_server_service.dart';
import '../../features/home/bloc/expense_bloc.dart';
import '../../features/home/bloc/expense_event.dart';
import '../../core/models/expense.dart';

/// Voice to Server Dialog - يرسل الصوت مباشرة للسيرفر
/// يدعم العربي والإنجليزي عن طريق السيرفر بتاعك
class VoiceToServerDialog extends StatefulWidget {
  const VoiceToServerDialog({super.key});

  @override
  State<VoiceToServerDialog> createState() => _VoiceToServerDialogState();
}

enum VoiceState { idle, recording, processing, success, error }

class _VoiceToServerDialogState extends State<VoiceToServerDialog>
    with TickerProviderStateMixin {
  VoiceState _currentState = VoiceState.idle;
  String _statusMessage = '';
  String _transcribedText = '';
  
  final VoiceToServerService _voiceService = VoiceToServerService();
  
  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  
  // Animations
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setState(VoiceState.idle);
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _voiceService.dispose();
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _setState(VoiceState newState) {
    if (mounted) {
      setState(() {
        _currentState = newState;
      });
      
      // Handle animations
      switch (newState) {
        case VoiceState.recording:
          _pulseController.repeat(reverse: true);
          break;
        case VoiceState.processing:
        case VoiceState.success:
        case VoiceState.error:
        case VoiceState.idle:
          _pulseController.stop();
          break;
      }
    }
  }

  String _getStateText() {
    switch (_currentState) {
      case VoiceState.idle:
        return '🎤 اضغط للتسجيل (عربي وإنجليزي)';
      case VoiceState.recording:
        return '🔴 جاري التسجيل... (اضغط لإيقاف)';
      case VoiceState.processing:
        return '📡 جاري إرسال الصوت للسيرفر وتحليله...';
      case VoiceState.success:
        return '✅ تم تحليل الصوت بنجاح!';
      case VoiceState.error:
        return '❌ حدث خطأ، جرب مرة أخرى';
    }
  }

  Color _getStateColor() {
    switch (_currentState) {
      case VoiceState.recording:
        return Colors.red;
      case VoiceState.processing:
        return Colors.blue;
      case VoiceState.success:
        return Colors.green;
      case VoiceState.error:
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  IconData _getStateIcon() {
    switch (_currentState) {
      case VoiceState.recording:
        return Icons.stop;
      case VoiceState.processing:
        return Icons.cloud_upload;
      case VoiceState.success:
        return Icons.check;
      case VoiceState.error:
        return Icons.refresh;
      default:
        return Icons.mic;
    }
  }

  Future<void> _toggleRecording() async {
    HapticFeedback.mediumImpact();
    
    if (_currentState == VoiceState.recording) {
      await _stopRecording();
    } else if (_currentState == VoiceState.idle || _currentState == VoiceState.error) {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    _setState(VoiceState.recording);
    setState(() {
      _statusMessage = 'اتكلم بالعربي أو الإنجليزي...';
      _transcribedText = '';
    });
    
    final success = await _voiceService.startRecording();
    if (!success) {
      setState(() {
        _statusMessage = 'فشل في بدء التسجيل. تحقق من إذن الميكروفون.';
      });
      _setState(VoiceState.error);
    }
  }

  Future<void> _stopRecording() async {
    _setState(VoiceState.processing);
    setState(() {
      _statusMessage = 'جاري إرسال الصوت للسيرفر...';
    });
    
    try {
      final result = await _voiceService.stopRecordingAndSend();
      
      if (!mounted) return;
      
      if (result != null && result['success'] == true) {
        // استخراج النص المحول
        final transcription = result['data']?['transcription'] as String? ?? '';
        
        setState(() {
          _transcribedText = transcription;
          _statusMessage = 'تم تحويل الصوت لنص بنجاح!';
        });
        
        // استخراج المعاملات المالية
        final analysisData = result['data']?['analysis'];
        if (analysisData != null) {
          final transactions = analysisData['transactions'];
          if (transactions != null && transactions.isNotEmpty) {
            await _processTransactions(transactions);
            return;
          }
        }
        
        _setState(VoiceState.success);
        
      } else {
        setState(() {
          _statusMessage = 'فشل في تحليل الصوت. جرب مرة أخرى.';
        });
        _setState(VoiceState.error);
      }
      
    } catch (e) {
      print('❌ خطأ في معالجة الصوت: $e');
      if (mounted) {
        setState(() {
          _statusMessage = 'حدث خطأ في الاتصال بالسيرفر.';
        });
        _setState(VoiceState.error);
      }
    }
  }

  Future<void> _processTransactions(List<dynamic> transactions) async {
    try {
      for (final transaction in transactions) {
        final amount = (transaction['amount'] as num?)?.toDouble() ?? 0.0;
        final category = transaction['category'] as String? ?? 'other';
        final item = transaction['item'] as String? ?? 'Unknown';
        final quantity = (transaction['quantity'] as num?)?.toInt() ?? 1;
        
        if (amount > 0) {
          final expense = Expense(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            amount: amount,
            category: category,
            title: item,
            date: DateTime.now(),
            isVoiceInput: true,
            quantity: quantity,
          );
          
          if (mounted && context.mounted) {
            try {
              context.read<ExpenseBloc>().add(AddExpense(expense));
              print('✅ تم إضافة المصروف: ${expense.title}');
            } catch (e) {
              print('⚠️ لا يمكن إضافة للـ ExpenseBloc: $e');
            }
          }
        }
      }
      
      if (mounted) {
        _setState(VoiceState.success);
        setState(() {
          _statusMessage = 'تم إضافة ${transactions.length} معاملة بنجاح!';
        });
        
        // إغلاق الـ dialog بعد ثانيتين
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context, _transcribedText);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ تم تحليل وإضافة ${transactions.length} معاملة من الصوت'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        });
      }
      
    } catch (e) {
      print('❌ خطأ في معالجة المعاملات: $e');
      if (mounted) {
        setState(() {
          _statusMessage = 'تم تحويل الصوت لكن فشل في إضافة المعاملات.';
        });
        _setState(VoiceState.error);
      }
    }
  }

  void _resetDialog() {
    HapticFeedback.lightImpact();
    setState(() {
      _transcribedText = '';
      _statusMessage = '';
    });
    _setState(VoiceState.idle);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Voice to Server',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStateColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getStateColor().withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    _getStateText(),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _getStateColor(),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_statusMessage.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      _statusMessage,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Voice Button
            GestureDetector(
              onTapDown: (_) => _scaleController.forward(),
              onTapUp: (_) => _scaleController.reverse(),
              onTapCancel: () => _scaleController.reverse(),
              onTap: _currentState != VoiceState.processing ? _toggleRecording : null,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 120 * (_currentState == VoiceState.recording ? _pulseAnimation.value : 1.0),
                      height: 120 * (_currentState == VoiceState.recording ? _pulseAnimation.value : 1.0),
                      decoration: BoxDecoration(
                        color: _getStateColor(),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _getStateColor().withValues(alpha: 0.3),
                            blurRadius: _currentState == VoiceState.recording ? 30 : 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: _currentState == VoiceState.processing
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : Icon(
                              _getStateIcon(),
                              color: Colors.white,
                              size: 50,
                            ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Transcribed Text
            if (_transcribedText.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'النص المحول:',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _transcribedText,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.green[800],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Action Buttons
            if (_currentState == VoiceState.success || _currentState == VoiceState.error) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _resetDialog,
                      child: const Text('تسجيل جديد'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, _transcribedText),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('إغلاق'),
                    ),
                  ),
                ],
              ),
            ],

            // Instructions
            if (_currentState == VoiceState.idle) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'تعليمات:\n'
                  '• اضغط على الميكروفون لبدء التسجيل\n'
                  '• تكلم بالعربي أو الإنجليزي\n'
                  '• اضغط مرة أخرى لإيقاف التسجيل\n'
                  '• سيتم إرسال الصوت للسيرفر للتحليل',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.blue[700],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Show Voice to Server Dialog
Future<String?> showVoiceToServerDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (context) => const VoiceToServerDialog(),
  );
}