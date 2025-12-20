import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../home/bloc/expense_bloc.dart';
import '../home/bloc/expense_state.dart';
import '../home/bloc/expense_event.dart';
import '../../core/models/expense.dart';
import '../../widgets/dialogs/add_options_bottom_sheet.dart';
import '../../widgets/dialogs/manual_entry_dialog.dart';

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
    // Use existing BlocProvider from parent (MainLayout)
    // Don't create new one - share the same ExpenseBloc
    return _ItemsPageContent(
      categoryName: categoryName,
      categoryIcon: categoryIcon,
      categoryColor: categoryColor,
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
      _fromDate = DateTime(
        now.year,
        now.month,
        1,
      ); // First day of current month
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

  Widget _buildBarChart() {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        // Show placeholder when no data
        if (state is! ExpenseLoaded || state.isEmpty) {
          return Container(
            height: 250,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart_rounded,
                    size: 48,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No items yet',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Get real items for this category
        final categoryExpenses = state.getExpensesByCategory(
          widget.categoryName,
        );

        // Group by item name and calculate totals
        final Map<String, double> itemTotals = {};
        for (var expense in categoryExpenses) {
          final name = expense.title;
          itemTotals[name] = (itemTotals[name] ?? 0) + expense.amount;
        }

        // Convert to chart data format
        final chartData = itemTotals.entries
            .take(5) // Top 5 items
            .map((e) => {'item': e.key, 'quantity': e.value})
            .toList();

        if (chartData.isEmpty) {
          return Container(
            height: 250,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'No items in this category',
                style: GoogleFonts.inter(color: Colors.grey),
              ),
            ),
          );
        }

        return Container(
          height: 250,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
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
        // Show empty state when no data
        if (state is! ExpenseLoaded || state.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No items added yet',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add your first expense',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Get real items for this category
        final items = state.getExpensesByCategory(widget.categoryName);

        if (items.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: Text(
                'No items in this category',
                style: GoogleFonts.inter(color: Colors.grey),
              ),
            ),
          );
        }

        return Column(
          children: items.map((expense) {
            return _buildItemCard(
              expense.title,
              _formatDate(expense.date),
              expense.amount,
              _getCategoryIcon(expense.category),
            );
          }).toList(),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day}/${date.month}, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food & Drink':
        return Icons.restaurant;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Bills':
        return Icons.receipt;
      case 'Health':
        return Icons.favorite;
      case 'Transport':
        return Icons.directions_car;
      case 'Entertainment':
        return Icons.movie;
      default:
        return Icons.category;
    }
  }

  Widget _buildItemCard(
    String name,
    String date,
    double amount,
    IconData icon,
  ) {
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
            color: const Color(0xFF42A5F5).withValues(alpha: 0.3),
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
              color: Colors.white.withValues(alpha: 0.2),
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
                    color: Colors.white.withValues(alpha: 0.8),
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
        onTap: () => _showAddOptions(),
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
                color: const Color(0xFF42A5F5).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: const Color(0xFF1976D2).withValues(alpha: 0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
              const BoxShadow(
                color: Colors.white,
                blurRadius: 0,
                offset: Offset(0, 0),
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
        ),
      ),
    );
  }

  void _showAddOptions() {
    showAddOptionsBottomSheet(
      context,
      categoryName: widget.categoryName,
      onManualTap: () async {
        final result = await showManualEntryDialog(
          context,
          initialCategory: widget.categoryName,
        );
        if (result != null && mounted) {
          // Add the expense to BLoC
          final expense = Expense(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: result['title'] as String,
            amount: result['amount'] as double,
            category: result['category'] as String,
            date: result['date'] as DateTime,
          );
          context.read<ExpenseBloc>().add(AddExpense(expense));

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added ${result['title']}'),
              backgroundColor: const Color(0xFF4CAF50),
            ),
          );
        }
      },
      onVoiceTap: () {
        // TODO: Implement voice input
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voice input - Coming soon!'),
            backgroundColor: Color(0xFFFF9800),
          ),
        );
      },
      onScanTap: () {
        // TODO: Implement scan receipt
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Scan receipt - Coming soon!'),
            backgroundColor: Color(0xFF2196F3),
          ),
        );
      },
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

    final maxQuantity = data
        .map((e) => e['quantity'] as double)
        .reduce(math.max);
    // Make bars thinner - reduce width multiplier
    final barWidth = (size.width - 60) / (data.length * 2.5);
    final spacing = barWidth * 1.0;

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
          style: const TextStyle(color: Colors.grey, fontSize: 10),
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
