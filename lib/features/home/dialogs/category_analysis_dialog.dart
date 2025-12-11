import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CategoryAnalysisDialog extends StatelessWidget {
  final String category;
  final IconData icon;
  final LinearGradient gradient;

  const CategoryAnalysisDialog({
    super.key,
    required this.category,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: gradient,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              '$category Analysis',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildAnalysisRow(
                    'Total Spent',
                    '650 EGP',
                    gradient.colors.first,
                  ),
                  const SizedBox(height: 12),
                  _buildAnalysisRow(
                    'Transactions',
                    '12',
                    gradient.colors.first,
                  ),
                  const SizedBox(height: 12),
                  _buildAnalysisRow(
                    'Average',
                    '54.17 EGP',
                    gradient.colors.first,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: gradient.colors.first,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
