import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Categories Page - عرض جميع الفئات
/// يعرض جميع فئات المصروفات في شكل Grid
class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

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
          'All Categories',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.9,
          children: [
            _buildCategoryCard(
              'Shopping',
              Icons.shopping_bag,
              '670 EGP',
              AppColors.shoppingGradientLight,
            ),
            _buildCategoryCard(
              'Bills',
              Icons.receipt_long,
              '580 EGP',
              AppColors.billsGradientLight,
            ),
            _buildCategoryCard(
              'Health',
              Icons.favorite,
              '220 EGP',
              AppColors.healthGradientLight,
            ),
            _buildCategoryCard(
              'Activities',
              Icons.sports_soccer,
              '450 EGP',
              AppColors.activitiesGradientLight,
            ),
            _buildCategoryCard(
              'Food & Drink',
              Icons.restaurant,
              '397 EGP',
              AppColors.foodGradientLight,
            ),
            _buildCategoryCard(
              'Education',
              Icons.school,
              '200 EGP',
              AppColors.educationGradientLight,
            ),
            _buildCategoryCard(
              'Entertainment',
              Icons.movie,
              '150 EGP',
              AppColors.entertainmentGradientLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    String title,
    IconData icon,
    String amount,
    LinearGradient gradient,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
    );
  }
}
