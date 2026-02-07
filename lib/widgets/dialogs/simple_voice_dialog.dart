import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../../services/voice_api_service.dart';
import '../../features/home/bloc/expense_bloc.dart';
import '../../features/home/bloc/expense_event.dart';
import '../../core/models/expense.dart';

class SimpleVoiceDialog extends StatefulWidget {
  const SimpleVoiceDialog({super.key});

  @override
  State<SimpleVoiceDialog> createState() => _SimpleVoiceDialogState();
}

class _SimpleVoiceDialogState extends State<SimpleVoiceDialog> {
  late final RecorderController _recorderController;
  final VoiceApiService _voiceApiService = VoiceApiService();
  
  bool _isRecording = false;
  bool _isProcessing = false;
  bool _showResults = false;
  String _recognizedText = '';
  String? _audioPath;
  
  // Store all transactions from server
  List<Map<String, dynamic>> _transactions = [];
  
  final List<String> _categories = [
    'طعام', 'مواصلات', 'تسوق', 'صحة', 'تعليم', 'ترفيه', 'فواتير', 'أخرى'
  ];

  @override
  void initState() {
    super.initState();
    _recorderController = RecorderController();
  }

  @override
  void dispose() {
    _recorderController.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى السماح بإذن الميكروفون')),
        );
        return;
      }

      final directory = await getTemporaryDirectory();
      _audioPath = '${directory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      
      // Record with high quality settings for better server transcription
      await _recorderController.record(
        path: _audioPath,
        bitRate: 128000, // High quality bitrate
        sampleRate: 44100, // CD quality sample rate
      );
      
      setState(() {
        _isRecording = true;
        _recognizedText = 'جاري التسجيل...';
      });
    } catch (e) {
      print('Error starting recording: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في بدء التسجيل: $e')),
      );
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _recorderController.stop();
      
      setState(() {
        _isRecording = false;
        _isProcessing = true;
        _recognizedText = 'جاري التحليل...';
      });
      
      if (path != null && path.isNotEmpty) {
        // Send directly to server (server handles Arabic better)
        await _analyzeAudioFile(File(path));
      }
    } catch (e) {
      print('Error stopping recording: $e');
      setState(() {
        _isRecording = false;
        _isProcessing = false;
      });
    }
  }

  Future<void> _analyzeAudioFile(File audioFile) async {
    try {
      print('📤 Sending audio file to server: ${audioFile.path}');
      print('📊 File size: ${await audioFile.length()} bytes');
      
      final result = await _voiceApiService.analyzeVoice(audioFile);
      
      setState(() {
        _isProcessing = false;
      });
      
      if (result.isSuccess && result.data != null) {
        print('✅ Server response received');
        print('📦 Full response data: ${result.data}');
        
        // Extract transcription
        final text = result.data['data']?['transcription'] ?? '';
        
        // Extract ALL transactions from server
        final transactionsList = result.data['data']?['analysis']?['transactions'] as List?;
        
        print('📝 Transcription: "$text"');
        print('📊 Found ${transactionsList?.length ?? 0} transactions');
        
        if (transactionsList != null && transactionsList.isNotEmpty) {
          _transactions = transactionsList.map((t) {
            final amount = (t['amount'] as num?)?.toDouble() ?? 0.0;
            final category = _mapCategoryToArabic(t['category'] as String? ?? 'other');
            final item = t['item'] as String? ?? '';
            final merchant = t['merchant'] as String? ?? '';
            final description = item.isNotEmpty ? item : merchant;
            
            print('  💰 Transaction: $description - $amount EGP - $category');
            
            return {
              'amount': amount,
              'category': category,
              'description': description,
              'original': t,
            };
          }).toList();
          
          setState(() {
            _recognizedText = text;
            _showResults = true;
          });
        } else {
          setState(() {
            _recognizedText = text.isNotEmpty ? text : 'لم يتم التعرف على معاملات';
          });
        }
      } else {
        print('❌ Server returned error');
        setState(() {
          _recognizedText = 'فشل التحليل: ${result.message ?? "خطأ غير معروف"}';
        });
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _recognizedText = 'خطأ في التحليل: $e';
      });
      print('❌ Error analyzing audio: $e');
    }
  }

  String _mapCategoryToArabic(String category) {
    final map = {
      'food': 'طعام',
      'transport': 'مواصلات',
      'transportation': 'مواصلات',
      'shopping': 'تسوق',
      'health': 'صحة',
      'education': 'تعليم',
      'entertainment': 'ترفيه',
      'bills': 'فواتير',
      'other': 'أخرى',
    };
    return map[category.toLowerCase()] ?? 'أخرى';
  }

  void _saveAllTransactions() {
    if (_transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد معاملات للحفظ')),
      );
      return;
    }
    
    final expenseBloc = context.read<ExpenseBloc>();
    
    for (final transaction in _transactions) {
      final expense = Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_${_transactions.indexOf(transaction)}',
        amount: transaction['amount'] as double,
        category: transaction['category'] as String,
        title: transaction['description'] as String,
        date: DateTime.now(),
        isVoiceInput: true,
      );
      
      expenseBloc.add(AddExpense(expense));
    }
    
    Navigator.of(context).pop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم إضافة ${_transactions.length} معاملة')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 400),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.mic, color: Color(0xFF667eea), size: 24),
                const SizedBox(width: 12),
                Text(
                  'تسجيل صوتي',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            if (!_showResults) ...[
              // Microphone Button
              GestureDetector(
                onTap: _isProcessing ? null : _toggleRecording,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _isRecording 
                        ? const Color(0xFF667eea).withValues(alpha: 0.1)
                        : _isProcessing
                            ? Colors.grey.withValues(alpha: 0.1)
                            : const Color(0xFF667eea).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _isRecording 
                          ? const Color(0xFF667eea)
                          : _isProcessing
                              ? Colors.grey
                              : const Color(0xFF667eea),
                      width: 3,
                    ),
                  ),
                  child: _isProcessing
                      ? const CircularProgressIndicator()
                      : Icon(
                          _isRecording ? Icons.stop : Icons.mic,
                          size: 40,
                          color: _isRecording 
                              ? const Color(0xFF667eea)
                              : const Color(0xFF667eea),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Status Text
              if (_recognizedText.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _recognizedText,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ] else ...[
              // Show transcription
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'النص المسجل:',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[900],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _recognizedText,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Transactions List
              Text(
                'المعاملات المكتشفة:',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = _transactions[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          // Icon based on category
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF667eea).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getCategoryIcon(transaction['category'] as String),
                              color: const Color(0xFF667eea),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  transaction['description'] as String,
                                  style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  transaction['category'] as String,
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Amount
                          Text(
                            '${transaction['amount']} جنيه',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFFF6B6B),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _showResults = false;
                          _transactions.clear();
                          _recognizedText = '';
                        });
                      },
                      child: Text('تسجيل مرة أخرى', style: GoogleFonts.cairo()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveAllTransactions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF26de81),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'حفظ الكل',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'طعام':
        return Icons.restaurant;
      case 'مواصلات':
        return Icons.directions_car;
      case 'تسوق':
        return Icons.shopping_bag;
      case 'صحة':
        return Icons.medical_services;
      case 'تعليم':
        return Icons.school;
      case 'ترفيه':
        return Icons.movie;
      case 'فواتير':
        return Icons.receipt;
      default:
        return Icons.category;
    }
  }
}
