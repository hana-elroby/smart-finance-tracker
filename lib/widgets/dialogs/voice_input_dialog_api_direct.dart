import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../services/voice_api_direct_service.dart';
import '../../features/home/bloc/expense_bloc.dart';
import '../../features/home/bloc/expense_event.dart';
import '../../core/models/expense.dart';

/// Voice Input Dialog - يستخدم API المستخدم مباشرة
/// يدعم العربي والإنجليزي مع إدخال نصي كبديل
/// https://gradution-project-u39v.onrender.com
class VoiceInputDialogApiDirect extends StatefulWidget {
  const VoiceInputDialogApiDirect({super.key});

  @override
  State<VoiceInputDialogApiDirect> createState() => _VoiceInputDialogApiDirectState();
}

enum VoiceState { idle, listening, processing, success, error }

class _VoiceInputDialogApiDirectState extends State<VoiceInputDialogApiDirect>
    with TickerProviderStateMixin {
  VoiceState _currentState = VoiceState.idle;
  String _statusMessage = '';
  String _recognizedText = '';
  
  final TextEditingController _textController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechEnabled = false;
  
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
    _initializeSpeech();
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

  void _initializeSpeech() async {
    try {
      _speechEnabled = await _speech.initialize(
        onStatus: (status) {
          print('🎤 Speech status: $status');
          if (status == 'done' || status == 'notListening') {
            if (_currentState == VoiceState.listening) {
              _setState(VoiceState.idle);
            }
          }
        },
        onError: (error) {
          print('❌ Speech error: $error');
          setState(() {
            _statusMessage = 'مشكلة في التعرف على الصوت. استخدم الإدخال النصي.';
          });
          _setState(VoiceState.error);
        },
      );
      
      if (_speechEnabled) {
        print('✅ Speech recognition initialized');
      } else {
        print('❌ Speech recognition not available');
        setState(() {
          _statusMessage = 'التعرف على الصوت غير متاح. استخدم الإدخال النصي.';
        });
      }
    } catch (e) {
      print('❌ Speech initialization error: $e');
      setState(() {
        _statusMessage = 'مشكلة في تهيئة التعرف على الصوت. استخدم الإدخال النصي.';
      });
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _pulseController.dispose();
    _scaleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _setState(VoiceState newState) {
    if (mounted) {
      setState(() {
        _currentState = newState;
      });
      
      // Handle animations
      switch (newState) {
        case VoiceState.listening:
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
        return '🎤 اضغط للتسجيل أو اكتب النص';
      case VoiceState.listening:
        return '🔴 جاري الاستماع... (اضغط لإيقاف)';
      case VoiceState.processing:
        return '📡 جاري إرسال النص لسيرفرك وتحليله...';
      case VoiceState.success:
        return '✅ تم تحليل النص وإضافة المعاملات!';
      case VoiceState.error:
        return '❌ حدث خطأ، جرب مرة أخرى';
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
        return Icons.cloud_upload;
      case VoiceState.success:
        return Icons.check;
      case VoiceState.error:
        return Icons.refresh;
      default:
        return Icons.mic;
    }
  }

  Future<void> _toggleVoiceRecording() async {
    HapticFeedback.mediumImpact();
    
    if (_currentState == VoiceState.listening) {
      await _stopListening();
    } else if (_currentState == VoiceState.idle || _currentState == VoiceState.error) {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    if (!_speechEnabled) {
      setState(() {
        _statusMessage = 'التعرف على الصوت غير متاح. استخدم الإدخال النصي.';
      });
      return;
    }

    _setState(VoiceState.listening);
    setState(() {
      _statusMessage = 'اتكلم بالعربي أو الإنجليزي...';
      _recognizedText = '';
    });
    
    try {
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords;
            _textController.text = _recognizedText;
          });
        },
        listenFor: const Duration(minutes: 5),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: 'ar-EG', // Arabic first, but will fallback to English
        cancelOnError: false,
        listenMode: stt.ListenMode.confirmation,
      );
    } catch (e) {
      print('❌ خطأ في بدء الاستماع: $e');
      setState(() {
        _statusMessage = 'مشكلة في التعرف على الصوت. استخدم الإدخال النصي.';
      });
      _setState(VoiceState.error);
    }
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    _setState(VoiceState.idle);
    
    // If we have recognized text, process it
    if (_recognizedText.isNotEmpty) {
      await _processText(_recognizedText);
    }
  }

  Future<void> _processTextFromInput() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _statusMessage = 'يرجى إدخال النص أولاً';
      });
      return;
    }
    
    await _processText(text);
  }

  Future<void> _processText(String text) async {
    _setState(VoiceState.processing);
    setState(() {
      _statusMessage = 'جاري إرسال النص لسيرفرك...';
    });
    
    try {
      // استخدام API المستخدم مباشرة
      final result = await VoiceApiDirectService.analyzeText(text);
      
      if (!mounted) return;
      
      if (result != null && result['success'] == true) {
        // استخراج المعاملات
        final transactions = VoiceApiDirectService.extractTransactions(result);
        
        if (transactions.isNotEmpty) {
          await _addTransactionsToApp(transactions);
          return;
        } else {
          setState(() {
            _statusMessage = 'تم تحليل النص لكن لم يتم العثور على معاملات مالية.';
          });
          _setState(VoiceState.error);
        }
      } else {
        setState(() {
          _statusMessage = 'فشل في تحليل النص. تحقق من الاتصال بالإنترنت.';
        });
        _setState(VoiceState.error);
      }
      
    } catch (e) {
      print('❌ خطأ في معالجة النص: $e');
      if (mounted) {
        setState(() {
          _statusMessage = 'حدث خطأ في الاتصال بالسيرفر.';
        });
        _setState(VoiceState.error);
      }
    }
  }

  Future<void> _addTransactionsToApp(List<Map<String, dynamic>> transactions) async {
    try {
      for (final transaction in transactions) {
        final expense = Expense(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          amount: transaction['amount'],
          category: transaction['category'],
          title: transaction['item'],
          date: DateTime.now(),
          isVoiceInput: true,
          quantity: transaction['quantity'],
        );
        
        if (mounted && context.mounted) {
          try {
            context.read<ExpenseBloc>().add(AddExpense(expense));
            print('✅ تم إضافة المصروف: ${expense.title} (${expense.quantity}x)');
          } catch (e) {
            print('⚠️ لا يمكن إضافة للـ ExpenseBloc: $e');
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
            Navigator.pop(context, _textController.text);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ تم تحليل وإضافة ${transactions.length} معاملة'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        });
      }
      
    } catch (e) {
      print('❌ خطأ في إضافة المعاملات: $e');
      if (mounted) {
        setState(() {
          _statusMessage = 'تم تحليل النص لكن فشل في إضافة المعاملات.';
        });
        _setState(VoiceState.error);
      }
    }
  }

  void _resetDialog() {
    HapticFeedback.lightImpact();
    setState(() {
      _recognizedText = '';
      _statusMessage = '';
      _textController.clear();
    });
    _setState(VoiceState.idle);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Container(
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
                      'Voice + Text Input',
                      style: GoogleFonts.inter(
                        fontSize: 18,
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
                const SizedBox(height: 16),

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
                  onTap: _currentState != VoiceState.processing ? _toggleVoiceRecording : null,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 100 * (_currentState == VoiceState.listening ? _pulseAnimation.value : 1.0),
                          height: 100 * (_currentState == VoiceState.listening ? _pulseAnimation.value : 1.0),
                          decoration: BoxDecoration(
                            color: _getStateColor(),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _getStateColor().withValues(alpha: 0.3),
                                blurRadius: _currentState == VoiceState.listening ? 30 : 20,
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
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Text Input Field
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'أو اكتب النص مباشرة:',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _textController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'مثال: اشتريت خبز بخمسة جنيه\nI bought bread for 5 EGP',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.blue),
                          ),
                        ),
                        style: GoogleFonts.inter(fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _currentState != VoiceState.processing ? _processTextFromInput : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'تحليل النص',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Action Buttons
                if (_currentState == VoiceState.success || _currentState == VoiceState.error) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _resetDialog,
                          child: const Text('جرب مرة أخرى'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, _textController.text),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'طريقتان للاستخدام:',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '🎤 الصوت: اضغط على الميكروفون واتكلم\n'
                          '⌨️ النص: اكتب مباشرة في الحقل أعلاه\n'
                          '🌐 يستخدم سيرفرك: gradution-project-u39v.onrender.com\n'
                          '🔄 يدعم العربي والإنجليزي والفرانكو-عربي',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Show Voice Input Dialog with API Direct
Future<String?> showVoiceInputDialogApiDirect(BuildContext context) {
  return showDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (context) => const VoiceInputDialogApiDirect(),
  );
}