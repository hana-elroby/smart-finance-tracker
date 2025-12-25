// Add Transaction Page - صفحة إضافة معاملة
// Page for adding new transactions via text, voice, or OCR

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _textController = TextEditingController();
  final _priceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  File? _recordedVoice;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Transaction'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.edit), text: 'Text'),
            Tab(icon: Icon(Icons.mic), text: 'Voice'),
            Tab(icon: Icon(Icons.camera_alt), text: 'Receipt'),
          ],
        ),
      ),
      body: BlocConsumer<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              TabBarView(
                controller: _tabController,
                children: [
                  _buildTextTab(state),
                  _buildVoiceTab(state),
                  _buildOcrTab(state),
                ],
              ),
              if (state.isCreating || state.isAnalyzing)
                Container(
                  color: Colors.black26,
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }

  // Text input tab
  Widget _buildTextTab(TransactionState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Description field
            TextFormField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'e.g., Coffee at Starbucks',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Price field
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Amount (EGP)',
                hintText: '0.00',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // AI Analysis button
            OutlinedButton.icon(
              onPressed: _textController.text.isNotEmpty
                  ? () {
                      context.read<TransactionBloc>().add(
                            AnalyzeText(_textController.text),
                          );
                    }
                  : null,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Analyze with AI'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            // Show AI analysis results
            if (state.hasAnalysis) ...[
              const SizedBox(height: 16),
              _buildAnalysisResults(state),
            ],

            const SizedBox(height: 24),

            // Submit button
            ElevatedButton(
              onPressed: state.isCreating ? null : _submitTextTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Add Transaction',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Voice input tab
  Widget _buildVoiceTab(TransactionState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Recording indicator
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: _isRecording ? Colors.red.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isRecording ? Icons.mic : Icons.mic_none,
              size: 80,
              color: _isRecording ? Colors.red : Colors.grey,
            ),
          ),
          const SizedBox(height: 24),

          // Record button
          ElevatedButton.icon(
            onPressed: _toggleRecording,
            icon: Icon(_isRecording ? Icons.stop : Icons.mic),
            label: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isRecording ? Colors.red : AppColors.primary,
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          if (_recordedVoice != null) ...[
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.audio_file, color: AppColors.primary),
                title: const Text('Voice recorded'),
                subtitle: const Text('Ready to analyze'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => setState(() => _recordedVoice = null),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Price field for voice
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Amount (EGP) - Optional',
                hintText: 'AI will extract if not provided',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),

            // Analyze voice button
            OutlinedButton.icon(
              onPressed: () {
                context.read<TransactionBloc>().add(AnalyzeVoice(_recordedVoice!));
              },
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Analyze Voice'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            // Show AI analysis results
            if (state.hasAnalysis) ...[
              const SizedBox(height: 16),
              _buildAnalysisResults(state),
            ],

            const SizedBox(height: 24),

            // Submit button
            ElevatedButton(
              onPressed: state.isCreating ? null : _submitVoiceTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Add Voice Transaction',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // OCR/Receipt tab
  Widget _buildOcrTab(TransactionState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image preview or placeholder
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
              image: _selectedImage != null
                  ? DecorationImage(
                      image: FileImage(_selectedImage!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _selectedImage == null
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 60, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('No receipt selected', style: TextStyle(color: Colors.grey)),
                    ],
                  )
                : null,
          ),
          const SizedBox(height: 16),

          // Image picker buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (_selectedImage != null) ...[
            const SizedBox(height: 16),

            // Price field for OCR
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Amount (EGP) - Optional',
                hintText: 'AI will extract from receipt',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),

            // Analyze image button
            OutlinedButton.icon(
              onPressed: () {
                context.read<TransactionBloc>().add(AnalyzeImage(_selectedImage!));
              },
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Analyze Receipt'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            // Show AI analysis results
            if (state.hasAnalysis) ...[
              const SizedBox(height: 16),
              _buildAnalysisResults(state),
            ],

            const SizedBox(height: 24),

            // Submit button
            ElevatedButton(
              onPressed: state.isCreating ? null : _submitOcrTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Add Receipt Transaction',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // AI Analysis results widget
  Widget _buildAnalysisResults(TransactionState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'AI Analysis',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    context.read<TransactionBloc>().add(const ClearAnalysis());
                  },
                ),
              ],
            ),
            if (state.extractedText != null) ...[
              const Divider(),
              Text('Extracted: ${state.extractedText}'),
            ],
            if (state.aiAnalyses.isNotEmpty) ...[
              const Divider(),
              ...state.aiAnalyses.map((analysis) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(child: Text(analysis.item)),
                        Text(
                          '${analysis.price.toStringAsFixed(2)} EGP',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  // Actions
  void _submitTextTransaction() {
    if (_formKey.currentState!.validate()) {
      final price = double.parse(_priceController.text);
      context.read<TransactionBloc>().add(
            CreateTextTransaction(
              text: _textController.text,
              price: price,
            ),
          );
    }
  }

  void _submitVoiceTransaction() {
    if (_recordedVoice == null) return;
    final price = double.tryParse(_priceController.text) ?? 0;
    context.read<TransactionBloc>().add(
          CreateVoiceTransaction(
            voiceFile: _recordedVoice!,
            price: price,
          ),
        );
  }

  void _submitOcrTransaction() {
    if (_selectedImage == null) return;
    final price = double.tryParse(_priceController.text) ?? 0;
    context.read<TransactionBloc>().add(
          CreateOcrTransaction(
            imageFile: _selectedImage!,
            price: price,
          ),
        );
  }

  void _toggleRecording() {
    // TODO: Implement actual voice recording with record package
    setState(() {
      _isRecording = !_isRecording;
      if (!_isRecording) {
        // Simulating recorded file - replace with actual recording
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Voice recording feature coming soon!')),
        );
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }
}
