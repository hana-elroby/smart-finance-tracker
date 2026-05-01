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
import '../../features/transactions/bloc/transaction_bloc.dart';
import '../../features/transactions/bloc/transaction_event.dart';

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
          const SnackBar(content: Text('Please allow microphone permission')),
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
        _recognizedText = 'Recording...';
      });
    } catch (e) {
      print('Error starting recording: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting recording: $e')),
      );
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _recorderController.stop();
      
      setState(() {
        _isRecording = false;
        _isProcessing = true;
        _recognizedText = 'Analyzing...';
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
            final rawCategory = t['category'] as String? ?? 'Other';
            final category = _mapServerCategoryToApp(rawCategory);
            
            // Try multiple fields for description
            final item = (t['item'] as String? ?? '').trim();
            final merchant = (t['merchant'] as String? ?? '').trim();
            final description2 = (t['description'] as String? ?? '').trim();
            final name = (t['name'] as String? ?? '').trim();
            
            // Pick best description — prefer item name, then merchant, then description
            String description = '';
            if (item.isNotEmpty && item.toLowerCase() != rawCategory.toLowerCase()) {
              description = item;
            } else if (merchant.isNotEmpty) {
              description = merchant;
            } else if (description2.isNotEmpty) {
              description = description2;
            } else if (name.isNotEmpty) {
              description = name;
            } else {
              // Fallback: use category as description
              description = category;
            }
            
            print('  💰 Transaction: "$description" - $amount EGP - $rawCategory → $category');
            print('     raw fields: item="$item" merchant="$merchant" desc="$description2"');
            
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
            _recognizedText = text.isNotEmpty ? text : 'No transactions detected';
          });
        }
      } else {
        print('❌ Server returned error');
        setState(() {
          _recognizedText = 'Analysis failed: ${result.message ?? "Unknown error"}';
        });
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _recognizedText = 'Error: $e';
      });
      print('❌ Error analyzing audio: $e');
    }
  }

  /// Trust the server category as-is.
  /// Only fix obvious mistakes where the server returned an item name instead of a category.
  String _mapServerCategoryToApp(String serverCategory) {
    final c = serverCategory.toLowerCase().trim();

    // If server returned something that looks like a food item name (not a category)
    // map it to Food & Drink
    const foodItems = [
      'chocolate', 'pizza', 'burger', 'sandwich', 'salad', 'coffee', 'tea',
      'juice', 'cake', 'bread', 'rice', 'pasta', 'sushi', 'shawarma',
      'شوكولاتة', 'بيتزا', 'برجر', 'سندوتش', 'سلطة', 'قهوة', 'شاي',
      'عصير', 'كيكة', 'خبز', 'أرز', 'مكرونة',
    ];
    for (final item in foodItems) {
      if (c == item) return 'Food & Drink'; // exact match = it's an item name, not category
    }

    // Server returned a proper category — use it as-is
    // Just normalize common variations to match our default categories
    if (c == 'food' || c == 'food & drink' || c == 'food and drink' ||
        c == 'طعام' || c == 'أكل') return 'Food & Drink';
    if (c == 'transport' || c == 'transportation' ||
        c == 'مواصلات') return 'Transport';
    if (c == 'shopping' || c == 'تسوق') return 'Shopping';
    if (c == 'health' || c == 'صحة') return 'Health';
    if (c == 'bills' || c == 'bill' || c == 'فواتير') return 'Bills';
    if (c == 'entertainment' || c == 'ترفيه') return 'Entertainment';
    if (c == 'education' || c == 'تعليم') return 'Education';

    // Unknown category → return as-is, will be created as custom category
    return serverCategory;
  }

  String _mapCategoryToArabic(String category) {
    final map = {
      'food': 'Food & Drink',
      'transport': 'Transport',
      'transportation': 'Transport',
      'shopping': 'Shopping',
      'health': 'Health',
      'education': 'Education',
      'entertainment': 'Entertainment',
      'bills': 'Bills',
      'other': 'Shopping',
    };
    return map[category.toLowerCase()] ?? _mapServerCategoryToApp(category);
  }

  IconData _getCategoryIconData(String category) {
    final c = category.toLowerCase();
    if (c.contains('food') || c.contains('drink')) return Icons.restaurant;
    if (c.contains('transport')) return Icons.directions_car;
    if (c.contains('shop')) return Icons.shopping_bag;
    if (c.contains('health')) return Icons.medical_services;
    if (c.contains('education')) return Icons.school;
    if (c.contains('entertain')) return Icons.movie;
    if (c.contains('bill')) return Icons.receipt;
    return Icons.category;
  }

  String _normalizeCategoryName(String categoryName) {
    // Remove special characters and extra spaces
    return categoryName
        .toLowerCase()
        .replaceAll(RegExp(r'[&\-_\s]+'), ' ')
        .trim();
  }

  String? _findMatchingCategory(String serverCategory) {
    // First use our smart mapper
    final mapped = _mapServerCategoryToApp(serverCategory);
    
    final dataStore = CategoryDataStore();
    final normalizedMapped = _normalizeCategoryName(mapped);
    
    // Check exact match with mapped category
    for (var cat in dataStore.allCategories) {
      if (_normalizeCategoryName(cat.name) == normalizedMapped) {
        return cat.name;
      }
    }
    
    // Check partial match
    for (var cat in dataStore.allCategories) {
      final normalizedExisting = _normalizeCategoryName(cat.name);
      if (normalizedMapped.contains(normalizedExisting) || 
          normalizedExisting.contains(normalizedMapped)) {
        return cat.name;
      }
    }
    
    // Return the mapped name directly (it's already one of our standard categories)
    return mapped;
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
        const SnackBar(content: Text('No transactions to save')),
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
      
      // Also save to TransactionBloc for persistence
      try {
        context.read<TransactionBloc>().add(AddTransaction(
          title: transaction['description'] as String,
          description: finalCategory,
          amount: transaction['amount'] as double,
          category: finalCategory,
          type: 'expense',
          date: DateTime.now(),
        ));
      } catch (_) {}
      
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
      SnackBar(content: Text('Added ${_transactions.length} transaction${_transactions.length > 1 ? 's' : ''}')),
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
                  'Voice Recording',
                  style: GoogleFonts.inter(
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
                      'Recorded text:',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[900],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: TextEditingController(text: _recognizedText),
                      maxLines: 3,
                      style: GoogleFonts.inter(
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
                        hintText: 'Edit text here...',
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
              
              // Transactions List
              Text(
                'Detected transactions:',
                style: GoogleFonts.inter(
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
                                  style: GoogleFonts.inter(
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
                                    hintText: 'Category...',
                                    hintStyle: GoogleFonts.inter(
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
                                '${transaction['amount']} EGP',
                                style: GoogleFonts.inter(
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
                            style: GoogleFonts.inter(
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
                              hintText: 'Transaction description...',
                              hintStyle: GoogleFonts.inter(
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
                      child: Text('Record again', style: GoogleFonts.inter()),
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
                        'Save All',
                        style: GoogleFonts.inter(
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
    final c = category.toLowerCase();
    if (c.contains('food') || c.contains('drink')) return Icons.restaurant;
    if (c.contains('transport')) return Icons.directions_car;
    if (c.contains('shop')) return Icons.shopping_bag;
    if (c.contains('health')) return Icons.medical_services;
    if (c.contains('education')) return Icons.school;
    if (c.contains('entertain')) return Icons.movie;
    if (c.contains('bill')) return Icons.receipt;
    return Icons.category;
  }
}
