import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/voice_service.dart';
import '../../services/voice_api_service.dart';
import '../../features/home/bloc/expense_bloc.dart';
import '../../features/home/bloc/expense_event.dart';
import '../../core/models/expense.dart';

/// Simple Voice Input Dialog - Complete Voice System
/// Features: Voice Recognition → Text Display → Edit → Smart Analysis → Auto Categories
class SimpleVoiceInputDialog extends StatefulWidget {
  const SimpleVoiceInputDialog({super.key});

  @override
  State<SimpleVoiceInputDialog> createState() => _SimpleVoiceInputDialogState();
}

class _SimpleVoiceInputDialogState extends State<SimpleVoiceInputDialog> {
  bool _isListening = false;
  String _recognizedText = '';
  String _errorMessage = '';
  bool _isProcessing = false;
  final VoiceService _voiceService = VoiceService();
  final VoiceApiService _voiceApiService = VoiceApiService();
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _voiceService.stopListening();
    _textController.dispose();
    super.dispose();
  }

  void _toggleListening() async {
    HapticFeedback.mediumImpact();
    
    if (_isListening) {
      await _voiceService.stopListening();
      setState(() {
        _isListening = false;
      });
    } else {
      setState(() {
        _isListening = true;
        _errorMessage = '';
        _recognizedText = '';
      });
      
      await _voiceService.startListening(
        onResult: (text) async {
          if (mounted && text.isNotEmpty && text.trim().length > 1) {
            print('🎤 Voice recognized: "$text"');
            setState(() {
              _recognizedText = text;
              _textController.text = text;
              _errorMessage = '';
            });
            
            // Don't auto-stop - let user control when to stop
            // User can tap the mic button again to stop
            print('🎤 Voice text received, continuing to listen...');
            setState(() {
              _recognizedText = text;
              _textController.text = text;
              _errorMessage = '';
            });
          }
        },
        onError: (error) {
          if (mounted) {
            print('❌ Voice error: $error');
            setState(() {
              _isListening = false;
              _errorMessage = 'Voice recognition failed. You can type manually below.';
              _recognizedText = 'manual_input';
              _textController.text = '';
            });
          }
        },
      );
    }
  }

  Future<void> _processVoiceAndAddExpense() async {
    final textToProcess = _textController.text.trim();
    if (_isProcessing || !mounted || textToProcess.isEmpty) return;
    
    setState(() {
      _isProcessing = true;
    });
    
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
              final expense = Expense(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                amount: amount,
                category: categoryName,
                title: item,
                date: DateTime.now(),
                isVoiceInput: true,
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
              
              Navigator.pop(context, textToProcess);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.mic, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('🎤 Added: $item - ${amount.toStringAsFixed(0)} EGP'),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.green,
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
            content: Text('🎤 Voice: $textToProcess'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🎤 Voice Input',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
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
            ),

            const SizedBox(height: 24),

            // Status message
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: _isListening 
                  ? Colors.red.withValues(alpha: 0.1)
                  : _recognizedText.isNotEmpty 
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isListening 
                    ? Colors.red.withValues(alpha: 0.3)
                    : _recognizedText.isNotEmpty 
                      ? Colors.green.withValues(alpha: 0.3)
                      : Colors.blue.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                _isListening 
                  ? '🎤 Recording... Tap mic to stop'
                  : _recognizedText.isNotEmpty 
                    ? '✅ Ready! Edit text below if needed'
                    : '💡 Speak English, edit to Arabic if needed',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _isListening 
                    ? Colors.red[700]
                    : _recognizedText.isNotEmpty 
                      ? Colors.green[700]
                      : Colors.blue[700],
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 24),

            // Microphone button with animation
            GestureDetector(
              onTap: _toggleListening,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: _isListening
                        ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                        : [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_isListening
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF3B82F6))
                          .withValues(alpha: 0.4),
                      blurRadius: _isListening ? 25 : 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Pulsing animation when recording
                    if (_isListening)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 1000),
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                      ),
                    // Mic icon
                    Icon(
                      _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Error message
            if (_errorMessage.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_rounded, color: Colors.orange[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Recognized text with editable field
            if (_recognizedText.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.edit_rounded, color: Colors.grey[600], size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Edit your text:',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _textController,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: const Color(0xFF374151),
                      ),
                      maxLines: 3,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF3B82F6),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                        hintText: 'e.g., "اشتريت قهوة بـ 50 جنيه"',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _recognizedText = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _recognizedText = '';
                          _textController.clear();
                          _errorMessage = '';
                        });
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Try Again'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey[400]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: (_textController.text.trim().isNotEmpty && !_isProcessing) 
                        ? _processVoiceAndAddExpense 
                        : null,
                      icon: _isProcessing 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.add_rounded, size: 18),
                      label: Text(_isProcessing ? 'Adding...' : 'Add Transaction'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Manual input option (when no voice text)
            if (_recognizedText.isEmpty && !_isListening) ...[
              const Divider(height: 32),
              Text(
                'Or type manually:',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _textController,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: const Color(0xFF374151),
                ),
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'e.g., "I bought coffee for 50 EGP"',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF3B82F6),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                onChanged: (value) {
                  setState(() {
                    if (value.trim().isNotEmpty) {
                      _recognizedText = 'manual_input';
                    } else {
                      _recognizedText = '';
                    }
                  });
                },
              ),
              if (_textController.text.trim().isNotEmpty) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: !_isProcessing ? _processVoiceAndAddExpense : null,
                    icon: _isProcessing 
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.add_rounded, size: 18),
                    label: Text(_isProcessing ? 'Adding...' : 'Add Transaction'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ],

            const SizedBox(height: 8),
          ],
        ),
      ),
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