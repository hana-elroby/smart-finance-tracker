import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home/bloc/expense_bloc.dart';
import '../home/bloc/expense_state.dart';
import '../home/bloc/expense_event.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  @override
  void initState() {
    super.initState();
    // Reload expenses when page opens to get latest data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseBloc>().add(const LoadExpenses());
    });
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
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          if (state is ExpenseLoading) {
            return const Center(child: CircularProgressIndicator());
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: GoogleFonts.inter(fontSize: 18, color: Colors.grey[400]),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items to categories to see them here',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(String name, double amount, DateTime date) {
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
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
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
}
