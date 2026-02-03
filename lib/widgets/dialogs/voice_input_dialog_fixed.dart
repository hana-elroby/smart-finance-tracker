import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/voice_service_fixed.dart';
import '../../services/voice_api_service.dart';
import '../../features/home/bloc/expense_bloc.dart';
import '../../features/home/bloc/expense_event.dart';
import '../../core/models/expense.dart';

/// Fixed Voice Input Dialog - مبسط وفعال
class FixedVoiceInputDialog extends StatefulWidget {
  const FixedVoiceInputDialog({super.key});

  @override
  State<FixedVoiceInputDialog> createState() => _FixedVoiceInputDialogState();
}

enum VoiceState { idle, listening, processing, success, error }

class _FixedVoiceInputDialogState extends State<FixedVoiceInputDialog> {
  VoiceState _currentState = VoiceState.idle;
  String _recognizedText = '';
  String _errorMessage = '';
  double _soundLevel = 0.0;
  
  final FixedVoiceService _voiceService = FixedVoiceService();
  final VoiceApiService _apiService = VoiceApiService();
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _voiceService.stopListening();
    _textController.dispose();
    super.dispose();
  }

  void _setState(VoiceState newState) {
    if (mounted) {
      setState(() {
        _currentState = newState;
      });
    }
  }

  String _getStateText() {
    switch (_currentState) {
      case VoiceState.idle:
        return '🎤 اضغط للتسجيل أو اكتب يدوياً';
      case VoiceState.listening:
        return '🎤 أتكلم الآن... (اضغط لإيقاف)';
      case VoiceState.processing:
        return '🔄 جاري التحليل...';
      case VoiceState.success:
        return '✅ تم بنجاح!';
      case VoiceState.error:
        return '❌ جرب الكتابة اليدوية';
    }
  }

  Color _getStateColor() {
    switch (_currentState) {
      case VoiceState.listening:
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
      case VoiceState.listening:
        return Icons.stop;
      case VoiceState.processing:
        return Icons.psychology;
      case VoiceState.success:
        return Icons.check;
      case VoiceState.error:
        return Icons.refresh;
      default:
        return Icons.mic;
    }
  }

  Future<void> _toggleListening() async {
    HapticFeedback.mediumImpact();
    
    if (_currentState == VoiceState.listening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    _setState(VoiceState.listening);
    setState(() {
      _errorMessage = '';
      _recognizedText = '';
    });
    
    try {
      await _voiceService.startListening(
        onResult: (text) {
          print('🎤 تم سماع: "$text"');
          if (mounted && text.isNotEmpty) {
            setState(() {
              _recognizedText = text;
              _textController.text = text;
            });
          }
        },
        onError: (error) {
          print('❌ خطأ في الصوت: $error');
          if (mounted) {
            setState(() {
              _errorMessage = 'مشكلة في الميكروفون: $error\nجرب الكتابة اليدوية أدناه';
            });
            _setState(VoiceState.error);
          }
        },
        onSoundLevel: (level) {
          if (mounted) {
            setState(() {
              _soundLevel = level;
            });
          }
        },
      );
    } catch (e) {
      print('❌ خطأ في بدء الاستماع: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'فشل في بدء التسجيل: $e';
        });
        _setState(VoiceState.error);
      }
    }
  }

  Future<void> _stopListening() async {
    await _voiceService.stopListening();
    if (mounted) {
      if (_recognizedText.isNotEmpty) {
        _setState(VoiceState.success);
      } else {
        _setState(VoiceState.idle);
      }
    }
  }

  Future<void> _processAndAdd() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _currentState == VoiceState.processing) return;
    
    _setState(VoiceState.processing);
    
    try {
      print('🔄 تحليل النص: "$text"');
      
      final result = await _apiService.analyzeText(text);
      
      if (!mounted) return;
      
      if (result.isSuccess && result.data != null) {
        final data = result.data!;
        if (data['success'] == true) {
          final transactions = data['data']?['analysis']?['transactions'];
          if (transactions != null && transactions.isNotEmpty) {
            final transaction = transactions[0];
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
                } catch (e) {
                  print('⚠️ Could not add to bloc: $e');
                }
              }
              
              if (mounted) {
                Navigator.pop(context, text);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ تم إضافة: ${quantity}x $item - ${amount.toStringAsFixed(0)} جنيه'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
              return;
            }
          }
        }
      }
      
      // إذا فشل التحليل، أرسل النص كما هو
      if (mounted) {
        Navigator.pop(context, text);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎤 تم إرسال: $text'),
            backgroundColor: Colors.blue,
          ),
        );
      }
      
    } catch (e) {
      print('❌ خطأ في التحليل: $e');
      if (mounted) {
        Navigator.pop(context, text);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎤 تم إرسال: $text'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _resetInput() {
    HapticFeedback.lightImpact();
    setState(() {
      _recognizedText = '';
      _textController.clear();
      _errorMessage = '';
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Voice Input - Fixed',
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
                child: Text(
                  _getStateText(),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _getStateColor(),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              // Voice Button
              GestureDetector(
                onTap: _currentState != VoiceState.processing ? _toggleListening : null,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: _getStateColor(),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _getStateColor().withValues(alpha: 0.3),
                        blurRadius: 20,
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
                          size: 40,
                        ),
                ),
              ),
              
              // Sound level indicator
              if (_currentState == VoiceState.listening) ...[
                const SizedBox(height: 16),
                Text(
                  'مستوى الصوت: ${_soundLevel.toStringAsFixed(0)} dB',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
              
              const SizedBox(height: 20),

              // Error message
              if (_errorMessage.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _errorMessage,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.red[700],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Text input
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: _textController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(12),
                    hintText: 'اكتب هنا أو استخدم الميكروفون أعلاه\nمثال: "اشتريت خبز بـ 5 جنيه"',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                  style: GoogleFonts.inter(fontSize: 14),
                ),
              ),
              const SizedBox(height: 20),

              // Quick examples
              if (_currentState == VoiceState.idle || _currentState == VoiceState.error) ...[
                Text(
                  'أمثلة سريعة:',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[600],
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    'اشتريت خبز بـ 5 جنيه',
                    'دفعت 20 جنيه مواصلات',
                    'صرفت 50 جنيه على أكل',
                  ].map((example) {
                    return GestureDetector(
                      onTap: () {
                        _textController.text = example;
                        HapticFeedback.lightImpact();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          example,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              // Action buttons
              if (_textController.text.trim().isNotEmpty) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _resetInput,
                        child: const Text('مسح'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _currentState != VoiceState.processing ? _processAndAdd : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: _currentState == VoiceState.processing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('إضافة'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Show Fixed Voice Input Dialog
Future<String?> showFixedVoiceInputDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (context) => const FixedVoiceInputDialog(),
  );
}