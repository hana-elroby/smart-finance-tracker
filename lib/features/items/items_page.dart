import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../home/bloc/expense_bloc.dart';
import '../home/bloc/expense_state.dart';
import '../home/bloc/expense_event.dart';
import '../../core/models/expense.dart';
import '../../widgets/dialogs/manual_entry_dialog.dart';
import '../../widgets/dialogs/voice_input_dialog.dart';

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
  String? _selectedItemName; // Selected item name for filtering
  bool _showFloatingOptions = false; // Track floating options visibility

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
  
  // Handle bar tap - filter items by name
  void _onBarTap(String itemName) {
    setState(() {
      if (_selectedItemName == itemName) {
        _selectedItemName = null; // Deselect if already selected
      } else {
        _selectedItemName = itemName; // Select this item
      }
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
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
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
                    ],
                  ),
                ),
              ),
              // Add Transaction Button at the bottom
              Padding(
                padding: const EdgeInsets.only(bottom: 30, top: 10),
                child: _buildAddTransactionButton(),
              ),
            ],
          ),
          // Floating options overlay
          if (_showFloatingOptions) _buildFloatingOptions(),
        ],
      ),
    );
  }

  // Floating Manual and Voice buttons above Plus
  Widget _buildFloatingOptions() {
    return GestureDetector(
      onTap: () {
        setState(() => _showFloatingOptions = false);
      },
      child: Container(
        color: Colors.black.withValues(alpha: 0.3),
        child: Stack(
          children: [
            // Manual button (left)
            Positioned(
              bottom: 120,
              left: MediaQuery.of(context).size.width / 2 - 90,
              child: GestureDetector(
                onTap: () async {
                  HapticFeedback.lightImpact();
                  setState(() => _showFloatingOptions = false);
                  final result = await showManualEntryDialog(
                    context,
                    initialCategory: widget.categoryName,
                  );
                  if (result != null && mounted) {
                    final expense = Expense(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: result['title'] as String,
                      amount: result['amount'] as double,
                      category: result['category'] as String,
                      date: result['date'] as DateTime,
                    );
                    context.read<ExpenseBloc>().add(AddExpense(expense));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added ${result['title']}'),
                        backgroundColor: const Color(0xFF4CAF50),
                      ),
                    );
                  }
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Color(0xFF4CAF50),
                    size: 26,
                  ),
                ),
              ),
            ),
            // Voice button (right)
            Positioned(
              bottom: 120,
              right: MediaQuery.of(context).size.width / 2 - 90,
              child: GestureDetector(
                onTap: () async {
                  HapticFeedback.lightImpact();
                  setState(() => _showFloatingOptions = false);
                  final result = await showVoiceInputDialog(context);
                  if (result != null && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added: $result'),
                        backgroundColor: const Color(0xFF10B981),
                      ),
                    );
                  }
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.mic_rounded,
                    color: Color(0xFF3B82F6),
                    size: 28,
                  ),
                ),
              ),
            ),
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
            color: const Color(0xFF1478E0).withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1478E0).withValues(alpha: 0.1),
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
              color: const Color(0xFF1478E0),
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
        // Get items for this category
        List<Expense> categoryExpenses = [];
        if (state is ExpenseLoaded) {
          categoryExpenses = state.getExpensesByCategory(widget.categoryName);
        }

        // Show placeholder when no items in this category
        if (state is! ExpenseLoaded || categoryExpenses.isEmpty) {
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
                  // Placeholder chart bars (faded)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildPlaceholderBar(40),
                      const SizedBox(width: 12),
                      _buildPlaceholderBar(70),
                      const SizedBox(width: 12),
                      _buildPlaceholderBar(55),
                      const SizedBox(width: 12),
                      _buildPlaceholderBar(85),
                      const SizedBox(width: 12),
                      _buildPlaceholderBar(45),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Icon(
                    Icons.analytics_outlined,
                    size: 32,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Analytics will appear here',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add items to see your spending analysis',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Group by item name and calculate totals
        final Map<String, double> itemTotals = {};
        for (var expense in categoryExpenses) {
          final name = expense.title;
          itemTotals[name] = (itemTotals[name] ?? 0) + expense.amount;
        }

        // Convert to chart data format
        final chartData = itemTotals.entries
            .take(7) // Top 7 items
            .map((e) => {'item': e.key, 'quantity': e.value})
            .toList();

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
          child: Column(
            children: [
              // Show selected filter chip if item is selected
              if (_selectedItemName != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Showing: $_selectedItemName',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2563EB),
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => setState(() => _selectedItemName = null),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: GestureDetector(
                  onTapUp: (details) {
                    // Calculate which bar was tapped
                    final tapX = details.localPosition.dx - 20; // Adjust for padding
                    final chartWidth = MediaQuery.of(context).size.width - 80;
                    final barWidth = (chartWidth - 60) / (chartData.length * 3.5);
                    final spacing = barWidth * 1.5;
                    
                    for (int i = 0; i < chartData.length; i++) {
                      final barStart = 30 + i * (barWidth + spacing);
                      final barEnd = barStart + barWidth;
                      
                      if (tapX >= barStart && tapX <= barEnd) {
                        _onBarTap(chartData[i]['item'] as String);
                        break;
                      }
                    }
                  },
                  child: CustomPaint(
                    size: const Size(double.infinity, 180),
                    painter: BarChartPainter(chartData, selectedItem: _selectedItemName),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderBar(double height) {
    return Container(
      width: 24,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  Widget _buildItemsList() {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        // Get items for this category
        List<Expense> items = [];
        if (state is ExpenseLoaded) {
          items = state.getExpensesByCategory(widget.categoryName);
          
          // Filter by selected item name if any
          if (_selectedItemName != null) {
            items = items.where((e) => e.title == _selectedItemName).toList();
          }
        }

        // Show empty state when no items
        if (items.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
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
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF64748B).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.categoryIcon,
                      size: 40,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _selectedItemName != null 
                        ? 'No "$_selectedItemName" items'
                        : 'No ${widget.categoryName} items yet',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedItemName != null
                        ? 'Tap on another bar or clear filter'
                        : 'Your expenses will appear here\nTap + to add your first item',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF9CA3AF),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show count when filtered
            if (_selectedItemName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '${items.length} item${items.length > 1 ? 's' : ''} found',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
            ...items.map((expense) {
              return _buildDismissibleItemCard(expense);
            }),
          ],
        );
      },
    );
  }

  Widget _buildDismissibleItemCard(Expense expense) {
    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(25),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Delete Item',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            content: Text(
              'Are you sure you want to delete "${expense.title}"?',
              style: GoogleFonts.inter(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Delete',
                  style: GoogleFonts.inter(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        context.read<ExpenseBloc>().add(DeleteExpense(expense.id));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${expense.title} deleted'),
            backgroundColor: Colors.red,
          ),
        );
      },
      child: _buildItemCard(
        expense.title,
        _formatDate(expense.date),
        expense.amount,
        _getCategoryIcon(expense.category),
      ),
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
    // Remove time from date (keep only date part)
    final dateOnly = date.contains(',') ? date.split(',')[0] : date.split(' ')[0];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFCBD5E1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A5F).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF1E3A5F), size: 20),
          ),
          const SizedBox(width: 12),
          // Name on left
          Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          // Date in center
          Expanded(
            child: Center(
              child: Text(
                dateOnly,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
          ),
          // Amount on the right with currency
          Text(
            '${amount.toStringAsFixed(0)} EGP',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E3A5F),
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
          HapticFeedback.lightImpact();
          setState(() {
            _showFloatingOptions = !_showFloatingOptions;
          });
        },
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
              const BoxShadow(
                color: Colors.white,
                blurRadius: 0,
                offset: Offset(0, 0),
                spreadRadius: 2,
              ),
            ],
          ),
          child: AnimatedRotation(
            turns: _showFloatingOptions ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
          ),
        ),
      ),
    );
  }

  // Keep old method for compatibility but not used
  // ignore: unused_element
  void _showAddOptions() {
    setState(() {
      _showFloatingOptions = true;
    });
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
  final String? selectedItem;

  BarChartPainter(this.data, {this.selectedItem});

  @override
  void paint(Canvas canvas, Size size) {
    final maxQuantity =
        data.map((e) => e['quantity'] as double).reduce(math.max);
    // Make bars thinner
    final barWidth = (size.width - 60) / (data.length * 3.5);
    final spacing = barWidth * 1.5;

    // Draw Y-axis label
    final yAxisPainter = TextPainter(
      text: const TextSpan(
        text: 'EGP',
        style: TextStyle(
          color: Color(0xFF64748B),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    yAxisPainter.layout();
    yAxisPainter.paint(canvas, const Offset(0, 0));

    for (int i = 0; i < data.length; i++) {
      final itemName = data[i]['item'] as String;
      final quantity = data[i]['quantity'] as double;
      final barHeight = (quantity / maxQuantity) * (size.height - 50);
      final isSelected = selectedItem == itemName;

      final x = 30 + i * (barWidth + spacing);
      final y = size.height - barHeight - 30;

      // Different colors for selected/unselected bars
      final paint = Paint()
        ..shader = LinearGradient(
          colors: isSelected 
              ? [const Color(0xFF10B981), const Color(0xFF059669)] // Green for selected
              : [const Color(0xFF3B82F6), const Color(0xFF2563EB)], // Blue for normal
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(x, y, barWidth, barHeight))
        ..style = PaintingStyle.fill;

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
          style: TextStyle(
            color: isSelected ? const Color(0xFF059669) : const Color(0xFF2563EB),
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

      // Draw item name label (X-axis) - Vertical text close to bar
      final displayName = itemName.length > 8 ? '${itemName.substring(0, 8)}.' : itemName;
      final namePainter = TextPainter(
        text: TextSpan(
          text: displayName,
          style: TextStyle(
            color: isSelected ? const Color(0xFF059669) : const Color(0xFF374151),
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      namePainter.layout();
      
      // Rotate text to be vertical and position close to bar bottom
      canvas.save();
      final centerX = x + barWidth / 2;
      final barBottom = size.height - 30; // Bottom of the chart area
      canvas.translate(centerX + 4, barBottom + 4);
      canvas.rotate(-1.5708); // -90 degrees in radians
      namePainter.paint(canvas, Offset(-namePainter.width, -namePainter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}


