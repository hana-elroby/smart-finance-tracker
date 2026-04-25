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

  @override
  void initState() {
    super.initState();
    startPerformanceTracking('transactions_page_init');
    
    // Reload expenses when page opens to get latest data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.mounted) {
        try {
          context.read<ExpenseBloc>().add(const LoadExpenses());
        } catch (e) {
          print('⚠️ Error loading expenses in TransactionsPage: $e');
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
        automaticallyImplyLeading: false, // Remove back button
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
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
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
                  physics: const AlwaysScrollableScrollPhysics(), // Always scrollable
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return Dismissible(
                      key: Key(expense.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerRight,
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      onDismissed: (direction) {
                        // Delete the expense
                        context.read<ExpenseBloc>().add(DeleteExpense(expense.id));
                        
                        // Show snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${expense.title} deleted'),
                            duration: const Duration(seconds: 2),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () {
                                // Add back the expense
                                context.read<ExpenseBloc>().add(AddExpense(expense));
                              },
                            ),
                          ),
                        );
                      },
                      child: _buildTransactionCard(
                        expense.title,
                        expense.amount,
                        expense.date,
                        expense.isVoiceInput,
                      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Left: Name with voice indicator
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Voice indicator icon
                if (isVoiceInput) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.mic_rounded,
                      size: 12,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Center: Date
          Expanded(
            flex: 3,
            child: Text(
              _formatDate(date),
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Right: Amount then Currency
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    amount.toStringAsFixed(2),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  'EGP',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ],
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
