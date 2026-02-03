// اختبار تكامل الـ Voice Input في التطبيق
// Test Voice Input Integration in App

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'lib/widgets/dialogs/voice_input_dialog_simple.dart';
import 'lib/services/voice_api_service.dart';
import 'lib/features/home/bloc/expense_bloc.dart';
import 'lib/features/home/bloc/expense_event.dart';
import 'lib/core/models/expense.dart';

void main() {
  runApp(const VoiceTestApp());
}

class VoiceTestApp extends StatelessWidget {
  const VoiceTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice API Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: GoogleFonts.inter().fontFamily,
      ),
      home: BlocProvider(
        create: (context) => ExpenseBloc(),
        child: const VoiceTestPage(),
      ),
    );
  }
}

class VoiceTestPage extends StatefulWidget {
  const VoiceTestPage({super.key});

  @override
  State<VoiceTestPage> createState() => _VoiceTestPageState();
}

class _VoiceTestPageState extends State<VoiceTestPage> {
  final VoiceApiService _voiceApiService = VoiceApiService();
  List<String> _testResults = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice API Integration Test'),
        backgroundColor: const Color(0xFF0D5DB8),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0D5DB8).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.mic_rounded,
                    size: 48,
                    color: Color(0xFF0D5DB8),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Voice API Integration Test',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0D5DB8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Test the same API functionality as in the complete test',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Test Buttons
            _buildTestButton(
              'Open Voice Dialog',
              Icons.mic_rounded,
              const Color(0xFF10B981),
              _openVoiceDialog,
            ),
            const SizedBox(height: 16),
            _buildTestButton(
              'Test Arabic Text',
              Icons.translate_rounded,
              const Color(0xFF3B82F6),
              () => _testText('اشتريت خبز بـ 5 جنيه من البقالة'),
            ),
            const SizedBox(height: 16),
            _buildTestButton(
              'Test English Text',
              Icons.language_rounded,
              const Color(0xFF8B5CF6),
              () => _testText('I bought bread for 5 EGP from the grocery store'),
            ),
            const SizedBox(height: 16),
            _buildTestButton(
              'Test Franco-Arabic',
              Icons.auto_fix_high_rounded,
              const Color(0xFFF59E0B),
              () => _testText('eshtareet khobz be 5 geneeh men el ba2ala'),
            ),
            const SizedBox(height: 24),

            // Results
            Expanded(
              child: Container(
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
                        const Icon(Icons.analytics_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Test Results',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        if (_isLoading)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _testResults.isEmpty
                          ? Center(
                              child: Text(
                                'No tests run yet',
                                style: GoogleFonts.inter(
                                  color: Colors.grey[500],
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _testResults.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey[200]!),
                                  ),
                                  child: Text(
                                    _testResults[index],
                                    style: GoogleFonts.inter(fontSize: 12),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : onPressed,
      icon: Icon(icon, size: 20),
      label: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
    );
  }

  Future<void> _openVoiceDialog() async {
    try {
      final result = await showSimpleVoiceInputDialog(context);
      
      setState(() {
        if (result != null && result.isNotEmpty) {
          _testResults.insert(0, '✅ Voice Dialog Result: "$result"');
        } else {
          _testResults.insert(0, '⚠️ Voice Dialog: No result or cancelled');
        }
      });
    } catch (e) {
      setState(() {
        _testResults.insert(0, '❌ Voice Dialog Error: $e');
      });
    }
  }

  Future<void> _testText(String text) async {
    setState(() {
      _isLoading = true;
      _testResults.insert(0, '🔍 Testing: "$text"');
    });

    try {
      final result = await _voiceApiService.analyzeText(text);
      
      setState(() {
        _isLoading = false;
        
        if (result.isSuccess) {
          final data = result.data;
          if (data != null && data['success'] == true) {
            final transactions = data['data']?['analysis']?['transactions'];
            if (transactions != null && transactions.isNotEmpty) {
              final transaction = transactions[0];
              final amount = transaction['amount'];
              final category = transaction['category'];
              final item = transaction['item'];
              final type = transaction['transaction_type'];
              
              _testResults.insert(0, 
                '✅ Success: $amount EGP, $category, $item ($type)'
              );
              
              // Add to ExpenseBloc if it's an expense
              if (type == 'expense' && amount > 0) {
                final expense = Expense(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  amount: (amount as num).toDouble(),
                  category: category,
                  title: item,
                  date: DateTime.now(),
                  isVoiceInput: true,
                );
                
                context.read<ExpenseBloc>().add(AddExpense(expense));
                _testResults.insert(0, '💾 Added to ExpenseBloc: ${expense.title}');
              }
            } else {
              _testResults.insert(0, '⚠️ No transactions found in response');
            }
          } else {
            _testResults.insert(0, '❌ API returned success=false');
          }
        } else {
          _testResults.insert(0, '❌ API Error: ${result.message}');
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _testResults.insert(0, '❌ Exception: $e');
      });
    }
  }
}