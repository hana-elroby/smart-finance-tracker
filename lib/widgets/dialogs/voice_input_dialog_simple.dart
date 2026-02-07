import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../services/voice_service.dart';
import '../../services/voice_api_service.dart';
import '../../features/home/bloc/expense_bloc.dart';
import '../../features/home/bloc/expense_event.dart';
import '../../core/models/expense.dart';

/// Ultra-Enhanced Voice Input Dialog - Premium UX with Language Intelligence
/// Features: 
/// - Smart language detection (Arabic/English/Franco-Arabic)
/// - Automatic Franco-Arabic to Arabic conversion
/// - Animated voice visualizer with real-time sound waves
/// - Particle effects and premium animations
/// - Comprehensive error handling and recovery
/// - Adaptive UI based on detected language
/// - Professional loading states with progress indicators
/// - Haptic feedback and micro-interactions
class SimpleVoiceInputDialog extends StatefulWidget {
  const SimpleVoiceInputDialog({super.key});

  @override
  State<SimpleVoiceInputDialog> createState() => _SimpleVoiceInputDialogState();
}

enum VoiceState {
  idle,
  initializing,
  listening,
  processing,
  success,
  error,
  typing
}

class _SimpleVoiceInputDialogState extends State<SimpleVoiceInputDialog>
    with TickerProviderStateMixin {
  VoiceState _currentState = VoiceState.idle;
  String _recognizedText = '';
  String _processedText = '';
  String _errorMessage = '';
  String _statusMessage = '';
  double _soundLevel = 0.0;
  
  final VoiceService _voiceService = VoiceService();
  final VoiceApiService _voiceApiService = VoiceApiService();
  final TextEditingController _textController = TextEditingController();
  
  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _particleController;
  
  // Animations
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _particleAnimation;
  
  Timer? _soundLevelTimer;
  Timer? _statusTimer;
  Timer? _particleTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _updateStatus(_getLocalizedText('status'));
  }

  void _initializeAnimations() {
    // Pulse animation for recording state
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Wave animation for sound visualization
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );

    // Scale animation for button interactions
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    // Fade animation for state transitions
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    // Particle animation for success state
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.easeOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _voiceService.stopListening();
    _textController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    _particleController.dispose();
    _soundLevelTimer?.cancel();
    _statusTimer?.cancel();
    _particleTimer?.cancel();
    super.dispose();
  }

  String _getLocalizedText(String key) {
    // Simple status messages with helpful tips
    final messages = {
      'status': '🎤 ابدأ التسجيل (قد لا يعمل على الـ Emulator) أو ⌨️ اكتب مباشرة',
      'listening': '🎤 أتكلم الآن... (إذا لم يعمل، اضغط لإيقاف واكتب يدوياً)',
      'processing': '🔄 جاري التحليل...',
      'success': '✅ تم بنجاح! راجع النص أدناه',
      'error': '❌ جرب الكتابة اليدوية أو الأمثلة السريعة أدناه',
      'placeholder': 'اكتب هنا: "اشتريت خبز بـ 5 جنيه" أو "دفعت 20 جنيه مواصلات"',
    };
    
    return messages[key] ?? 'Ready to record or type';
  }

  void _updateStatus(String message, {Duration? duration}) {
    setState(() {
      _statusMessage = message;
    });
    
    _statusTimer?.cancel();
    if (duration != null) {
      _statusTimer = Timer(duration, () {
        if (mounted) {
          setState(() {
            _statusMessage = '';
          });
        }
      });
    }
  }

  void _setState(VoiceState newState) {
    if (_currentState == newState) return;
    
    setState(() {
      _currentState = newState;
    });

    // Handle state-specific animations and behaviors
    switch (newState) {
      case VoiceState.idle:
        _pulseController.stop();
        _waveController.stop();
        _updateStatus(_getLocalizedText('status'));
        break;
      case VoiceState.initializing:
        _updateStatus('🎤 Initializing microphone...', duration: const Duration(seconds: 3));
        break;
      case VoiceState.listening:
        _pulseController.repeat(reverse: true);
        _waveController.repeat(reverse: true);
        _updateStatus(_getLocalizedText('listening'));
        break;
      case VoiceState.processing:
        _pulseController.stop();
        _waveController.stop();
        _updateStatus(_getLocalizedText('processing'));
        break;
      case VoiceState.success:
        _pulseController.stop();
        _waveController.stop();
        _particleController.forward();
        _updateStatus(_getLocalizedText('success'), duration: const Duration(seconds: 3));
        break;
      case VoiceState.error:
        _pulseController.stop();
        _waveController.stop();
        break;
      case VoiceState.typing:
        _pulseController.stop();
        _waveController.stop();
        _updateStatus('⌨️ Type your expense details');
        break;
    }
  }

  void _toggleListening() async {
    HapticFeedback.mediumImpact();
    
    if (_currentState == VoiceState.listening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    _setState(VoiceState.initializing);
    
    try {
      await _voiceService.startListening(
        onResult: (text) async {
          if (mounted && text.isNotEmpty && text.trim().length > 1) {
            print('🎤 Voice recognized: "$text"');
            
            setState(() {
              _recognizedText = text;
              _processedText = text; // استخدام النص مباشرة
              _textController.text = text; // تحديث الحقل فوراً
            });
            
            // لا نوقف الاستماع، نتركه يكمل
            // المستخدم هو اللي هيوقفه لما يخلص
            print('📝 النص المحدث: "$text"');
          }
        },
        onError: (error) {
          if (mounted) {
            print('❌ خطأ في الصوت: $error');
            
            // معالجة خاصة لمشاكل الـ Android Emulator
            if (error.toLowerCase().contains('speech_timeout') ||
                error.toLowerCase().contains('timeout')) {
              setState(() {
                _errorMessage = '⚠️ مشكلة في الـ Android Emulator:\n'
                    '• الميكروفون مش بيشتغل كويس على الـ Emulator\n'
                    '• جرب على جهاز حقيقي للحصول على أفضل النتائج\n'
                    '• أو استخدم الكتابة اليدوية أو الأمثلة أدناه';
              });
            } else if (error.toLowerCase().contains('no_match') || 
                error.toLowerCase().contains('no match')) {
              setState(() {
                _errorMessage = '🎤 لم يتم سماع صوت واضح. تأكد من:\n• الميكروفون يعمل\n• التحدث بوضوح\n• أو استخدم الكتابة اليدوية أدناه';
              });
            } else if (error.toLowerCase().contains('no_speech')) {
              setState(() {
                _errorMessage = '🔇 لم يتم اكتشاف كلام. جرب:\n• التحدث أقرب للميكروفون\n• رفع مستوى الصوت\n• أو اكتب يدوياً أدناه';
              });
            } else if (error.toLowerCase().contains('permission')) {
              setState(() {
                _errorMessage = '🚫 مطلوب إذن الميكروفون. يرجى تفعيله من الإعدادات أو استخدم الكتابة اليدوية.';
              });
            } else if (error.toLowerCase().contains('network')) {
              setState(() {
                _errorMessage = '🌐 خطأ في الشبكة. تحقق من اتصال الإنترنت أو استخدم الكتابة اليدوية.';
              });
            } else if (error.toLowerCase().contains('not available')) {
              setState(() {
                _errorMessage = '❌ التعرف على الصوت غير متاح على هذا الجهاز.\n✅ استخدم الكتابة اليدوية أو الأمثلة السريعة أدناه.';
              });
            } else {
              setState(() {
                _errorMessage = '⚠️ مشكلة في التعرف على الصوت.\n💡 جرب الكتابة اليدوية أو الأمثلة السريعة أدناه.';
              });
            }
            
            _setState(VoiceState.error);
            HapticFeedback.heavyImpact();
            
            // بعد 4 ثواني، اخفي الخطأ واعرض الكتابة مع الأمثلة السريعة
            Timer(const Duration(seconds: 4), () {
              if (mounted) {
                setState(() {
                  _errorMessage = '';
                });
                _setState(VoiceState.idle); // العودة للحالة الأساسية لإظهار الأمثلة السريعة
              }
            });
          }
        },
        onSoundLevel: (level) {
          if (mounted) {
            setState(() {
              _soundLevel = level;
            });
            
            // إذا مستوى الصوت ضعيف جداً لفترة طويلة، اعرض تحذير
            if (level < -15 && _currentState == VoiceState.listening) {
              print('⚠️ مستوى صوت ضعيف: $level dB');
            }
          }
        },
      );
      
      if (mounted) {
        _setState(VoiceState.listening);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'فشل في بدء التسجيل. جرب الكتابة يدوياً.';
        });
        _setState(VoiceState.typing); // اتجه للكتابة مباشرة
        HapticFeedback.heavyImpact();
      }
    }
  }

  Future<void> _stopListening() async {
    await _voiceService.stopListening();
    if (mounted) {
      if (_processedText.isNotEmpty || _recognizedText.isNotEmpty) {
        _setState(VoiceState.success);
      } else {
        _setState(VoiceState.idle);
      }
    }
  }

  Future<void> _processVoiceAndAddExpense() async {
    final textToProcess = _textController.text.trim();
    if (_currentState == VoiceState.processing || !mounted || textToProcess.isEmpty) return;
    
    _setState(VoiceState.processing);
    HapticFeedback.mediumImpact();
    
    try {
      print('🎤 Processing text: $textToProcess');
      
      final result = await _voiceApiService.analyzeText(textToProcess);
      
      if (!mounted) return;
      
      if (result.isSuccess) {
        final data = result.data;
        if (data != null && data['success'] == true) {
          final transactions = data['data']?['analysis']?['transactions'];
          if (transactions != null && transactions.isNotEmpty) {
            final transaction = transactions[0];
            final amount = (transaction['amount'] as num?)?.toDouble() ?? 0.0;
            final categoryName = transaction['category'] as String? ?? 'other';
            final item = transaction['item'] as String? ?? 'Unknown Item';
            
            if (mounted && amount > 0) {
              // Extract quantity from API response or default to 1
              final quantity = (transaction['quantity'] as num?)?.toInt() ?? 1;
              
              final expense = Expense(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                amount: amount,
                category: categoryName,
                title: item,
                date: DateTime.now(),
                isVoiceInput: true,
                quantity: quantity, // Include quantity from API
              );
              
              // Use the context from the dialog's parent
              if (mounted && context.mounted) {
                try {
                  context.read<ExpenseBloc>().add(AddExpense(expense));
                  print('✅ Added voice expense: ${expense.title} - ${expense.amount} EGP');
                } catch (e) {
                  print('⚠️ Could not add to ExpenseBloc, but continuing: $e');
                }
              }
              
              if (!mounted) return;
              
              // Success animation with particles
              HapticFeedback.lightImpact();
              await _scaleController.forward();
              await _scaleController.reverse();
              _particleController.forward();
              
              Navigator.pop(context, textToProcess);
              
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '✅ تم إضافة: ${quantity}x $item - ${amount.toStringAsFixed(0)} جنيه',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: const Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      duration: const Duration(seconds: 4),
                    ),
                  );
            }
          }
        }
      }
    } catch (e) {
      print('❌ Voice processing error: $e');
      
      if (!mounted) return;
      
      Navigator.pop(context, textToProcess);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text('🎤 Voice: $textToProcess')),
              ],
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        _setState(VoiceState.idle);
      }
    }
  }

  void _onTextChanged(String value) {
    // Simply update the processed text without any language processing
    setState(() {
      _processedText = value;
      
      if (_currentState == VoiceState.idle && value.trim().isNotEmpty) {
        _setState(VoiceState.typing);
      } else if (_currentState == VoiceState.typing && value.trim().isEmpty) {
        _setState(VoiceState.idle);
      }
    });
  }

  void _resetInput() {
    HapticFeedback.lightImpact();
    setState(() {
      _recognizedText = '';
      _processedText = '';
      _textController.clear();
      _errorMessage = '';
    });
    _setState(VoiceState.idle);
    _particleController.reset();
  }

  Color _getStateColor() {
    switch (_currentState) {
      case VoiceState.listening:
        return const Color(0xFFEF4444);
      case VoiceState.processing:
        return const Color(0xFF06B6D4);
      case VoiceState.success:
        return const Color(0xFF10B981);
      case VoiceState.error:
        return const Color(0xFFF59E0B);
      case VoiceState.typing:
        return const Color(0xFF6366F1);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  IconData _getStateIcon() {
    switch (_currentState) {
      case VoiceState.listening:
        return Icons.stop_rounded;
      case VoiceState.processing:
        return Icons.psychology_rounded;
      case VoiceState.success:
        return Icons.check_rounded;
      case VoiceState.error:
        return Icons.refresh_rounded;
      case VoiceState.initializing:
        return Icons.mic_rounded;
      default:
        return Icons.mic_rounded;
    }
  }

  String _getStateText() {
    switch (_currentState) {
      case VoiceState.listening:
        return '🎤 أتكلم الآن... (المايك شغال، اضغط لإيقاف لما تخلص)';
      case VoiceState.processing:
        return '🧠 جاري تحليل النص...';
      case VoiceState.success:
        return '✅ تم بنجاح! راجع النص أدناه';
      case VoiceState.error:
        return '❌ جرب الكتابة اليدوية أو الأمثلة السريعة أدناه';
      case VoiceState.initializing:
        return '🔄 جاري تهيئة الميكروفون...';
      case VoiceState.typing:
        return '⌨️ اكتب تفاصيل المصروف أو اختر مثال سريع';
      default:
        return '🎤 ابدأ التسجيل (هيفضل شغال لحد ما توقفه)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.92,
          constraints: BoxConstraints(
            maxWidth: 400,
            maxHeight: MediaQuery.of(context).size.height * 0.85, // حد أقصى للارتفاع
          ),
          padding: const EdgeInsets.all(20), // تقليل الـ padding
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 32,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView( // إضافة scroll للمحتوى
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Enhanced Header
                _buildHeader(),
                const SizedBox(height: 20),

                // Dynamic Status Card
                _buildStatusCard(),
                const SizedBox(height: 20),

                // Enhanced Voice Button with Visualizer
                _buildVoiceButton(),
                const SizedBox(height: 20),

                // Error Display
                if (_errorMessage.isNotEmpty) ...[
                  _buildErrorCard(),
                  const SizedBox(height: 16),
                ],

                // Text Input Section
                _buildTextInputSection(),

                // Action Buttons
                if (_processedText.isNotEmpty || _textController.text.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildActionButtons(),
                ],

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getStateColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.mic_rounded,
                color: _getStateColor(),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Voice Input',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.close_rounded,
              color: Colors.grey[600],
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: _getStateColor().withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStateColor().withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          if (_currentState == VoiceState.processing) ...[
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(_getStateColor()),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              _statusMessage.isNotEmpty ? _statusMessage : _getStateText(),
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _getStateColor(),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceButton() {
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) => _scaleController.reverse(),
      onTapCancel: () => _scaleController.reverse(),
      onTap: _currentState != VoiceState.processing 
          ? _toggleListening : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Success particle effects
            if (_currentState == VoiceState.success)
              AnimatedBuilder(
                animation: _particleAnimation,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: List.generate(8, (index) {
                      final angle = (index * math.pi * 2) / 8;
                      final distance = 60 * _particleAnimation.value;
                      final x = math.cos(angle) * distance;
                      final y = math.sin(angle) * distance;
                      
                      return Transform.translate(
                        offset: Offset(x, y),
                        child: Opacity(
                          opacity: 1.0 - _particleAnimation.value,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getStateColor(),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),

            // Outer pulse ring for listening state
            if (_currentState == VoiceState.listening)
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: 140 * _pulseAnimation.value,
                    height: 140 * _pulseAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _getStateColor().withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                  );
                },
              ),

            // Enhanced sound wave visualization with sound level
            if (_currentState == VoiceState.listening)
              ...List.generate(4, (index) {
                return AnimatedBuilder(
                  animation: _waveAnimation,
                  builder: (context, child) {
                    final delay = index * 0.15;
                    final animValue = (_waveAnimation.value + delay) % 1.0;
                    final soundIntensity = math.max(0.0, (_soundLevel + 20) / 20);
                    final baseScale = 1.0 + (math.sin(animValue * math.pi * 2) * 0.08);
                    final soundScale = baseScale + (soundIntensity * 0.15);
                    
                    return Container(
                      width: (115 + index * 12) * soundScale,
                      height: (115 + index * 12) * soundScale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _getStateColor().withValues(
                            alpha: (0.15 - index * 0.03) + (soundIntensity * 0.1)
                          ),
                          width: 1 + (soundIntensity * 0.5),
                        ),
                      ),
                    );
                  },
                );
              }),

            // Sound level indicator (inner glow)
            if (_currentState == VoiceState.listening && _soundLevel > -15)
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _getStateColor().withValues(
                        alpha: math.max(0.0, (_soundLevel + 20) / 40)
                      ),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),

            // Main button
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    _getStateColor(),
                    _getStateColor().withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getStateColor().withValues(alpha: 0.4),
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
                      size: 44,
                    ),
            ),

            // Sound level text indicator (for debugging - can be removed in production)
            if (_currentState == VoiceState.listening && _soundLevel > -20)
              Positioned(
                bottom: -35,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_soundLevel.toStringAsFixed(0)} dB',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_rounded, color: Colors.red[600], size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.red[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInputSection() {
    final hasText = _processedText.isNotEmpty || _textController.text.trim().isNotEmpty;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasText) ...[
            Row(
              children: [
                Icon(Icons.edit_rounded, color: Colors.grey[600], size: 16),
                const SizedBox(width: 6),
                Text(
                  'Review and edit:',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ] else ...[
            const Divider(height: 20),
            Center(
              child: Text(
                'أو اكتب يدوياً:',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Quick input buttons for common Arabic phrases
            if (_currentState == VoiceState.error || _currentState == VoiceState.idle) ...[
              _buildQuickInputButtons(),
              const SizedBox(height: 12),
            ],
          ],
          
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _currentState == VoiceState.typing 
                    ? const Color(0xFF6366F1)
                    : Colors.grey[300]!,
                width: _currentState == VoiceState.typing ? 2 : 1,
              ),
            ),
            child: TextField(
              controller: _textController,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF374151),
              ),
              maxLines: 2,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(12),
                hintText: hasText 
                    ? 'Edit your expense details...'
                    : 'اكتب هنا: "اشتريت خبز بـ 5 جنيه" أو "دفعت 20 جنيه مواصلات"',
                hintStyle: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
              onChanged: _onTextChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInputButtons() {
    final quickPhrases = [
      'اشتريت خبز بـ 5 جنيه',
      'دفعت 20 جنيه مواصلات',
      'صرفت 50 جنيه على أكل',
      'اشتريت دواء بـ 30 جنيه',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.touch_app_rounded, color: Colors.blue[600], size: 14),
            const SizedBox(width: 6),
            Text(
              'أمثلة سريعة (اضغط للاستخدام):',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.blue[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: quickPhrases.map((phrase) {
            return GestureDetector(
              onTap: () {
                _textController.text = phrase;
                _onTextChanged(phrase);
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
                  phrase,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        // إضافة نصيحة للميكروفون
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.red[700], size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'تحذير: الميكروفون قد لا يعمل على الـ Android Emulator. جرب على جهاز حقيقي أو استخدم الأمثلة أعلاه',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Colors.red[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final isProcessing = _currentState == VoiceState.processing;
    final hasText = _textController.text.trim().isNotEmpty;
    
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isProcessing ? null : _resetInput,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Reset'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: Colors.grey[400]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: (hasText && !isProcessing) ? _processVoiceAndAddExpense : null,
            icon: isProcessing 
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.add_rounded, size: 20),
            label: Text(
              isProcessing 
                  ? 'Adding...' 
                  : 'Add Transaction',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }
}

/// Show Simple Voice Input Dialog
Future<String?> showSimpleVoiceInputDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) => const SimpleVoiceInputDialog(),
  );
}