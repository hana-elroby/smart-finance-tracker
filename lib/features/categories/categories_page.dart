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
import 'bloc/category_bloc.dart';
import 'category_data_store.dart';

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

  @override
  void initState() {
    super.initState();
    _setDefaultDates();
  }

  void _setDefaultDates() {
    // Start with no filter — show all data by default
    setState(() {
      _fromDate = null;
      _toDate = null;
    });
  }

  bool get _isDateFiltered => _fromDate != null || _toDate != null;

  void _clearDateFilter() {
    setState(() {
      _fromDate = null;
      _toDate = null;
    });
  }

  /// Filter expenses by the selected date range
  List<dynamic> _filterByDate(List<dynamic> expenses) {
    if (!_isDateFiltered) return expenses;
    return expenses.where((e) {
      final date = e.date as DateTime;
      if (_fromDate != null) {
        final from = DateTime(_fromDate!.year, _fromDate!.month, _fromDate!.day);
        if (date.isBefore(from)) return false;
      }
      if (_toDate != null) {
        final to = DateTime(_toDate!.year, _toDate!.month, _toDate!.day, 23, 59, 59);
        if (date.isAfter(to)) return false;
      }
      return true;
    }).toList();
  }

  List<Map<String, dynamic>> _getAllCategories(List<Map<String, dynamic>> customCategories) {
    // Remove custom categories that duplicate default names (case-insensitive)
    final defaultNames = _defaultCategories
        .map((c) => (c['name'] as String).toLowerCase())
        .toSet();

    final uniqueCustom = customCategories
        .where((c) => !defaultNames.contains((c['name'] as String).toLowerCase()))
        .toList();

    return [
      ..._defaultCategories,
      ...uniqueCustom,
    ];
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
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 150,
              child: _buildSimpleDateField(
                label: 'From',
                date: _fromDate,
                onTap: () => _selectFromDate(),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: 150,
              child: _buildSimpleDateField(
                label: 'To',
                date: _toDate,
                onTap: () => _selectToDate(),
              ),
            ),
          ],
        ),
        if (_isDateFiltered) ...[
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _clearDateFilter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.close_rounded, size: 16, color: Color(0xFFEF4444)),
                  const SizedBox(width: 6),
                  Text(
                    'Clear filter — show all',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSimpleDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    final isActive = date != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1478E0).withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? const Color(0xFF1478E0) : const Color(0xFF1478E0).withValues(alpha: 0.3),
            width: isActive ? 2 : 1.5,
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
              isActive ? Icons.event_available_rounded : Icons.calendar_today_outlined,
              color: const Color(0xFF1478E0),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              isActive ? '$label: ${date.day}/${date.month}' : '$label: Any',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                color: isActive ? const Color(0xFF1478E0) : const Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Track selected category for drill-down
  String? _selectedCategory;
  
  Widget _buildPieChart() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, categoryState) {
        final allCategories = _getAllCategories(categoryState.customCategories);
        
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
              // Apply date filter first
              final filtered = _filterByDate(state.expenses);

              // Calculate totals per category from filtered expenses
              for (var cat in allCategories) {
                final name = cat['name'] as String;
                final total = filtered
                    .where((e) => e.category == name)
                    .fold<double>(0, (sum, e) => sum + e.amount);
                if (total > 0) {
                  categoryTotals[name] = total;
                }
              }

              totalAmount = categoryTotals.values.fold(0, (sum, a) => sum + a);
            }

            // If still no data after calculation, show placeholder
            if (totalAmount == 0) {
              return const ChartPlaceholder(
                title: 'Spending by Category',
                height: 150,
                type: ChartPlaceholderType.pie,
              );
            }

            // If a category is selected, show items breakdown
            if (_selectedCategory != null && state is ExpenseLoaded) {
              return _buildItemsBreakdownChart(state, _selectedCategory!);
            }

            // Main categories pie chart
            return Column(
              children: [
                Text(
                  'Tap a slice to see items',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTapUp: (details) {
                    final tappedCategory = _getTappedCategory(
                      details.localPosition,
                      const Size(220, 220),
                      categoryTotals,
                      totalAmount,
                    );
                    if (tappedCategory != null) {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedCategory = tappedCategory;
                      });
                    }
                  },
                  child: SizedBox(
                    width: 220,
                    height: 220,
                    child: CustomPaint(
                      painter: PieChartPainter(categoryTotals, totalAmount),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Get which category was tapped based on position
  String? _getTappedCategory(
    Offset tapPosition,
    Size size,
    Map<String, double> categoryTotals,
    double totalAmount,
  ) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;
    
    // Check if tap is within the pie
    final distance = (tapPosition - center).distance;
    if (distance > radius) return null;
    
    // Calculate angle of tap
    final dx = tapPosition.dx - center.dx;
    final dy = tapPosition.dy - center.dy;
    var tapAngle = math.atan2(dy, dx);
    
    // Normalize angle to start from top (-π/2)
    tapAngle = tapAngle + math.pi / 2;
    if (tapAngle < 0) tapAngle += 2 * math.pi;
    
    // Find which segment was tapped
    double startAngle = 0;
    for (final entry in categoryTotals.entries) {
      if (entry.value > 0) {
        final sweepAngle = (entry.value / totalAmount) * 2 * math.pi;
        if (tapAngle >= startAngle && tapAngle < startAngle + sweepAngle) {
          return entry.key;
        }
        startAngle += sweepAngle;
      }
    }
    return null;
  }

  // Build items breakdown chart for selected category
  Widget _buildItemsBreakdownChart(ExpenseLoaded state, String categoryName) {
    // Apply date filter then filter by category
    final filtered = _filterByDate(state.expenses)
        .where((e) => e.category == categoryName)
        .toList();

    final Map<String, double> itemTotals = {};
    final Map<String, int> itemCounts = {};

    for (final expense in filtered) {
      final itemName = expense.title;
      itemTotals[itemName] = (itemTotals[itemName] ?? 0) + expense.amount;
      itemCounts[itemName] = (itemCounts[itemName] ?? 0) + 1;
    }
    
    if (itemTotals.isEmpty) {
      return Column(
        children: [
          _buildBackButton(),
          const SizedBox(height: 16),
          Text(
            'No items in $categoryName',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      );
    }
    
    // Sort by AMOUNT (highest spending first)
    final sortedItems = itemTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final totalAmount = itemTotals.values.fold(0.0, (sum, v) => sum + v);
    
    return Column(
      children: [
        // Back button and title
        _buildBackButton(),
        const SizedBox(height: 8),
        Text(
          categoryName,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1976D2),
          ),
        ),
        Text(
          'Spending breakdown',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 16),
        
        // Items pie chart (based on amount)
        SizedBox(
          width: 200,
          height: 200,
          child: CustomPaint(
            painter: ItemsPieChartPainter(
              items: sortedItems,
              itemCounts: itemCounts,
              totalCount: totalAmount.toInt(),
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Items legend - sorted by amount (EGP percentage)
        ...sortedItems.take(5).map((entry) {
          final percentage = totalAmount > 0 ? ((entry.value / totalAmount) * 100).round() : 0;
          final colorIndex = sortedItems.indexOf(entry);
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getItemColor(colorIndex),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: Text(
                    entry.key,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF374151),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$percentage%',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${entry.value.toInt()} EGP',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedCategory = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1976D2).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.arrow_back_rounded,
              size: 16,
              color: Color(0xFF1976D2),
            ),
            const SizedBox(width: 4),
            Text(
              'Back to Categories',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1976D2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getItemColor(int index) {
    final colors = [
      const Color(0xFF1976D2),
      const Color(0xFF42A5F5),
      const Color(0xFF64B5F6),
      const Color(0xFF90CAF9),
      const Color(0xFFBBDEFB),
    ];
    return colors[index % colors.length];
  }

  Widget _buildCategoriesList() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, categoryState) {
        final customCategories = categoryState.customCategories;
        final allCategories = _getAllCategories(customCategories);
        
        return Column(
          children: [
            BlocBuilder<ExpenseBloc, ExpenseState>(
              builder: (context, state) {
                // Get category totals from filtered data
                Map<String, double> categoryTotals = {};
                if (state is ExpenseLoaded) {
                  final filtered = _filterByDate(state.expenses);
                  for (var cat in allCategories) {
                    final name = cat['name'] as String;
                    categoryTotals[name] = filtered
                        .where((e) => e.category == name)
                        .fold<double>(0, (sum, e) => sum + e.amount);
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

                    // Custom Categories (can be deleted with swipe)
                    ...customCategories.map((category) {
                      final amount = categoryTotals[category['name']] ?? 0;
                      return Dismissible(
                        key: Key(category['name'] as String),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          alignment: Alignment.centerRight,
                          child: const Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        onDismissed: (direction) {
                          final categoryName = category['name'] as String;
                          _deleteCategory(categoryName);
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$categoryName deleted'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: _buildCategoryItem(
                          category['name'] as String,
                          category['icon'] as IconData,
                          const Color(0xFF1976D2),
                          amount,
                          isDefault: false,
                          onDelete: () => _deleteCategory(category['name'] as String),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),

            // Add Category Button
            _buildAddCategoryButton(),
          ],
        );
      },
    );
  }

  Widget _buildAddCategoryButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          debugPrint('=== Add Category Button Tapped ===');
          _addNewCategory();
        },
        borderRadius: BorderRadius.circular(25),
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
      ),
    );
  }

  Future<void> _addNewCategory() async {
    debugPrint('=== _addNewCategory START ===');
    HapticFeedback.lightImpact();
    
    final result = await showAddCategoryDialog(context);
    debugPrint('=== Result received: $result ===');
    
    if (result != null && result['name'] != null && result['icon'] != null) {
      // Use CategoryBloc to add category
      context.read<CategoryBloc>().add(AddCategory(
        name: result['name'] as String,
        icon: result['icon'] as IconData,
      ));
      
      debugPrint('=== Category added via BLoC ===');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Category "${result['name']}" added!'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } else {
      debugPrint('=== Dialog cancelled or invalid result ===');
    }
  }

  void _deleteCategory(String name) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Use CategoryBloc to delete category
              context.read<CategoryBloc>().add(DeleteCategory(name));
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Category "$name" deleted'),
                  backgroundColor: Colors.red,
                ),
              );
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
        if (mounted && context.mounted) {
          try {
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
          } catch (e) {
            print('⚠️ Error navigating to ItemsPage: $e');
          }
        }
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




// Pie chart painter for items breakdown (based on amount)
class ItemsPieChartPainter extends CustomPainter {
  final List<MapEntry<String, double>> items;
  final Map<String, int> itemCounts;
  final int totalCount;

  ItemsPieChartPainter({
    required this.items,
    required this.itemCounts,
    required this.totalCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;

    final colors = [
      const Color(0xFF1976D2),
      const Color(0xFF42A5F5),
      const Color(0xFF64B5F6),
      const Color(0xFF90CAF9),
      const Color(0xFFBBDEFB),
    ];

    // Use amounts for pie slices
    final totalAmount = items.fold(0.0, (sum, e) => sum + e.value);
    if (totalAmount == 0) return;

    double startAngle = -math.pi / 2;

    for (int i = 0; i < items.length && i < 5; i++) {
      final item = items[i];
      final sweepAngle = (item.value / totalAmount) * 2 * math.pi;

      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw percentage text for large segments
      final percentage = ((item.value / totalAmount) * 100).round();
      if (percentage >= 15) {
        final textAngle = startAngle + sweepAngle / 2;
        final textRadius = radius * 0.65;
        final textX = center.dx + textRadius * math.cos(textAngle);
        final textY = center.dy + textRadius * math.sin(textAngle);

        final textPainter = TextPainter(
          text: TextSpan(
            text: '$percentage%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
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
    }

    // Draw center circle (donut style)
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.4, centerPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
