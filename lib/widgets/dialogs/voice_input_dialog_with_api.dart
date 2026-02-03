import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/voice_api_service.dart';
import '../../features/home/bloc/expense_bloc.dart';
import '../../features/home/bloc/expense_event.dart';
import '../../core/models/expense.dart';

/// Voice Input Dialog with API Integration
/// يستخدم الـ Voice البسيط الشغال + الـ APIs بتوعك بدون تعديل
class VoiceInputDialogWithAPI extends StatefulWidget {
  const VoiceInputDialogWithAPI({super.key});

  @override
  State<VoiceInputDialogWithAPI> createState() => _VoiceInputDialogWithAPIState();
}

enum VoiceState { idle, listening, processing, success, error }

class _VoiceInputDialogWithAPIState extends State<VoiceInputDialogWithAPI> {
  VoiceState _currentState = VoiceState.idle;
  String _recognizedText = '';
  String _errorMessage = '';
  String _statusMessage = '';
  
  final SpeechToText _speech = SpeechToText();
  final VoiceApiService _apiService = VoiceApiService();
  final TextEditingController _textController = TextEditingController();
  bool _isListening = false;

  @override
  void dispose() {
    if (_isListening) {
      _speech.stop();
    }
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
        return '🔄 جاري إرسال للـ API وتحليل النص...';
      case VoiceState.success:
        return '✅ تم التحليل بنجاح!';
      case VoiceState.error:
        return '❌ جرب الكتابة اليدوية أو الأمثلة أدناه';
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
    
    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    // طلب إذن الميكروفون
    final permission = await Permission.microphone.request();
    if (permission != PermissionStatus.granted) {
      setState(() {
        _errorMessage = 'مطلوب إذن الميكروفون';
        _statusMessage = 'يرجى تفعيل إذن الميكروفون من الإعدادات';
      });
      _setState(VoiceState.error);
      return;
    }

    // تهيئة التعرف على الكلام
    final available = await _speech.initialize(
      onError: (error) {
        print('❌ خطأ في الصوت: ${error.errorMsg}');
        if (mounted) {
          setState(() {
            _errorMessage = 'مشكلة في الميكروفون: ${error.errorMsg}';
            _statusMessage = 'جرب الكتابة اليدوية أدناه';
          });
          _setState(VoiceState.error);
        }
      },
      onStatus: (status) {
        print('📊 حالة الصوت: $status');
        if (mounted) {
          if (status == 'listening') {
            setState(() {
              _statusMessage = '🎤 أتكلم الآن...';
            });
          } else if (status == 'notListening' || status == 'done') {
            setState(() {
              _isListening = false;
            });
            if (_recognizedText.isNotEmpty) {
              _setState(VoiceState.success);
            } else {
              _setState(VoiceState.idle);
            }
          }
        }
      },
    );

    if (!available) {
      setState(() {
        _errorMessage = 'التعرف على الكلام غير متاح على هذا الجهاز';
        _statusMessage = 'استخدم الكتابة اليدوية أو الأمثلة أدناه';
      });
      _setState(VoiceState.error);
      return;
    }

    // بدء الاستماع
    try {
      await _speech.listen(
        onResult: (result) {
          final text = result.recognizedWords.trim();
          print('🎤 سمعت: "$text" (ثقة: ${result.confidence})');
          
          if (mounted && text.isNotEmpty) {
            setState(() {
              _recognizedText = text;
              _textController.text = text;
            });
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: false,
        listenMode: ListenMode.dictation,
      );

      setState(() {
        _isListening = true;
        _errorMessage = '';
        _statusMessage = '🎤 أتكلم الآن...';
      });
      _setState(VoiceState.listening);
      
    } catch (e) {
      print('❌ خطأ في بدء الاستماع: $e');
      setState(() {
        _errorMessage = 'فشل في بدء التسجيل';
        _statusMessage = 'جرب الكتابة اليدوية أدناه';
      });
      _setState(VoiceState.error);
    }
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
    });
    
    if (_recognizedText.isNotEmpty) {
      _setState(VoiceState.success);
      setState(() {
        _statusMessage = '✅ تم سماع النص بنجاح';
      });
    } else {
      _setState(VoiceState.idle);
      setState(() {
        _statusMessage = 'لم يتم سماع أي نص';
      });
    }
  }

  Future<void> _processWithAPI() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _currentState == VoiceState.processing) return;
    
    _setState(VoiceState.processing);
    setState(() {
      _statusMessage = '🔄 جاري إرسال للـ API: "$text"';
    });
    
    try {
      print('🔄 إرسال للـ API: "$text"');
      
      // استخدام الـ API بتاعك بدون أي تعديل
      final result = await _apiService.analyzeText(text);
      
      if (!mounted) return;
      
      print('📥 استجابة الـ API: ${result.data}');
      
      if (result.isSuccess && result.data != null) {
        final data = result.data!;
        
        // استخدام النتيجة كما هي من الـ API بدون تعديل
        if (data['success'] == true) {
          final analysisData = data['data']?['analysis'];
          if (analysisData != null) {
            final transactions = analysisData['transactions'];
            if (transactions != null && transactions.isNotEmpty) {
              final transaction = transactions[0];
              
              // أخذ البيانات كما هي من الـ API
              final amount = (transaction['amount'] as num?)?.toDouble() ?? 0.0;
              final category = transaction['category'] as String? ?? 'other';
              final item = transaction['item'] as String? ?? 'Unknown';
              final quantity = (transaction['quantity'] as num?)?.toInt() ?? 1;
              
              print('📊 تحليل الـ API: $item, $amount, $category, quantity: $quantity');
              
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
                
                // إضافة للـ ExpenseBloc
                if (mounted && context.mounted) {
                  try {
                    context.read<ExpenseBloc>().add(AddExpense(expense));
                    print('✅ تم إضافة المصروف: ${expense.title}');
                  } catch (e) {
                    print('⚠️ لا يمكن إضافة للـ ExpenseBloc: $e');
                  }
                }
                
                if (mounted) {
                  Navigator.pop(context, text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '✅ تم التحليل والإضافة:\n'
                        '${quantity}x $item - ${amount.toStringAsFixed(0)} جنيه\n'
                        'الفئة: $category'
                      ),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
                return;
              }
            }
          }
        }
      }
      
      // إذا فشل التحليل، أرسل النص كما هو
      if (mounted) {
        Navigator.pop(context, text);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎤 تم إرسال النص: $text\n(لم يتم التحليل بواسطة الـ API)'),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      
    } catch (e) {
      print('❌ خطأ في الـ API: $e');
      if (mounted) {
        Navigator.pop(context, text);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎤 تم إرسال النص: $text\n(خطأ في الـ API: $e)'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Voice + API',
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
                    hintText: 'النص المسموع سيظهر هنا أو اكتب يدوياً\nمثال: "اشتريت خبز بـ 5 جنيه"',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                  style: GoogleFonts.inter(fontSize: 14),
                  onChanged: (text) {
                    setState(() {
                      _recognizedText = text;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Quick examples
              if (_currentState == VoiceState.idle || _currentState == VoiceState.error) ...[
                Text(
                  'أمثلة سريعة (اضغط للاستخدام):',
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
                    'اشتريت دواء بـ 30 جنيه',
                  ].map((example) {
                    return GestureDetector(
                      onTap: () {
                        _textController.text = example;
                        setState(() {
                          _recognizedText = example;
                        });
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
                        onPressed: _currentState != VoiceState.processing ? _processWithAPI : null,
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
                            : const Text('تحليل وإضافة'),
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

/// Show Voice Input Dialog with API
Future<String?> showVoiceInputDialogWithAPI(BuildContext context) {
  return showDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (context) => const VoiceInputDialogWithAPI(),
  );
}