// اختبار الـ Voice Input داخل التطبيق
// Test Voice Input Inside App

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'lib/widgets/dialogs/voice_input_dialog_simple.dart';
import 'lib/widgets/dialogs/add_options_bottom_sheet.dart';
import 'lib/services/voice_api_service.dart';
import 'lib/features/home/bloc/expense_bloc.dart';

void main() {
  runApp(const VoiceInAppTest());
}

class VoiceInAppTest extends StatelessWidget {
  const VoiceInAppTest({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice in App Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: GoogleFonts.inter().fontFamily,
      ),
      home: BlocProvider(
        create: (context) => ExpenseBloc(),
        child: const VoiceTestHomePage(),
      ),
    );
  }
}

class VoiceTestHomePage extends StatefulWidget {
  const VoiceTestHomePage({super.key});

  @override
  State<VoiceTestHomePage> createState() => _VoiceTestHomePageState();
}

class _VoiceTestHomePageState extends State<VoiceTestHomePage> {
  final VoiceApiService _voiceApiService = VoiceApiService();
  List<Map<String, dynamic>> _expenses = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Test - Like Real App'),
        backgroundColor: const Color(0xFF0D5DB8),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _testApiDirectly,
            icon: const Icon(Icons.api_rounded),
            tooltip: 'Test API Directly',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D5DB8), Color(0xFF1E40AF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.mic_rounded, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Voice Input Test',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Test the same API that works in the complete test',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickTestButton(
                        'Voice Dialog',
                        Icons.mic_rounded,
                        _openVoiceDialog,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickTestButton(
                        'Add Options',
                        Icons.add_rounded,
                        _showAddOptions,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Quick Test Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTestButton(
                        'Arabic Test',
                        'اشتريت خبز بـ 5 جنيه',
                        const Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTestButton(
                        'English Test',
                        'I bought bread for 5 EGP',
                        const Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTestButton(
                  'Franco-Arabic Test',
                  'eshtareet khobz be 5 geneeh men el ba2ala',
                  const Color(0xFFF59E0B),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Expenses List
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
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
                      const Icon(Icons.receipt_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Added Expenses (${_expenses.length})',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _expenses.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long_rounded,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No expenses added yet',
                                  style: GoogleFonts.inter(
                                    color: Colors.grey[500],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try the voice input or test buttons above',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _expenses.length,
                            itemBuilder: (context, index) {
                              final expense = _expenses[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        expense['isVoice'] ? Icons.mic_rounded : Icons.edit_rounded,
                                        color: const Color(0xFF10B981),
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            expense['title'],
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            expense['category'],
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${expense['amount']} EGP',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF0D5DB8),
                                      ),
                                    ),
                                  ],
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
    );
  }

  Widget _buildQuickTestButton(String title, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0D5DB8),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
    );
  }

  Widget _buildTestButton(String title, String testText, Color color) {
    return ElevatedButton(
      onPressed: () => _testTextDirectly(testText, title),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  Future<void> _openVoiceDialog() async {
    try {
      final result = await showSimpleVoiceInputDialog(context);
      
      if (result != null && result.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Voice Result: $result'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Voice Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAddOptions() {
    showAddOptionsBottomSheet(
      context,
      onVoiceTap: _openVoiceDialog,
      onManualTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Manual entry would open here'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      },
      onScanTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR/Receipt scanner would open here'),
            backgroundColor: Color(0xFF2196F3),
          ),
        );
      },
    );
  }

  Future<void> _testApiDirectly() async {
    final result = await _voiceApiService.testConnection();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result ? 'API Connection: ✅ Success' : 'API Connection: ❌ Failed'),
        backgroundColor: result ? const Color(0xFF10B981) : Colors.red,
      ),
    );
  }

  Future<void> _testTextDirectly(String text, String type) async {
    try {
      final result = await _voiceApiService.analyzeText(text);
      
      if (result.isSuccess) {
        final data = result.data;
        if (data != null && data['success'] == true) {
          final transactions = data['data']?['analysis']?['transactions'];
          if (transactions != null && transactions.isNotEmpty) {
            final transaction = transactions[0];
            final amount = (transaction['amount'] as num?)?.toDouble() ?? 0.0;
            final category = transaction['category'] as String? ?? 'Other';
            final item = transaction['item'] as String? ?? 'Unknown';
            
            // Add to local list
            setState(() {
              _expenses.insert(0, {
                'title': item,
                'amount': amount,
                'category': category,
                'isVoice': false,
                'type': type,
              });
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ $type: $item - $amount EGP'),
                backgroundColor: const Color(0xFF10B981),
              ),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $type failed: ${result.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ $type error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}