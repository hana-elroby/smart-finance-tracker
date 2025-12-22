import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CategoryDialog extends StatelessWidget {
  final String category;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onManualEntry;
  final VoidCallback onVoiceRecording;
  final VoidCallback onViewAnalysis;

  const CategoryDialog({
    super.key,
    required this.category,
    required this.icon,
    required this.gradient,
    required this.onManualEntry,
    required this.onVoiceRecording,
    required this.onViewAnalysis,
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
            // Category Icon with Gradient
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
              'Add $category Expense',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            // Manual Entry Option
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                onManualEntry();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit, color: Colors.white, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Manual Entry',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Voice Recording Option
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                onVoiceRecording();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mic, color: gradient.colors.first, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Voice Recording',
                      style: TextStyle(
                        color: gradient.colors.first,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Analysis Option
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                onViewAnalysis();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.analytics,
                      color: gradient.colors.first,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'View Analysis',
                      style: TextStyle(
                        color: gradient.colors.first,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



