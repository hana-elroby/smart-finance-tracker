import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../categories/categories_page.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_state.dart';

class HomeCategories extends StatelessWidget {
  final Function(String category, IconData icon, LinearGradient gradient)
  onCategoryTap;
  final ExpenseBloc expenseBloc;

  const HomeCategories({
    super.key,
    required this.onCategoryTap,
    required this.expenseBloc,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Our categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: expenseBloc,
                      child: const CategoriesPage(),
                    ),
                  ),
                );
              },
              child: const Row(
                children: [
                  Text(
                    'Show More',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 16, color: Colors.black),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 3 Category Cards in a Row
        BlocBuilder<ExpenseBloc, ExpenseState>(
          builder: (context, state) {
            // Default amounts
            double shoppingTotal = 0;
            double billsTotal = 0;
            double healthTotal = 0;

            // Get totals from state if available
            if (state is ExpenseLoaded) {
              shoppingTotal = state.getCategoryTotal('Shopping');
              billsTotal = state.getCategoryTotal('Bills');
              healthTotal = state.getCategoryTotal('Health');
              print(
                '📊 Totals - Shopping: $shoppingTotal, Bills: $billsTotal, Health: $healthTotal',
              );
            }

            return Row(
              children: [
                Expanded(
                  child: _buildCategoryCard(
                    'Shopping',
                    Icons.shopping_bag,
                    '${shoppingTotal.toStringAsFixed(0)} EGP',
                    AppColors.shoppingGradient,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCategoryCard(
                    'Bills',
                    Icons.receipt_long,
                    '${billsTotal.toStringAsFixed(0)} EGP',
                    AppColors.billsGradient,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCategoryCard(
                    'Health',
                    Icons.favorite_border,
                    '${healthTotal.toStringAsFixed(0)} EGP',
                    AppColors.healthGradient,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    String title,
    IconData icon,
    String amount,
    LinearGradient gradient,
  ) {
    return Builder(
      builder: (context) {
        return GestureDetector(
          onTap: () => onCategoryTap(title, icon, gradient),
          child: Container(
            width: 140,
            height: 150,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: Colors.white, size: 32),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        amount,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
