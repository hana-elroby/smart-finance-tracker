import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/empty_state.dart';
import 'bloc/transaction_bloc.dart';
import 'bloc/transaction_event.dart';
import 'bloc/transaction_state.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TransactionBloc>().add(const LoadTransactions());
      }
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
        automaticallyImplyLeading: false,
        title: Text('Transaction', style: GoogleFonts.inter(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state.isLoading) return _buildLoadingState();
          final transactions = state.transactions;
          if (transactions.isEmpty) return _buildEmptyState();
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final t = transactions[index];
              return Dismissible(
                key: Key(t.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                  alignment: Alignment.centerRight,
                  child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                ),
                onDismissed: (_) {
                  context.read<TransactionBloc>().add(DeleteTransaction(t.id));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${t.title} deleted'), duration: const Duration(seconds: 2)),
                  );
                },
                child: _buildTransactionCard(t.title, t.amount, t.date),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() => EmptyStates.noTransactions(onAddTransaction: () {});

  Widget _buildTransactionCard(String name, double amount, DateTime date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(name, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black87), overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 8),
          Expanded(flex: 3, child: Text(_formatDate(date), style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[500]), textAlign: TextAlign.center)),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(child: Text(amount.toStringAsFixed(2), style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 3),
                Text('EGP', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() => Padding(
    padding: const EdgeInsets.all(20),
    child: SkeletonLoaders.transactionList(itemCount: 8),
  );
}
