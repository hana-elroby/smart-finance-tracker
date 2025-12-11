import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Analysis Page - عرض تحليل المصروفات
/// يعرض إجمالي المصروفات والتحليل الأسبوعي والتقسيم حسب الفئات
class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Spending Analysis',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Summary Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.notificationGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Spending',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '2,667 EGP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildSummaryItem('This Week', '690 EGP'),
                      const SizedBox(width: 24),
                      _buildSummaryItem('This Month', '2,667 EGP'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Weekly Chart
            const Text(
              'Weekly Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildWeekBar('Mon', 120, 200),
                      _buildWeekBar('Tue', 180, 200),
                      _buildWeekBar('Wed', 150, 200),
                      _buildWeekBar('Thu', 190, 200),
                      _buildWeekBar('Fri', 160, 200),
                      _buildWeekBar('Sat', 140, 200),
                      _buildWeekBar('Sun', 110, 200),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Category Breakdown
            const Text(
              'By Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildCategoryBreakdown(
              'Shopping',
              '670 EGP',
              0.25,
              AppColors.shoppingGradient.colors.first,
            ),
            _buildCategoryBreakdown(
              'Bills',
              '580 EGP',
              0.22,
              AppColors.billsGradient.colors.first,
            ),
            _buildCategoryBreakdown(
              'Activities',
              '450 EGP',
              0.17,
              AppColors.activitiesGradient.colors.first,
            ),
            _buildCategoryBreakdown(
              'Food',
              '397 EGP',
              0.15,
              AppColors.foodGradient.colors.first,
            ),
            _buildCategoryBreakdown(
              'Health',
              '220 EGP',
              0.08,
              AppColors.healthGradient.colors.first,
            ),
            _buildCategoryBreakdown(
              'Education',
              '200 EGP',
              0.08,
              AppColors.educationGradient.colors.first,
            ),
            _buildCategoryBreakdown(
              'Entertainment',
              '150 EGP',
              0.05,
              AppColors.entertainmentGradient.colors.first,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildWeekBar(String day, double height, double maxHeight) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 35,
          height: height,
          decoration: BoxDecoration(
            color: height > 150 ? AppColors.chartBar2 : AppColors.chartBar1,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown(
    String category,
    String amount,
    double percentage,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                amount,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
