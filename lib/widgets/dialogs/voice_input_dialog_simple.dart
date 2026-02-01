import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/voice_service.dart';
import '../../services/voice_api_service.dart';
import '../../features/home/bloc/expense_bloc.dart';
import '../../features/home/bloc/expense_event.dart';
import '../../core/models/expense.dart';

/// Simple Voice Input Dialog - WORKING VERSION
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
          if (mounted && text.isNotEmpty) {
            print('🎤 Voice recognized: "$text"');
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
              _errorMessage = 'Voice recognition failed. Try again.';
              _isListening = false;
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
      
      // Step 1: Analyze text using Voice API
      final result = await _voiceApiService.analyzeText(textToProcess);
      
      if (!mounted) return;
      
      if (result.isSuccess) {
        final analysis = result.data['analysis'];
        if (analysis != null) {
          final amount = (analysis['amount'] as num?)?.toDouble() ?? 0.0;
          final categoryName = analysis['category'] as String? ?? 'other';
          final item = analysis['item'] as String? ?? 'Unknown Item';
          final place = analysis['place'] as String?;
          
          // Step 2: Smart category mapping with item-based detection
          final mappedCategory = _mapToExistingCategory(categoryName, item);
          
          // Step 3: Create expense and add to ExpenseBloc
          if (mounted && amount > 0) {
            final expense = Expense(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              amount: amount,
              category: mappedCategory,
              title: item,
              date: DateTime.now(),
              notes: place != null ? 'at $place' : null,
              isVoiceInput: true, // Mark as voice input
            );
            
            // Add to ExpenseBloc
            context.read<ExpenseBloc>().add(AddExpense(expense));
            print('✅ Added voice expense: ${expense.title} - ${expense.amount} EGP (${expense.category})');
            
            if (!mounted) return;
            
            Navigator.pop(context, textToProcess);
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.mic, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('🎤 Added: $item - ${amount.toStringAsFixed(0)} EGP ($mappedCategory)'),
                    ),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 4),
              ),
            );
          }
          
          print('✅ Voice analysis successful: $analysis');
        } else {
          throw Exception('No analysis data received');
        }
      } else {
        throw Exception(result.message ?? 'Voice analysis failed');
      }
    } catch (e) {
      print('❌ Voice processing error: $e');
      
      if (!mounted) return;
      
      Navigator.pop(context, textToProcess);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎤 Voice: $textToProcess\n(Analysis failed: $e)'),
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

  String _mapToExistingCategory(String voiceCategory, String itemName) {
    final category = voiceCategory.toLowerCase();
    final item = itemName.toLowerCase();
    
    print('🤖 AI Mapping - Category: "$voiceCategory", Item: "$itemName"');
    
    // First priority: Direct category mapping from Voice API
    switch (category) {
      case 'food':
      case 'drink':
        print('✅ AI mapped to: Food & Drink');
        return 'Food & Drink';
      
      case 'shopping':
        print('✅ AI mapped to: Shopping');
        return 'Shopping';
      
      case 'bills':
      case 'utilities':
        print('✅ AI mapped to: Bills');
        return 'Bills';
      
      case 'health':
      case 'medical':
        print('✅ AI mapped to: Health');
        return 'Health';
    }
    
    // Second priority: AI-based item analysis for "other" or unknown categories
    print('🧠 AI analyzing item: "$item" for smart categorization...');
    
    // Use AI-like keyword analysis (more flexible than exact matching)
    final itemWords = item.split(' ');
    
    // Health-related AI detection
    if (_containsHealthKeywords(item, itemWords)) {
      print('🤖 AI detected: Health category');
      return 'Health';
    }
    
    // Food-related AI detection  
    if (_containsFoodKeywords(item, itemWords)) {
      print('🤖 AI detected: Food & Drink category');
      return 'Food & Drink';
    }
    
    // Shopping-related AI detection
    if (_containsShoppingKeywords(item, itemWords)) {
      print('🤖 AI detected: Shopping category');
      return 'Shopping';
    }
    
    // Bills-related AI detection
    if (_containsBillsKeywords(item, itemWords)) {
      print('🤖 AI detected: Bills category');
      return 'Bills';
    }
    
    // If AI can't determine, create smart dynamic category
    final smartCategory = _createSmartCategory(voiceCategory, itemName);
    print('🤖 AI created smart category: $smartCategory');
    return smartCategory;
  }

  // AI-powered health detection
  bool _containsHealthKeywords(String item, List<String> words) {
    final healthPatterns = [
      // English patterns
      'medic', 'doctor', 'hospital', 'pharmacy', 'pill', 'drug', 'vitamin',
      'clinic', 'dental', 'health', 'treatment', 'therapy', 'surgery',
      // Arabic patterns  
      'دوا', 'دكتور', 'مستشفى', 'صيدلية', 'علاج', 'طبيب', 'عيادة',
      'أسنان', 'صحة', 'فيتامين', 'حبوب', 'دواء'
    ];
    
    return healthPatterns.any((pattern) => 
      item.contains(pattern) || words.any((word) => word.contains(pattern))
    );
  }

  // AI-powered food detection
  bool _containsFoodKeywords(String item, List<String> words) {
    final foodPatterns = [
      // English patterns
      'food', 'eat', 'drink', 'coffee', 'tea', 'restaurant', 'cafe',
      'meal', 'lunch', 'dinner', 'breakfast', 'snack', 'pizza', 'burger',
      // Arabic patterns
      'أكل', 'طعام', 'شراب', 'قهوة', 'شاي', 'مطعم', 'وجبة',
      'فطار', 'غداء', 'عشاء', 'مشروب', 'عصير'
    ];
    
    return foodPatterns.any((pattern) => 
      item.contains(pattern) || words.any((word) => word.contains(pattern))
    );
  }

  // AI-powered shopping detection
  bool _containsShoppingKeywords(String item, List<String> words) {
    final shoppingPatterns = [
      // English patterns
      'buy', 'shop', 'store', 'book', 'clothes', 'shirt', 'shoes',
      'electronics', 'phone', 'computer', 'gift', 'toy', 'game',
      // Arabic patterns
      'شراء', 'متجر', 'كتاب', 'ملابس', 'قميص', 'حذاء',
      'إلكترونيات', 'هاتف', 'كمبيوتر', 'هدية', 'لعبة'
    ];
    
    return shoppingPatterns.any((pattern) => 
      item.contains(pattern) || words.any((word) => word.contains(pattern))
    );
  }

  // AI-powered bills detection
  bool _containsBillsKeywords(String item, List<String> words) {
    final billsPatterns = [
      // English patterns
      'bill', 'electric', 'water', 'gas', 'internet', 'phone', 'rent',
      'subscription', 'utility', 'payment', 'invoice',
      // Arabic patterns
      'فاتورة', 'كهرباء', 'مياه', 'غاز', 'إنترنت', 'تليفون',
      'إيجار', 'اشتراك', 'دفع', 'سداد'
    ];
    
    return billsPatterns.any((pattern) => 
      item.contains(pattern) || words.any((word) => word.contains(pattern))
    );
  }

  // AI-powered smart category creation
  String _createSmartCategory(String originalCategory, String itemName) {
    // If Voice API provided a meaningful category, use it
    if (originalCategory.toLowerCase() != 'other' && originalCategory.isNotEmpty) {
      return originalCategory[0].toUpperCase() + originalCategory.substring(1).toLowerCase();
    }
    
    // Otherwise, create category based on item name
    final words = itemName.toLowerCase().split(' ');
    final meaningfulWord = words.firstWhere(
      (word) => word.length > 2 && !['the', 'and', 'for', 'with'].contains(word),
      orElse: () => itemName,
    );
    
    return meaningfulWord[0].toUpperCase() + meaningfulWord.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
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
            ),

            const SizedBox(height: 8),

            // Title
            Text(
              'Voice Input',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0D5DB8),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _isListening 
                ? '🎤 Recording... Speak now!' 
                : 'Tap the mic to start recording',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: _isListening ? Colors.red[600] : Colors.grey[600],
                fontWeight: _isListening ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Simple Mic Button with pulsing animation when recording
            GestureDetector(
              onTap: _toggleListening,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 80,
                height: 80,
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
                      blurRadius: _isListening ? 30 : 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Pulsing ring when recording
                    if (_isListening)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 1000),
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                      ),
                    Icon(
                      _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

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
                    fontSize: 14,
                    color: Colors.red[700],
                  ),
                  textAlign: TextAlign.center,
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
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF10B981),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Recognized - You can edit:',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Editable text field
                    TextField(
                      controller: _textController,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151),
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: const Color(0xFF10B981).withValues(alpha: 0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF10B981),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        hintText: 'Edit your text here...',
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _recognizedText = '';
                          _textController.clear();
                          _errorMessage = '';
                        });
                        _toggleListening();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFF6B7280)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Try Again',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_textController.text.trim().isNotEmpty && !_isProcessing) 
                        ? _processVoiceAndAddExpense 
                        : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isProcessing 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Add Transaction',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                    ),
                  ),
                ],
              ),
            ],

            if (_recognizedText.isEmpty && !_isListening) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.mic_rounded,
                      color: Colors.grey[400],
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the microphone and speak clearly\nSupports Arabic and English\nTap again to stop recording',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],

            // Show recording status when listening
            if (_isListening && _recognizedText.isEmpty) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'RECORDING',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.red[700],
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Speak now... Tap mic to stop',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.red[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
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