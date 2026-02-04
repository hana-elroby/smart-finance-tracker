import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/empty_state.dart';
import '../../core/services/performance_service.dart';
import '../home/bloc/expense_bloc.dart';
import '../home/bloc/expense_state.dart';
import '../home/bloc/expense_event.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> 
    with PerformanceMonitorMixin {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    startPerformanceTracking('transactions_page_init');
    
    // Reload expenses when page opens to get latest data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.mounted) {
        try {
          context.read<ExpenseBloc>().add(const LoadExpenses());
          // Simulate loading time
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          });
        } catch (e) {
          print('⚠️ Error loading expenses in TransactionsPage: $e');
          setState(() {
            _isLoading = false;
          });
        }
      }
    });
    
    endPerformanceTracking('transactions_page_init');
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EEF5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Transaction',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading 
        ? _buildLoadingState()
        : BlocBuilder<ExpenseBloc, ExpenseState>(
            builder: (context, state) {
              if (state is ExpenseLoading) {
                return _buildLoadingState();
              }
              
              if (state is ExpenseLoaded) {
                final expenses = List.from(state.expenses)
                  ..sort((a, b) => b.date.compareTo(a.date));
                
                if (expenses.isEmpty) {
                  return _buildEmptyState();
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return _buildTransactionCard(
                      expense.title,
                      expense.amount,
                      expense.date,
                  expense.isVoiceInput, // Pass voice input flag
                );
              },
            );
          }
          
          return _buildEmptyState();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyStates.noTransactions(
      onAddTransaction: () {
        Navigator.pop(context);
        // Navigate to add transaction
      },
    );
  }

  Widget _buildTransactionCard(String name, double amount, DateTime date, bool isVoiceInput) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    // Voice indicator icon
                    if (isVoiceInput) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.mic_rounded,
                          size: 14,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(date),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Text(
            'EGP${amount.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SkeletonLoaders.transactionList(itemCount: 8),
    );
  }
}
