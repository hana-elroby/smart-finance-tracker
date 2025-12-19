import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';
import '../home/bloc/expense_bloc.dart';
import '../home/bloc/expense_state.dart';

/// Items Page - عرض العناصر في كل فئة
/// تعرض كل الـ items الموجودة في فئة معينة مع chart وقائمة
class ItemsPage extends StatelessWidget {
  final String categoryName;
  final IconData categoryIcon;
  final Color categoryColor;

  const ItemsPage({
    super.key,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExpenseBloc(),
      child: _ItemsPageContent(
        categoryName: categoryName,
        categoryIcon: categoryIcon,
        categoryColor: categoryColor,
      ),
    );
  }
}

class _ItemsPageContent extends StatefulWidget {
  final String categoryName;
  final IconData categoryIcon;
  final Color categoryColor;

  const _ItemsPageContent({
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
  });

  @override
  State<_ItemsPageContent> createState() => _ItemsPageContentState();
}

class _ItemsPageContentState extends State<_ItemsPageContent> {
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
          'Items',
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
            
            // Bar Chart
            _buildBarChart(),
            
            const SizedBox(height: 30),
            
            // Items List
            _buildItemsList(),
            
            const SizedBox(height: 20),
            
            // Add Transaction Button
            _buildAddTransactionButton(),
            
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

  Widget _buildBarChart() {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        // Sample data for the chart with item names and quantities
        final chartData = [
          {'item': 'Pizza', 'quantity': 5.0},
          {'item': 'Burger', 'quantity': 3.0},
          {'item': 'Coffee', 'quantity': 8.0},
          {'item': 'Pasta', 'quantity': 2.0},
          {'item': 'Sushi', 'quantity': 6.0},
        ];

        return Container(
          height: 250,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: CustomPaint(
            size: const Size(double.infinity, 200),
            painter: BarChartPainter(chartData),
          ),
        );
      },
    );
  }

  Widget _buildItemsList() {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        // Sample items data - replace with real data from the category
        final items = [
          {
            'name': 'McDonald',
            'date': 'Today, 17:40 PM',
            'amount': 26.64,
            'icon': Icons.fastfood,
          },
          {
            'name': 'PizzaHut',
            'date': 'March 10, 15:00 PM',
            'amount': 46.40,
            'icon': Icons.local_pizza,
          },
          {
            'name': 'Coffee',
            'date': 'March 10, 13:00 PM',
            'amount': 46.40,
            'icon': Icons.coffee,
          },
          {
            'name': 'PizzaHut',
            'date': 'March 10, 13:00 PM',
            'amount': 46.40,
            'icon': Icons.local_pizza,
          },
        ];

        return Column(
          children: items.map((item) {
            return _buildItemCard(
              item['name'] as String,
              item['date'] as String,
              item['amount'] as double,
              item['icon'] as IconData,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildItemCard(String name, String date, double amount, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF42A5F5).withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddTransactionButton() {
    return Center(
      child: GestureDetector(
        onTap: () {
          // TODO: Add functionality to open add expense page
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Add Transaction - Coming soon!',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              backgroundColor: const Color(0xFF42A5F5),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF42A5F5).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: const Color(0xFF1976D2).withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: Colors.white,
                blurRadius: 0,
                offset: const Offset(0, 0),
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 32,
          ),
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

class BarChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;

  BarChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final maxQuantity = data.map((e) => e['quantity'] as double).reduce(math.max);
    final barWidth = (size.width - 40) / (data.length * 1.5);
    final spacing = barWidth * 0.5;

    // Draw Y-axis label
    final yAxisPainter = TextPainter(
      text: const TextSpan(
        text: 'Qty',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    yAxisPainter.layout();
    yAxisPainter.paint(canvas, const Offset(0, 0));

    for (int i = 0; i < data.length; i++) {
      final quantity = data[i]['quantity'] as double;
      final barHeight = (quantity / maxQuantity) * (size.height - 50);
      
      final x = 30 + i * (barWidth + spacing);
      final y = size.height - barHeight - 30;

      // Draw bar with gradient
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(6),
        ),
        paint,
      );

      // Draw quantity on top of bar
      final qtyPainter = TextPainter(
        text: TextSpan(
          text: quantity.toInt().toString(),
          style: const TextStyle(
            color: Color(0xFF1976D2),
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      qtyPainter.layout();
      qtyPainter.paint(
        canvas,
        Offset(x + barWidth / 2 - qtyPainter.width / 2, y - 18),
      );

      // Draw item name label (X-axis)
      final itemName = data[i]['item'] as String;
      final namePainter = TextPainter(
        text: TextSpan(
          text: itemName.length > 6 ? '${itemName.substring(0, 6)}.' : itemName,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      namePainter.layout();
      namePainter.paint(
        canvas,
        Offset(x + barWidth / 2 - namePainter.width / 2, size.height - 20),
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}