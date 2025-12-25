// Category Filter Chips - فلتر الفئات
// Horizontal scrollable category filter

import 'package:flutter/material.dart';
import '../../../../core/models/expense_model.dart';
import '../../../../core/theme/app_colors.dart';

class CategoryFilterChips extends StatelessWidget {
  final String? selectedCategory;
  final Map<String, double> categoryTotals;
  final Function(String?) onCategorySelected;

  const CategoryFilterChips({
    super.key,
    this.selectedCategory,
    required this.categoryTotals,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // All categories chip
          _buildChip(
            label: 'All',
            emoji: '📊',
            isSelected: selectedCategory == null,
            onTap: () => onCategorySelected(null),
          ),
          const SizedBox(width: 8),

          // Category chips
          ...ExpenseCategory.values.map((category) {
            final hasExpenses = categoryTotals.containsKey(category.name);
            if (!hasExpenses && selectedCategory != category.name) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildChip(
                label: category.name,
                emoji: category.emoji,
                isSelected: selectedCategory == category.name,
                onTap: () => onCategorySelected(category.name),
                count: categoryTotals[category.name]?.toInt(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required String emoji,
    required bool isSelected,
    required VoidCallback onTap,
    int? count,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected ? Colors.white : AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
