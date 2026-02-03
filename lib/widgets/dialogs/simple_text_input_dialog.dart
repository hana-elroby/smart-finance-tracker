import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/voice_api_service.dart';
import '../../features/home/bloc/expense_bloc.dart';
import '../../features/home/bloc/expense_event.dart';
import '../../core/models/expense.dart';

/// Simple Text Input Dialog - بدون voice، بس text + API
class SimpleTextInputDialog extends StatefulWidget {
  const SimpleTextInputDialog({super.key});

  @override
  State<SimpleTextInputDialog> createState() => _SimpleTextInputDialogState();
}

class _SimpleTextInputDialogState extends State<SimpleTextInputDialog> {
  final TextEditingController _textController = TextEditingController();
  final VoiceApiService _apiService = VoiceApiService();
  bool _isProcessing = false;
  String _statusMessage = '';

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _processWithAPI() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isProcessing) return;
    
    setState(() {
      _isProcessing = true;
      _statusMessage = 'جاري التحليل...';
    });
    
    try {
      print('🔄 إرسال للـ API: "$text"');
      
      final result = await _apiService.analyzeText(text);
      
      if (!mounted) return;
      
      print('📥 استجابة الـ API: ${result.data}');
      
      if (result.isSuccess && result.data != null) {
        final data = result.data!;
        
        if (data['success'] == true) {
          final analysisData = data['data']?['analysis'];
          if (analysisData != null) {
            final transactions = analysisData['transactions'];
            if (transactions != null && transactions.isNotEmpty) {
              final transaction = transactions[0];
              
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
      
      // إذا فشل التحليل
      if (mounted) {
        Navigator.pop(context, text);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إرسال النص: $text\n(لم يتم التحليل)'),
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
            content: Text('تم إرسال النص: $text\n(خطأ في الـ API)'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _statusMessage = '';
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
                  'إضافة مصروف',
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
            if (_statusMessage.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _statusMessage,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Text input
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _textController,
                maxLines: 4,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  hintText: 'اكتب تفاصيل المصروف هنا:\nمثال: "اشتريت خبز بـ 5 جنيه"\nأو: "دفعت 20 جنيه مواصلات"',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
                style: GoogleFonts.inter(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),

            // Quick examples
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
                'جبت 2 قهوة بـ 60 جنيه',
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
            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _textController.clear();
                      HapticFeedback.lightImpact();
                    },
                    child: const Text('مسح'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _textController.text.trim().isNotEmpty && !_isProcessing 
                        ? _processWithAPI 
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                        : const Text('تحليل وإضافة'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Show Simple Text Input Dialog
Future<String?> showSimpleTextInputDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (context) => const SimpleTextInputDialog(),
  );
}