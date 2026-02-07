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

/// Modern Voice Input Dialog with Beautiful UI/UX
/// Features: Real server integration, Smart analysis, Beautiful animations
class ModernVoiceDialog extends StatefulWidget {
  const ModernVoiceDialog({super.key});

  @override
  State<ModernVoiceDialog> createState() => _ModernVoiceDialogState();
}

enum VoiceState {
  idle,
  listening,
  processing,
  success,
  error,
}

class _ModernVoiceDialogState extends State<ModernVoiceDialog>
    with TickerProviderStateMixin {
  VoiceState _currentState = VoiceState.idle;
  String _recognizedText = '';
  String _analysisResult = '';
  String _errorMessage = '';
  double _soundLevel = 0.0;
  
  final VoiceService _voiceService = VoiceService();
  final VoiceApiService _voiceApiService = VoiceApiService();
  final TextEditingController _textController = TextEditingController();
  
  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _fadeController;
  
  // Animations
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _fadeAnimation;
  
  Timer? _soundLevelTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _testServerConnection();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _fadeController.forward();
  }

  Future<void> _testServerConnection() async {
    final isConnected = await _voiceApiService.testConnection();
    if (!isConnected) {
      setState(() {
        _errorMessage = 'Server connection failed. Please try again later.';
      });
    }
  }

  Future<void> _startListening() async {
    if (_currentState == VoiceState.listening) return;
    
    HapticFeedback.lightImpact();
    setState(() {
      _currentState = VoiceState.listening;
      _recognizedText = '';
      _errorMessage = '';
    });

    _pulseController.repeat(reverse: true);
    _waveController.repeat(reverse: true);

    try {
      await _voiceService.startListening(
        onResult: (text) {
          setState(() {
            _recognizedText = text;
          });
          
          if (text.isNotEmpty) {
            _analyzeText(text);
          }
        },
        onError: (error) {
          _handleError('Voice recognition failed: $error');
        },
        onSoundLevel: (level) {
          setState(() {
            _soundLevel = level;
          });
        },
      );
    } catch (e) {
      _handleError('Voice service error: $e');
    }

    _stopAnimations();
  }

  Future<void> _analyzeText(String text) async {
    setState(() {
      _currentState = VoiceState.processing;
    });

    try {
      final result = await _voiceApiService.analyzeText(text);
      
      if (result.isSuccess && result.data != null) {
        final data = result.data;
        
        // Extract expense data from server response
        final amount = _extractAmount(data);
        final category = _extractCategory(data);
        final description = _extractDescription(data) ?? text;
        
        if (amount > 0) {
          setState(() {
            _currentState = VoiceState.success;
            _analysisResult = 'Amount: \$${amount.toStringAsFixed(2)}\\nCategory: $category\\nDescription: $description';
          });
          
          // Add expense to bloc
          _addExpenseToBloc(amount, category, description);
          
          // Auto close after success
          Timer(const Duration(seconds: 2), () {
            if (mounted) Navigator.of(context).pop(_analysisResult);
          });
        } else {
          _handleError('Could not extract expense information from: "$text"');
        }
      } else {
        _handleError(result.message ?? 'Analysis failed');
      }
    } catch (e) {
      _handleError('Analysis error: $e');
    }
  }

  double _extractAmount(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        // Try different possible keys for amount
        final possibleKeys = ['amount', 'price', 'cost', 'value', 'money', 'total'];
        for (String key in possibleKeys) {
          if (data.containsKey(key)) {
            final value = data[key];
            if (value is num) return value.toDouble();
            if (value is String) {
              // Extract numbers from string
              final match = RegExp(r'[\d.]+').firstMatch(value);
              if (match != null) {
                return double.tryParse(match.group(0)!) ?? 0.0;
              }
            }
          }
        }
        
        // If no direct amount found, try to parse from any string value
        for (var value in data.values) {
          if (value is String) {
            final match = RegExp(r'[\d.]+').firstMatch(value);
            if (match != null) {
              final amount = double.tryParse(match.group(0)!);
              if (amount != null && amount > 0) return amount;
            }
          }
        }
      }
      return 0.0;
    } catch (e) {
      print('Error extracting amount: $e');
      return 0.0;
    }
  }

  String _extractCategory(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        // Try different possible keys for category
        final possibleKeys = ['category', 'type', 'classification', 'class'];
        for (String key in possibleKeys) {
          if (data.containsKey(key) && data[key] is String) {
            return data[key];
          }
        }
        
        // Default categories based on common Arabic/English words
        final text = data.toString().toLowerCase();
        if (text.contains('طعام') || text.contains('food') || text.contains('restaurant')) return 'Food';
        if (text.contains('مواصلات') || text.contains('transport') || text.contains('taxi')) return 'Transport';
        if (text.contains('تسوق') || text.contains('shopping') || text.contains('clothes')) return 'Shopping';
        if (text.contains('صحة') || text.contains('health') || text.contains('medicine')) return 'Health';
        if (text.contains('تعليم') || text.contains('education') || text.contains('books')) return 'Education';
      }
      return 'Other';
    } catch (e) {
      print('Error extracting category: $e');
      return 'Other';
    }
  }

  String? _extractDescription(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        // Try different possible keys for description
        final possibleKeys = ['description', 'item', 'note', 'details', 'text'];
        for (String key in possibleKeys) {
          if (data.containsKey(key) && data[key] is String) {
            return data[key];
          }
        }
      }
      return null;
    } catch (e) {
      print('Error extracting description: $e');
      return null;
    }
  }

  void _addExpenseToBloc(double amount, String category, String description) {
    try {
      final expense = Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount,
        category: category,
        title: description,
        date: DateTime.now(),
        isVoiceInput: true,
      );
      
      context.read<ExpenseBloc>().add(AddExpense(expense));
    } catch (e) {
      print('Error adding expense to bloc: $e');
    }
  }

  void _handleError(String error) {
    setState(() {
      _currentState = VoiceState.error;
      _errorMessage = error;
    });
    _stopAnimations();
    HapticFeedback.heavyImpact();
  }

  void _stopAnimations() {
    _pulseController.stop();
    _waveController.stop();
  }

  Future<void> _analyzeTextInput() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    
    await _analyzeText(text);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _fadeController.dispose();
    _soundLevelTimer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
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
              _buildHeader(),
              const SizedBox(height: 24),
              _buildVoiceVisualizer(),
              const SizedBox(height: 24),
              _buildStatusSection(),
              const SizedBox(height: 24),
              _buildTextInput(),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.mic_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Voice Expense Tracker',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1a1a1a),
                ),
              ),
              Text(
                'Speak or type your expense',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey[100],
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceVisualizer() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF667eea).withValues(alpha: 0.1),
            const Color(0xFF764ba2).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated background waves
          if (_currentState == VoiceState.listening) ...[
            AnimatedBuilder(
              animation: _waveAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(double.infinity, 120),
                  painter: WaveformPainter(
                    progress: _waveAnimation.value,
                    soundLevel: _soundLevel,
                  ),
                );
              },
            ),
          ],
          
          // Central microphone button
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _currentState == VoiceState.listening ? _pulseAnimation.value : 1.0,
                child: GestureDetector(
                  onTap: _startListening,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getButtonColors(),
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _getButtonColors().first.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      _getButtonIcon(),
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Color> _getButtonColors() {
    switch (_currentState) {
      case VoiceState.listening:
        return [const Color(0xFFff6b6b), const Color(0xFFee5a24)];
      case VoiceState.processing:
        return [const Color(0xFFfeca57), const Color(0xFFff9ff3)];
      case VoiceState.success:
        return [const Color(0xFF26de81), const Color(0xFF20bf6b)];
      case VoiceState.error:
        return [const Color(0xFFff6b6b), const Color(0xFFee5a24)];
      default:
        return [const Color(0xFF667eea), const Color(0xFF764ba2)];
    }
  }

  IconData _getButtonIcon() {
    switch (_currentState) {
      case VoiceState.listening:
        return Icons.stop_rounded;
      case VoiceState.processing:
        return Icons.hourglass_empty_rounded;
      case VoiceState.success:
        return Icons.check_rounded;
      case VoiceState.error:
        return Icons.error_outline_rounded;
      default:
        return Icons.mic_rounded;
    }
  }

  Widget _buildStatusSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getStatusTitle(),
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1a1a1a),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getStatusMessage(),
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          if (_recognizedText.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Text(
                _recognizedText,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.blue[800],
                ),
              ),
            ),
          ],
          if (_analysisResult.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Text(
                _analysisResult,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.green[800],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getStatusTitle() {
    switch (_currentState) {
      case VoiceState.listening:
        return 'Listening...';
      case VoiceState.processing:
        return 'Analyzing...';
      case VoiceState.success:
        return 'Success!';
      case VoiceState.error:
        return 'Error';
      default:
        return 'Ready';
    }
  }

  String _getStatusMessage() {
    switch (_currentState) {
      case VoiceState.listening:
        return 'Speak clearly about your expense';
      case VoiceState.processing:
        return 'Processing your input with AI...';
      case VoiceState.success:
        return 'Expense added successfully!';
      case VoiceState.error:
        return _errorMessage;
      default:
        return 'Tap the microphone to start recording';
    }
  }

  Widget _buildTextInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Or type your expense:',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _textController,
          decoration: InputDecoration(
            hintText: 'e.g., "Spent 25 dollars on lunch at McDonald\'s"',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF667eea)),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          maxLines: 2,
          onSubmitted: (_) => _analyzeTextInput(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _textController.text.trim().isNotEmpty ? _analyzeTextInput : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Analyze Text',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Custom painter for waveform visualization
class WaveformPainter extends CustomPainter {
  final double progress;
  final double soundLevel;

  WaveformPainter({required this.progress, required this.soundLevel});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF667eea).withValues(alpha: 0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = 30.0;
    
    for (int i = 0; i < 3; i++) {
      final radius = baseRadius + (i * 15) + (soundLevel * 20);
      final opacity = (1.0 - (i * 0.3)) * (0.5 + soundLevel);
      
      paint.color = const Color(0xFF667eea).withValues(alpha: opacity);
      
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}