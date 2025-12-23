import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../home/bloc/expense_bloc.dart';
import '../items/items_page.dart';
import 'category_data_store.dart';

/// Categories Page
class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExpenseBloc(),
      child: const _CategoriesPageContent(),
    );
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
  final CategoryDataStore _dataStore = CategoryDataStore();

  @override
  void initState() {
    super.initState();
    _setDefaultDates();
  }

  void _setDefaultDates() {
    final now = DateTime.now();
    setState(() {
      _fromDate = DateTime(now.year, now.month, 1);
      _toDate = now;
    });
  }

  void _addCategory(CategoryData category) {
    setState(() {
      _dataStore.addCustomCategory(category);
    });
  }

  void _deleteCategory(int index) {
    setState(() {
      _dataStore.removeCustomCategory(index);
    });
  }

  void _refreshState() {
    setState(() {});
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
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
            _buildDateSelectors(),
            const SizedBox(height: 30),
            _buildPieChart(),
            const SizedBox(height: 30),
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
            const Icon(Icons.calendar_today_outlined, color: Color(0xFF1687F0), size: 16),
            const SizedBox(width: 8),
            Text(
              '$label: ${date != null ? '${date.day}/${date.month}' : 'Select'}',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF374151)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    Map<String, double> categoryTotals = {};
    // Add all categories from data store
    for (var cat in _dataStore.allCategories) {
      categoryTotals[cat.name] = cat.totalAmount;
    }
    double totalAmount = categoryTotals.values.fold(0, (sum, amount) => sum + amount);
    if (totalAmount == 0) totalAmount = 1;

    return SizedBox(
      width: 250,
      height: 250,
      child: CustomPaint(painter: PieChartPainter(categoryTotals, totalAmount)),
    );
  }

  Widget _buildCategoriesList() {
    // Sort categories by amount (highest first)
    final sortedMain = List<CategoryData>.from(_dataStore.mainCategories)
      ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    final sortedCustom = List<CategoryData>.from(_dataStore.customCategories)
      ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    return Column(
      children: [
        // Main categories (sorted by amount)
        ...sortedMain.map((category) {
          final index = _dataStore.mainCategories.indexOf(category);
          return _buildCategoryItem(
            category.name,
            category.icon,
            category.color,
            category.totalAmount,
            isDeletable: false,
            isMainCategory: true,
            mainCategoryIndex: index,
          );
        }),
        // Custom categories (sorted by amount)
        ...sortedCustom.map((category) {
          final index = _dataStore.customCategories.indexOf(category);
          return _buildCategoryItem(
            category.name,
            category.icon,
            category.color,
            category.totalAmount,
            isDeletable: true,
            onDelete: () => _showDeleteConfirmation(index),
            onMenuTap: () => _showCategoryMenu(index),
            customCategoryIndex: index,
          );
        }),
        const SizedBox(height: 16),
        _buildAddCategoryButton(),
      ],
    );
  }

  Widget _buildCategoryItem(
    String name, IconData icon, Color color, double amount, {
    bool isDeletable = false,
    bool isMainCategory = false,
    int? mainCategoryIndex,
    int? customCategoryIndex,
    VoidCallback? onDelete,
    VoidCallback? onMenuTap,
  }) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemsPage(
              categoryName: name,
              categoryIcon: icon,
              categoryColor: color,
            ),
          ),
        );
        // Refresh state after returning - data is persisted in store
        _refreshState();
      },
      onLongPress: isDeletable ? onDelete : null,
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
              child: Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
            ),
            Text(
              'EGP ${amount.toInt()}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            if (isDeletable) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onMenuTap,
                child: Icon(Icons.more_vert, color: Colors.grey[400], size: 18),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCategoryMenu(int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text('Delete Category', style: GoogleFonts.inter(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Category', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        content: Text('Are you sure you want to delete "${_dataStore.customCategories[index].name}"?', style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteCategory(index);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: Text('Delete', style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _selectFromDate() async {
    final picked = await showDatePicker(context: context, initialDate: _fromDate ?? DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime(2100));
    if (picked != null) setState(() => _fromDate = picked);
  }

  Future<void> _selectToDate() async {
    final picked = await showDatePicker(context: context, initialDate: _toDate ?? DateTime.now(), firstDate: _fromDate ?? DateTime(1900), lastDate: DateTime(2100));
    if (picked != null) setState(() => _toDate = picked);
  }

  Widget _buildAddCategoryButton() {
    return GestureDetector(
      onTap: () => _showAddCategoryDialog(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: const Color(0xFF1976D2), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: Color(0xFF1976D2), size: 20),
            const SizedBox(width: 8),
            Text('Add Category', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1976D2))),
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _AddCategoryDialog(onCategoryCreated: (category) => _addCategory(category)),
    );
  }
}

class _AddCategoryDialog extends StatefulWidget {
  final Function(CategoryData) onCategoryCreated;
  const _AddCategoryDialog({required this.onCategoryCreated});

  @override
  State<_AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<_AddCategoryDialog> {
  final _nameController = TextEditingController();
  IconData _selectedIcon = Icons.category;

  final List<IconData> _availableIcons = [
    Icons.category, Icons.shopping_cart, Icons.restaurant, Icons.local_gas_station,
    Icons.home, Icons.school, Icons.work, Icons.fitness_center, Icons.movie,
    Icons.music_note, Icons.pets, Icons.flight, Icons.hotel, Icons.local_hospital,
    Icons.local_pharmacy, Icons.car_repair, Icons.build, Icons.cleaning_services,
    Icons.child_care, Icons.sports_soccer, Icons.pool, Icons.park, Icons.cake,
    Icons.coffee, Icons.fastfood, Icons.local_pizza, Icons.icecream, Icons.wine_bar,
    Icons.directions_car, Icons.phone_android,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                      child: Icon(Icons.close, color: Colors.grey[600], size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Create Category', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black))),
                ],
              ),
              const SizedBox(height: 24),
              Text('Category Name', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700])),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter name...',
                  hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
                  filled: true,
                  fillColor: const Color(0xFFF8F8F8),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2)),
                ),
              ),
              const SizedBox(height: 20),
              Text('Select Icon', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700])),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF8F8F8), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: const Color(0xFF1976D2), borderRadius: BorderRadius.circular(10)),
                      child: Icon(_selectedIcon, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text('Selected', style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600])),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 160,
                decoration: BoxDecoration(color: const Color(0xFFF8F8F8), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
                child: GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, crossAxisSpacing: 6, mainAxisSpacing: 6),
                  itemCount: _availableIcons.length,
                  itemBuilder: (context, index) {
                    final icon = _availableIcons[index];
                    final isSelected = icon == _selectedIcon;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = icon),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF1976D2) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isSelected ? const Color(0xFF1976D2) : Colors.grey[300]!, width: isSelected ? 2 : 1),
                        ),
                        child: Icon(icon, color: isSelected ? Colors.white : Colors.grey[600], size: 18),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _createCategory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Save', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createCategory() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a category name', style: GoogleFonts.inter(color: Colors.white)), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
      );
      return;
    }
    widget.onCategoryCreated(CategoryData(name: _nameController.text.trim(), icon: _selectedIcon));
    Navigator.pop(context);
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
    final colors = [const Color(0xFF1976D2), const Color(0xFF2196F3), const Color(0xFF64B5F6), const Color(0xFF90CAF9), const Color(0xFFBBDEFB), const Color(0xFFE3F2FD)];
    double startAngle = -math.pi / 2;
    int colorIndex = 0;

    categoryTotals.forEach((category, amount) {
      if (amount > 0) {
        final sweepAngle = (amount / totalAmount) * 2 * math.pi;
        final paint = Paint()..color = colors[colorIndex % colors.length]..style = PaintingStyle.fill;
        canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, true, paint);
        final percentage = ((amount / totalAmount) * 100).round();
        if (percentage >= 10) {
          final textAngle = startAngle + sweepAngle / 2;
          final textRadius = radius * 0.7;
          final textX = center.dx + textRadius * math.cos(textAngle);
          final textY = center.dy + textRadius * math.sin(textAngle);
          final textPainter = TextPainter(
            text: TextSpan(text: '$category\n$percentage%', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          textPainter.paint(canvas, Offset(textX - textPainter.width / 2, textY - textPainter.height / 2));
        }
        startAngle += sweepAngle;
        colorIndex++;
      }
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
