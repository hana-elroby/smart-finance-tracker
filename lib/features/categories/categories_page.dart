import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';
import '../home/bloc/expense_bloc.dart';
import '../home/bloc/expense_state.dart';
import '../items/items_page.dart';

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

  @override
  void initState() {
    super.initState();
    _setDefaultDates();
  }

  void _setDefaultDates() {
    final now = DateTime.now();
    setState(() {
      _fromDate = DateTime(now.year, now.month, 1); // First day of current month
      _toDate = now; // Today
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'categories',
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
            color: const Color(0xFF1687F0).withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1687F0).withOpacity(0.1),
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
        Map<String, double> categoryTotals = {};
        double totalAmount = 0;

        if (state is ExpenseLoaded) {
          // Calculate totals for each category
          categoryTotals['Food'] = state.getCategoryTotal('Food & Drink');
          categoryTotals['Shopping'] = state.getCategoryTotal('Shopping');
          categoryTotals['Bills'] = state.getCategoryTotal('Bills');
          categoryTotals['Health'] = state.getCategoryTotal('Health');
          categoryTotals['Transport'] = state.getCategoryTotal('Transport');
          categoryTotals['Entertainment'] = state.getCategoryTotal('Entertainment');

          totalAmount = categoryTotals.values.fold(0, (sum, amount) => sum + amount);
        }

        // Default data if no expenses
        if (totalAmount == 0) {
          categoryTotals = {
            'Food': 300,
            'Shopping': 790,
            'Bills': 200,
            'Health': 150,
            'Transport': 100,
            'Entertainment': 80,
          };
          totalAmount = categoryTotals.values.fold(0, (sum, amount) => sum + amount);
        }

        return SizedBox(
          width: 250,
          height: 250,
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
        Map<String, double> categoryTotals = {};

        if (state is ExpenseLoaded) {
          categoryTotals['Food'] = state.getCategoryTotal('Food & Drink');
          categoryTotals['Shopping'] = state.getCategoryTotal('Shopping');
          categoryTotals['Bills'] = state.getCategoryTotal('Bills');
          categoryTotals['Health'] = state.getCategoryTotal('Health');
          categoryTotals['Transport'] = state.getCategoryTotal('Transport');
          categoryTotals['Entertainment'] = state.getCategoryTotal('Entertainment');
        } else {
          // Default data
          categoryTotals = {
            'Food': 300,
            'Shopping': 790,
            'Bills': 200,
            'Health': 150,
            'Transport': 100,
            'Entertainment': 80,
          };
        }

        final categories = [
          {'name': 'Food', 'icon': Icons.restaurant, 'color': const Color(0xFF1976D2)},
          {'name': 'Shopping', 'icon': Icons.shopping_bag, 'color': const Color(0xFF1976D2)},
          {'name': 'Bills', 'icon': Icons.receipt, 'color': const Color(0xFF1976D2)},
          {'name': 'Health', 'icon': Icons.favorite, 'color': const Color(0xFF1976D2)},
          {'name': 'Transport', 'icon': Icons.directions_car, 'color': const Color(0xFF1976D2)},
          {'name': 'Entertainment', 'icon': Icons.movie, 'color': const Color(0xFF1976D2)},
        ];

        return Column(
          children: categories.map((category) {
            final amount = categoryTotals[category['name']] ?? 0;
            return _buildCategoryItem(
              category['name'] as String,
              category['icon'] as IconData,
              category['color'] as Color,
              amount,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCategoryItem(String name, IconData icon, Color color, double amount) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemsPage(
              categoryName: name,
              categoryIcon: icon,
              categoryColor: color,
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
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            Text(
              'EGP ${amount.toInt()}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
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
        if (percentage >= 10) { // Only show text for segments >= 10%
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
            Offset(textX - textPainter.width / 2, textY - textPainter.height / 2),
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