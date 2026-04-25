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
import '../../features/categories/bloc/category_bloc.dart';
import '../../features/categories/category_data_store.dart';

class SimpleVoiceDialog extends StatefulWidget {
  final ExpenseBloc expenseBloc;
  final CategoryBloc categoryBloc;
  
  const SimpleVoiceDialog({
    super.key,
    required this.expenseBloc,
    required this.categoryBloc,
  });

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
            // Keep category as-is from server (don't translate)
            final category = t['category'] as String? ?? 'Other';
            final item = t['item'] as String? ?? '';
            final merchant = t['merchant'] as String? ?? '';
            final description = item.isNotEmpty ? item : merchant;
            
            print('  💰 Transaction: $description - $amount EGP - $category');
            
            return {
              'amount': amount,
              'category': category, // Keep original from server
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

  IconData _getCategoryIconData(String category) {
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

  String _normalizeCategoryName(String categoryName) {
    // Remove special characters and extra spaces
    return categoryName
        .toLowerCase()
        .replaceAll(RegExp(r'[&\-_\s]+'), ' ')
        .trim();
  }

  String? _findMatchingCategory(String serverCategory) {
    final dataStore = CategoryDataStore();
    final normalizedServer = _normalizeCategoryName(serverCategory);
    
    // Check exact match first
    for (var cat in dataStore.allCategories) {
      if (_normalizeCategoryName(cat.name) == normalizedServer) {
        return cat.name;
      }
    }
    
    // Check if server category contains existing category name
    for (var cat in dataStore.allCategories) {
      final normalizedExisting = _normalizeCategoryName(cat.name);
      if (normalizedServer.contains(normalizedExisting) || 
          normalizedExisting.contains(normalizedServer)) {
        return cat.name; // Use existing category
      }
    }
    
    // No match found, return original
    return null;
  }

  Future<void> _ensureCategoryExists(String categoryName) async {
    final dataStore = CategoryDataStore();
    
    // Try to find matching category first
    final matchingCategory = _findMatchingCategory(categoryName);
    if (matchingCategory != null) {
      print('✅ Found matching category: $matchingCategory for $categoryName');
      return; // Use existing category
    }
    
    // Check if exact category exists
    final existingCategory = dataStore.findCategory(categoryName);
    
    if (existingCategory == null) {
      print('📝 Creating new category: $categoryName');
      
      final icon = _getCategoryIconData(categoryName);
      widget.categoryBloc.add(AddCategory(name: categoryName, icon: icon));
      
      final newCategory = CategoryData(
        name: categoryName,
        icon: icon,
        color: const Color(0xFF667eea),
        isMain: false,
      );
      dataStore.addCustomCategory(newCategory);
      
      print('✅ Category created: $categoryName');
    } else {
      print('✅ Category already exists: $categoryName');
    }
  }

  void _saveAllTransactions() async {
    if (_transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد معاملات للحفظ')),
      );
      return;
    }
    
    final dataStore = CategoryDataStore();
    
    // First, ensure all categories exist and get final category names
    final Map<int, String> finalCategoryNames = {};
    for (int i = 0; i < _transactions.length; i++) {
      final serverCategory = _transactions[i]['category'] as String;
      final matchingCategory = _findMatchingCategory(serverCategory);
      final finalCategory = matchingCategory ?? serverCategory;
      
      finalCategoryNames[i] = finalCategory;
      await _ensureCategoryExists(finalCategory);
    }
    
    // Then add all transactions and items to categories
    for (int i = 0; i < _transactions.length; i++) {
      final transaction = _transactions[i];
      final finalCategory = finalCategoryNames[i]!;
      
      // Add expense
      final expense = Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_$i',
        amount: transaction['amount'] as double,
        category: finalCategory,
        title: transaction['description'] as String,
        date: DateTime.now(),
        isVoiceInput: true,
      );
      
      widget.expenseBloc.add(AddExpense(expense));
      
      // Add item to category
      final categoryItem = CategoryItem(
        name: transaction['description'] as String,
        quantity: 1,
        unitPrice: transaction['amount'] as double,
        date: DateTime.now(),
        source: 'voice',
      );
      
      dataStore.addItemToCategory(finalCategory, categoryItem);
      print('✅ Added item "${categoryItem.name}" to category "$finalCategory"');
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
              // Show transcription - EDITABLE
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
                    const SizedBox(height: 8),
                    TextField(
                      controller: TextEditingController(text: _recognizedText),
                      maxLines: 3,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                        hintText: 'عدّل النص هنا...',
                        hintStyle: GoogleFonts.cairo(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
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
                              
                              // Editable category field
                              Expanded(
                                child: TextField(
                                  controller: TextEditingController(
                                    text: transaction['category'] as String,
                                  ),
                                  maxLines: 1,
                                  style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF667eea),
                                  ),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: const Color(0xFF667eea).withValues(alpha: 0.05),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: const Color(0xFF667eea).withValues(alpha: 0.2)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: const Color(0xFF667eea).withValues(alpha: 0.2)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF667eea),
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    hintText: 'الفئة...',
                                    hintStyle: GoogleFonts.cairo(
                                      fontSize: 14,
                                      color: Colors.grey[400],
                                    ),
                                    isDense: true,
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _transactions[index]['category'] = value;
                                    });
                                  },
                                ),
                              ),
                              
                              const SizedBox(width: 12),
                              
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
                          const SizedBox(height: 10),
                          
                          // Editable description field
                          TextField(
                            controller: TextEditingController(
                              text: transaction['description'] as String,
                            ),
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFF667eea),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              hintText: 'وصف المعاملة...',
                              hintStyle: GoogleFonts.cairo(
                                fontSize: 14,
                                color: Colors.grey[400],
                              ),
                              prefixIcon: Icon(
                                Icons.edit,
                                size: 18,
                                color: Colors.grey[400],
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _transactions[index]['description'] = value;
                              });
                            },
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
    final lowerCategory = category.toLowerCase();
    
    // Support both English and Arabic
    if (lowerCategory.contains('food') || lowerCategory.contains('طعام')) {
      return Icons.restaurant;
    } else if (lowerCategory.contains('transport') || lowerCategory.contains('مواصلات')) {
      return Icons.directions_car;
    } else if (lowerCategory.contains('shopping') || lowerCategory.contains('تسوق')) {
      return Icons.shopping_bag;
    } else if (lowerCategory.contains('health') || lowerCategory.contains('صحة')) {
      return Icons.medical_services;
    } else if (lowerCategory.contains('education') || lowerCategory.contains('تعليم')) {
      return Icons.school;
    } else if (lowerCategory.contains('entertainment') || lowerCategory.contains('ترفيه')) {
      return Icons.movie;
    } else if (lowerCategory.contains('bill') || lowerCategory.contains('فواتير')) {
      return Icons.receipt;
    } else {
      return Icons.category;
    }
  }
}
