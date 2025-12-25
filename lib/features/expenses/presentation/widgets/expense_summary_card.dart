// Expense Summary Card - كارت ملخص المصاريف
// Displays expense totals and statistics

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ExpenseSummaryCard extends StatelessWidget {
  final double totalAmount;
  final double todayTotal;
  final double weekTotal;
  final double monthTotal;

  const ExpenseSummaryCard({
    super.key,
    required this.totalAmount,
    required this.todayTotal,
    required this.weekTotal,
    required this.monthTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            Color(0xFF0277BD),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Expenses',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${totalAmount.toStringAsFixed(2)} EGP',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatItem('Today', todayTotal),
              const SizedBox(width: 24),
              _buildStatItem('This Week', weekTotal),
              const SizedBox(width: 24),
              _buildStatItem('This Month', monthTotal),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, double amount) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${amount.toStringAsFixed(0)} EGP',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
