import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import '../bloc/expense_bloc.dart';
import '../bloc/expense_state.dart';
import '../bloc/expense_event.dart';
import '../../../core/models/expense.dart';

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      child: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          if (state is! ExpenseLoaded) {
            return Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const CircularProgressIndicator(),
            );
          }

          // Filter expenses for this category
          final categoryExpenses = state.expenses
              .where((expense) => expense.category == category)
              .toList();

          if (categoryExpenses.isEmpty) {
            return Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 40, color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No expenses in $category yet',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Calculate total
          final total = categoryExpenses.fold<double>(
            0,
            (sum, expense) => sum + expense.amount,
          );

          // Group expenses by title for pie chart
          final Map<String, double> itemTotals = {};
          final Map<String, int> itemCounts = {};

          for (var expense in categoryExpenses) {
            final desc = expense.title.isEmpty ? category : expense.title;
            itemTotals[desc] = (itemTotals[desc] ?? 0) + expense.amount;
            itemCounts[desc] = (itemCounts[desc] ?? 0) + 1;
          }

          // Sort items by amount (descending)
          final sortedItems = itemTotals.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FD),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF4A90E2), width: 3),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      '$category Analysis',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Budget Spent . Last 30 days',
                      style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 32),

                    // Pie Chart and Legend
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pie Chart
                        SizedBox(
                          width: 140,
                          height: 140,
                          child: CustomPaint(
                            painter: PieChartPainter(
                              data: sortedItems.take(4).toList(),
                              total: total,
                              baseColors: gradient.colors,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),

                        // Legend
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: sortedItems.take(4).map((item) {
                              final index = sortedItems.indexOf(item);
                              final percentage = (item.value / total * 100)
                                  .round();
                              final color = _getShadeColor(
                                gradient.colors,
                                index,
                              );

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        item.key,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black87,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '$percentage%',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Breakdown Section
                    const Text(
                      'Breakdown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Items List
                    ...sortedItems.map((item) {
                      final percentage = (item.value / total * 100).round();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.key,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$percentage% of $category Category',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${item.value.toInt()} EGP',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => _showDeleteDialog(
                                context,
                                item.key,
                                categoryExpenses,
                              ),
                              icon: Icon(
                                Icons.delete_outline,
                                color: Colors.red[400],
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getShadeColor(List<Color> baseColors, int index) {
    final baseColor = baseColors[0];
    final shades = [
      baseColor,
      Color.lerp(baseColor, Colors.white, 0.3)!,
      Color.lerp(baseColor, Colors.white, 0.5)!,
      Color.lerp(baseColor, Colors.black, 0.2)!,
    ];
    return shades[index % shades.length];
  }

  void _showDeleteDialog(
    BuildContext context,
    String itemDescription,
    List<Expense> categoryExpenses,
  ) {
    final expensesToDelete = categoryExpenses
        .where((e) => (e.title.isEmpty ? category : e.title) == itemDescription)
        .toList();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Expenses'),
        content: Text(
          'Delete all ${expensesToDelete.length} expense(s) for "$itemDescription"?\n\nThis will remove them from all analysis.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Delete all matching expenses
              for (var expense in expensesToDelete) {
                context.read<ExpenseBloc>().add(DeleteExpense(expense.id));
              }
              Navigator.pop(dialogContext);
              Navigator.pop(context); // Close analysis dialog too
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Deleted ${expensesToDelete.length} expense(s)',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final List<MapEntry<String, double>> data;
  final double total;
  final List<Color> baseColors;

  PieChartPainter({
    required this.data,
    required this.total,
    required this.baseColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    double startAngle = -math.pi / 2; // Start from top

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final sweepAngle = (item.value / total) * 2 * math.pi;

      final color = _getShadeColor(i);
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  Color _getShadeColor(int index) {
    final baseColor = baseColors[0];
    final shades = [
      baseColor,
      Color.lerp(baseColor, Colors.white, 0.3)!,
      Color.lerp(baseColor, Colors.white, 0.5)!,
      Color.lerp(baseColor, Colors.black, 0.2)!,
    ];
    return shades[index % shades.length];
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

