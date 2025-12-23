import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../analysis/analysis_page.dart';
import '../bloc/expense_bloc.dart';

class HomeSpendingChart extends StatelessWidget {
  final ExpenseBloc expenseBloc;

  const HomeSpendingChart({super.key, required this.expenseBloc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Your Spending this week',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          // Bar Chart - Vertical bars with labels - centered (Design only)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Labels on the left - aligned to left
                    Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Shopping'),
                          const SizedBox(height: 24),
                          _buildLabel('Activities'),
                          const SizedBox(height: 24),
                          _buildLabel('Food'),
                          const SizedBox(height: 24),
                          _buildLabel('Bills'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Vertical Bars on the right - centered (Fixed heights for design)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildVerticalBar(0.68, AppColors.chartBar2),
                            const SizedBox(width: 12),
                            _buildVerticalBar(1.0, AppColors.chartBar1),
                            const SizedBox(width: 12),
                            _buildVerticalBar(0.83, AppColors.chartBar2),
                            const SizedBox(width: 12),
                            _buildVerticalBar(0.58, AppColors.chartBar1),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // See all button below bars
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocProvider.value(
                                  value: expenseBloc,
                                  child: const AnalysisPage(),
                                ),
                              ),
                            );
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'See all',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward,
                                size: 16,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildVerticalBar(double heightFactor, Color color) {
    return Container(
      width: 28,
      height: 200 * heightFactor,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}


