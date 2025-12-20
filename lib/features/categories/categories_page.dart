import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../home/bloc/expense_bloc.dart';
import '../home/bloc/expense_state.dart';
import '../items/items_page.dart';
import '../../widgets/chart_placeholder.dart';
import '../../widgets/dialogs/add_category_dialog.dart';

/// Categories Page - عرض الفئات مع Pie Chart
/// يعرض pie chart ديناميك وقائمة الفئات
class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CategoriesPageContent();
  }
}

class _CategoriesPageContent extends StatefulWidget {
  const _CategoriesPageContent();

  @override
  State<_CategoriesPageContent> createState() => _CategoriesPageContentState();
}

class _CategoriesPageContentState extends State<_CategoriesPageContent> {
  DateTime? _fromDate;
  DateTime? _toDate;

  // Default categories that cannot be deleted
  final List<Map<String, dynamic>> _defaultCategories = [
    {'name': 'Food & Drink', 'icon': Icons.restaurant, 'isDefault': true},
    {'name': 'Shopping', 'icon': Icons.shopping_bag, 'isDefault': true},
    {'name': 'Bills', 'icon': Icons.receipt, 'isDefault': true},
    {'name': 'Health', 'icon': Icons.favorite, 'isDefault': true},
  ];

  // Custom categories added by user (can be deleted)
  List<Map<String, dynamic>> _customCategories = [];

  @override
  void initState() {
    super.initState();
    _setDefaultDates();
  }

  void _setDefaultDates() {
    final now = DateTime.now();
    setState(() {
      _fromDate = DateTime(
        now.year,
        now.month,
        1,
      ); // First day of current month
      _toDate = now; // Today
    });
  }

  List<Map<String, dynamic>> get _allCategories => [
    ..._defaultCategories,
    ..._customCategories,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // No back button - this is a tab page
        title: Text(
          'Categories',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Date Selectors
            _buildDateSelectors(),

            const SizedBox(height: 30),

            // Pie Chart
            _buildPieChart(),

            const SizedBox(height: 30),

            // Categories List
            _buildCategoriesList(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelectors() {
    return Row(
      children: [
        SizedBox(
          width: 160,
          child: _buildSimpleDateField(
            label: 'From',
            date: _fromDate,
            onTap: () => _selectFromDate(),
          ),
        ),
        const Spacer(),
        SizedBox(
          width: 160,
          child: _buildSimpleDateField(
            label: 'To',
            date: _toDate,
            onTap: () => _selectToDate(),
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF1687F0).withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1687F0).withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              color: const Color(0xFF1687F0),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              '$label: ${date != null ? '${date.day}/${date.month}' : 'Select'}',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        // Show placeholder when no data exists
        if (state is ExpenseLoaded && state.isEmpty) {
          return const ChartPlaceholder(
            title: 'Spending by Category',
            height: 150,
            type: ChartPlaceholderType.pie,
          );
        }

        Map<String, double> categoryTotals = {};
        double totalAmount = 0;

        if (state is ExpenseLoaded && state.hasData) {
          // Calculate totals for ALL categories (default + custom)
          for (var cat in _allCategories) {
            final name = cat['name'] as String;
            final total = state.getCategoryTotal(name);
            if (total > 0) {
              categoryTotals[name] = total;
            }
          }

          totalAmount = categoryTotals.values.fold(
            0,
            (sum, amount) => sum + amount,
          );
        }

        // If still no data after calculation, show placeholder
        if (totalAmount == 0) {
          return const ChartPlaceholder(
            title: 'Spending by Category',
            height: 150,
            type: ChartPlaceholderType.pie,
          );
        }

        return SizedBox(
          width: 220,
          height: 220,
          child: CustomPaint(
            painter: PieChartPainter(categoryTotals, totalAmount),
          ),
        );
      },
    );
  }

  Widget _buildCategoriesList() {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        // Get category totals from real data
        Map<String, double> categoryTotals = {};
        if (state is ExpenseLoaded) {
          for (var cat in _allCategories) {
            final name = cat['name'] as String;
            categoryTotals[name] = state.getCategoryTotal(name);
          }
        }

        return Column(
          children: [
            // Default Categories (4 main ones)
            ..._defaultCategories.map((category) {
              final amount = categoryTotals[category['name']] ?? 0;
              return _buildCategoryItem(
                category['name'] as String,
                category['icon'] as IconData,
                const Color(0xFF1976D2),
                amount,
                isDefault: true,
              );
            }),

            // Custom Categories (can be deleted)
            ..._customCategories.map((category) {
              final amount = categoryTotals[category['name']] ?? 0;
              return _buildCategoryItem(
                category['name'] as String,
                category['icon'] as IconData,
                const Color(0xFF1976D2),
                amount,
                isDefault: false,
                onDelete: () => _deleteCategory(category['name'] as String),
              );
            }),

            const SizedBox(height: 16),

            // Add Category Button
            _buildAddCategoryButton(),
          ],
        );
      },
    );
  }

  Widget _buildAddCategoryButton() {
    return GestureDetector(
      onTap: _addNewCategory,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: const Color(0xFF1976D2).withValues(alpha: 0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Color(0xFF1976D2),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Add Category',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1976D2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addNewCategory() async {
    HapticFeedback.lightImpact();
    final result = await showAddCategoryDialog(context);
    if (result != null) {
      setState(() {
        _customCategories.add({
          'name': result['name'],
          'icon': result['icon'],
          'isDefault': false,
        });
      });
    }
  }

  void _deleteCategory(String name) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Category',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete "$name"?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _customCategories.removeWhere((cat) => cat['name'] == name);
              });
            },
            child: Text('Delete', style: GoogleFonts.inter(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    String name,
    IconData icon,
    Color color,
    double amount, {
    bool isDefault = true,
    VoidCallback? onDelete,
  }) {
    return GestureDetector(
      onTap: () {
        // Pass the existing ExpenseBloc to ItemsPage
        final expenseBloc = context.read<ExpenseBloc>();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: expenseBloc,
              child: ItemsPage(
                categoryName: name,
                categoryIcon: icon,
                categoryColor: color,
              ),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Text(
              'EGP ${amount.toInt()}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            // Delete button for custom categories only
            if (!isDefault && onDelete != null) ...[
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                    size: 18,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _selectFromDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _fromDate) {
      setState(() {
        _fromDate = picked;
      });
    }
  }

  Future<void> _selectToDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? DateTime.now(),
      firstDate: _fromDate ?? DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _toDate) {
      setState(() {
        _toDate = picked;
      });
    }
  }
}

class PieChartPainter extends CustomPainter {
  final Map<String, double> categoryTotals;
  final double totalAmount;

  PieChartPainter(this.categoryTotals, this.totalAmount);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;

    final colors = [
      const Color(0xFF1976D2), // Food - Dark Blue
      const Color(0xFF2196F3), // Shopping - Blue
      const Color(0xFF64B5F6), // Bills - Light Blue
      const Color(0xFF90CAF9), // Health - Lighter Blue
      const Color(0xFFBBDEFB), // Transport - Very Light Blue
      const Color(0xFFE3F2FD), // Entertainment - Pale Blue
    ];

    double startAngle = -math.pi / 2; // Start from top
    int colorIndex = 0;

    categoryTotals.forEach((category, amount) {
      if (amount > 0) {
        final sweepAngle = (amount / totalAmount) * 2 * math.pi;

        final paint = Paint()
          ..color = colors[colorIndex % colors.length]
          ..style = PaintingStyle.fill;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          true,
          paint,
        );

        // Draw percentage text
        final percentage = ((amount / totalAmount) * 100).round();
        if (percentage >= 10) {
          // Only show text for segments >= 10%
          final textAngle = startAngle + sweepAngle / 2;
          final textRadius = radius * 0.7;
          final textX = center.dx + textRadius * math.cos(textAngle);
          final textY = center.dy + textRadius * math.sin(textAngle);

          final textPainter = TextPainter(
            text: TextSpan(
              text: '$category\n$percentage%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          textPainter.paint(
            canvas,
            Offset(
              textX - textPainter.width / 2,
              textY - textPainter.height / 2,
            ),
          );
        }

        startAngle += sweepAngle;
        colorIndex++;
      }
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
