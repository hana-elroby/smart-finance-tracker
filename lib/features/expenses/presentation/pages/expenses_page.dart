// Expenses Page - صفحة المصاريف
// Main page for viewing and managing expenses

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/models/expense_model.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../bloc/expense_state.dart';
import '../widgets/expense_card.dart';
import '../widgets/expense_summary_card.dart';
import '../widgets/category_filter_chips.dart';
import 'add_expense_page.dart';

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExpenseBloc()..add(const LoadExpenses()),
      child: const _ExpensesPageContent(),
    );
  }
}

class _ExpensesPageContent extends StatelessWidget {
  const _ExpensesPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Expenses'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Sync button
          BlocBuilder<ExpenseBloc, ExpenseState>(
            builder: (context, state) {
              return Stack(
                children: [
                  IconButton(
                    icon: state.isSyncing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.sync),
                    onPressed: state.isSyncing
                        ? null
                        : () {
                            context.read<ExpenseBloc>().add(const SyncExpenses());
                          },
                  ),
                  if (state.unsyncedCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${state.unsyncedCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          // Search button
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: BlocConsumer<ExpenseBloc, ExpenseState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.expenses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ExpenseBloc>().add(const LoadExpenses());
            },
            child: CustomScrollView(
              slivers: [
                // Summary cards
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ExpenseSummaryCard(
                      totalAmount: state.totalAmount,
                      todayTotal: state.todayTotal,
                      weekTotal: state.weekTotal,
                      monthTotal: state.monthTotal,
                    ),
                  ),
                ),

                // Category filter chips
                SliverToBoxAdapter(
                  child: CategoryFilterChips(
                    selectedCategory: state.selectedCategory,
                    categoryTotals: state.categoryTotals,
                    onCategorySelected: (category) {
                      context
                          .read<ExpenseBloc>()
                          .add(FilterByCategory(category));
                    },
                  ),
                ),

                // Clear filters button
                if (state.hasFilters)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextButton.icon(
                        onPressed: () {
                          context.read<ExpenseBloc>().add(const ClearFilter());
                        },
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear Filters'),
                      ),
                    ),
                  ),

                // Expenses list
                if (state.filteredExpenses.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No expenses yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap + to add your first expense',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final expense = state.filteredExpenses[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ExpenseCard(
                              expense: expense,
                              onDelete: () => _confirmDelete(context, expense),
                              onTap: () => _showExpenseDetails(context, expense),
                            ),
                          );
                        },
                        childCount: state.filteredExpenses.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddExpense(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Expense',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _navigateToAddExpense(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddExpensePage()),
    );

    if (result == true && context.mounted) {
      context.read<ExpenseBloc>().add(const LoadExpenses());
    }
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Search Expenses'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Search by title, category...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              context.read<ExpenseBloc>().add(SearchExpenses(value));
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.read<ExpenseBloc>().add(const ClearFilter());
                Navigator.pop(dialogContext);
              },
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Expense'),
          content: Text('Are you sure you want to delete "${expense.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<ExpenseBloc>().add(
                      DeleteExpense(
                        id: expense.id!,
                        firestoreId: expense.firestoreId,
                      ),
                    );
                Navigator.pop(dialogContext);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showExpenseDetails(BuildContext context, Expense expense) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      expense.categoryEnum.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          expense.category ?? 'Other',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    expense.formattedAmount,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (expense.description != null &&
                  expense.description!.isNotEmpty) ...[
                const Text(
                  'Description',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(expense.description!),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(expense.date),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Icon(
                    expense.isSyncedToCloud ? Icons.cloud_done : Icons.cloud_off,
                    size: 16,
                    color: expense.isSyncedToCloud ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    expense.isSyncedToCloud ? 'Synced' : 'Pending sync',
                    style: TextStyle(
                      color: expense.isSyncedToCloud ? Colors.green : Colors.orange,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    return '${date.day}/${date.month}/${date.year}';
  }
}
