import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../core/theme/app_colors.dart';
import '../home/dialogs/category_dialog.dart';
import '../home/dialogs/manual_entry_dialog.dart';
import '../home/dialogs/voice_recording_dialog.dart';
import '../home/dialogs/success_dialog.dart';
import '../home/dialogs/category_analysis_dialog.dart';
import '../home/widgets/simple_bottom_nav.dart';
import '../home/home_page.dart';
import '../analysis/analysis_page.dart';
import '../profile/profile_page.dart';
import '../home/bloc/expense_bloc.dart';
import '../home/bloc/expense_state.dart';

/// Categories Page - عرض جميع الفئات
/// يعرض جميع فئات المصروفات في شكل Grid
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
  int _selectedIndex = 0; // للـ navbar
  ExpenseBloc? _expenseBloc;

  // Custom categories list
  final List<Map<String, dynamic>> _customCategories = [];

  @override
  void initState() {
    super.initState();
    _loadCustomCategories();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_expenseBloc == null) {
      try {
        _expenseBloc = context.read<ExpenseBloc>();
      } catch (e) {
        // If no bloc in context, create new one
        _expenseBloc = ExpenseBloc();
      }
    }
  }

  // Load custom categories from SharedPreferences
  Future<void> _loadCustomCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = prefs.getString('custom_categories');
    if (categoriesJson != null) {
      final List<dynamic> decoded = json.decode(categoriesJson);
      if (mounted) {
        setState(() {
          _customCategories.clear();
          for (var item in decoded) {
            _customCategories.add({
              'name': item['name'],
              'icon': IconData(item['iconCode'], fontFamily: 'MaterialIcons'),
              'gradient': _getRandomGradient(item['gradientIndex']),
            });
          }
        });
      }
    }
  }

  // Save custom categories to SharedPreferences
  Future<void> _saveCustomCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesToSave = _customCategories.map((cat) {
      return {
        'name': cat['name'],
        'iconCode': (cat['icon'] as IconData).codePoint,
        'gradientIndex': _customCategories.indexOf(cat),
      };
    }).toList();
    final categoriesJson = json.encode(categoriesToSave);
    await prefs.setString('custom_categories', categoriesJson);
  }

  @override
  Widget build(BuildContext context) {
    if (_expenseBloc == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BlocProvider.value(
      value: _expenseBloc!,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'categories',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0814F9), Color(0xFFF509D6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(6),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications,
                    color: Color(0xFFFFC107),
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Categories Grid (2x2 + Add button)
                BlocBuilder<ExpenseBloc, ExpenseState>(
                  builder: (context, state) {
                    // Get totals from BLoC
                    double shoppingTotal = 0;
                    double billsTotal = 0;
                    double healthTotal = 0;
                    double foodTotal = 0;

                    // Get all unique categories from expenses
                    Set<String> allCategories = {};
                    Map<String, double> categoryTotals = {};

                    if (state is ExpenseLoaded) {
                      shoppingTotal = state.getCategoryTotal('Shopping');
                      billsTotal = state.getCategoryTotal('Bills');
                      healthTotal = state.getCategoryTotal('Health');
                      foodTotal = state.getCategoryTotal('Food & Drink');

                      // Get all unique categories
                      for (var expense in state.expenses) {
                        allCategories.add(expense.category);
                        categoryTotals[expense.category] = state
                            .getCategoryTotal(expense.category);
                      }
                    }

                    // Filter out default categories to get only custom ones
                    final customCategoryNames = allCategories
                        .where(
                          (cat) =>
                              cat != 'Shopping' &&
                              cat != 'Bills' &&
                              cat != 'Health' &&
                              cat != 'Food & Drink',
                        )
                        .toList();

                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                      children: [
                        _buildCategoryCard(
                          'Shopping',
                          Icons.shopping_bag,
                          '${shoppingTotal.toStringAsFixed(0)} EGP',
                          AppColors.shoppingGradient,
                        ),
                        _buildCategoryCard(
                          'Bills',
                          Icons.receipt_long,
                          '${billsTotal.toStringAsFixed(0)} EGP',
                          AppColors.billsGradient,
                        ),
                        _buildCategoryCard(
                          'Health',
                          Icons.favorite_border,
                          '${healthTotal.toStringAsFixed(0)} EGP',
                          AppColors.healthGradient,
                        ),
                        _buildCategoryCard(
                          'Food & Drink',
                          Icons.restaurant_menu,
                          '${foodTotal.toStringAsFixed(0)} EGP',
                          AppColors.foodGradient,
                        ),
                        // Custom categories from _customCategories (user added)
                        ..._customCategories.asMap().entries.map((entry) {
                          final cat = entry.value;
                          final categoryName = cat['name'];
                          double customTotal = 0;

                          if (state is ExpenseLoaded) {
                            customTotal = state.getCategoryTotal(categoryName);
                          }

                          return _buildCustomCategoryCard(
                            categoryName,
                            cat['icon'],
                            '${customTotal.toStringAsFixed(0)} EGP',
                            cat['gradient'],
                            entry.key,
                          );
                        }),
                        // Add Category Button
                        _buildAddCategoryCard(),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 40),

                // Recent Transactions Section
                const Text(
                  'Recent Transactions',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),

                // Recent Transactions List
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildTransactionItem(
                        'Health',
                        '220 EGP',
                        Icons.favorite_border,
                        const Color(0xFF2ECC71),
                      ),
                      _buildDivider(),
                      _buildTransactionItem(
                        'Bills',
                        '198 EGP',
                        Icons.receipt,
                        const Color(0xFFE74C3C),
                      ),
                      _buildDivider(),
                      _buildTransactionItem(
                        'Shopping',
                        '360 EGP',
                        Icons.shopping_bag_outlined,
                        const Color(0xFF4A90E2),
                      ),
                      _buildDivider(),
                      _buildTransactionItem(
                        'Food',
                        '120 EGP',
                        Icons.restaurant_menu,
                        const Color(0xFF3498DB),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SimpleBottomNav(
          selectedIndex: _selectedIndex,
          onItemSelected: _onNavItemTapped,
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    String title,
    IconData icon,
    String amount,
    LinearGradient gradient,
  ) {
    return GestureDetector(
      onTap: () => _showCategoryDialog(title, icon, gradient),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomCategoryCard(
    String title,
    IconData icon,
    String amount,
    LinearGradient gradient,
    int index,
  ) {
    return GestureDetector(
      onTap: () => _showCategoryDialog(title, icon, gradient),
      onLongPress: () => _showDeleteConfirmation(index, title),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      amount,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Delete icon
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _showDeleteConfirmation(index, title),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(int index, String categoryName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Delete Category',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: Text(
            'Are you sure you want to delete "$categoryName"?',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                _customCategories.removeAt(index);
                await _saveCustomCategories();
                Navigator.pop(context);
                setState(() {});
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAddCategoryCard() {
    return GestureDetector(
      onTap: _showAddCategoryDialog,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF003566), // لون أزرق غامق عادي
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Icon(Icons.add, color: Colors.white, size: 40),
        ),
      ),
    );
  }

  void _showAddCategoryDialog() {
    final TextEditingController nameController = TextEditingController();
    IconData selectedIcon = Icons.category;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (_, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'New Category',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Category Name TextField
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F2F5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: nameController,
                        style: const TextStyle(fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: 'Category Name',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Icon Selection
                    const Text(
                      'Select Icon',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Icons Grid
                    SizedBox(
                      height: 120,
                      child: GridView.count(
                        crossAxisCount: 6,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        children: [
                          _buildIconOption(
                            Icons.restaurant_menu,
                            selectedIcon,
                            (icon) {
                              setDialogState(() => selectedIcon = icon);
                            },
                          ),
                          _buildIconOption(Icons.local_cafe, selectedIcon, (
                            icon,
                          ) {
                            setDialogState(() => selectedIcon = icon);
                          }),
                          _buildIconOption(Icons.shopping_cart, selectedIcon, (
                            icon,
                          ) {
                            setDialogState(() => selectedIcon = icon);
                          }),
                          _buildIconOption(Icons.directions_car, selectedIcon, (
                            icon,
                          ) {
                            setDialogState(() => selectedIcon = icon);
                          }),
                          _buildIconOption(Icons.flight, selectedIcon, (icon) {
                            setDialogState(() => selectedIcon = icon);
                          }),
                          _buildIconOption(Icons.home, selectedIcon, (icon) {
                            setDialogState(() => selectedIcon = icon);
                          }),
                          _buildIconOption(Icons.school, selectedIcon, (icon) {
                            setDialogState(() => selectedIcon = icon);
                          }),
                          _buildIconOption(Icons.fitness_center, selectedIcon, (
                            icon,
                          ) {
                            setDialogState(() => selectedIcon = icon);
                          }),
                          _buildIconOption(Icons.sports_soccer, selectedIcon, (
                            icon,
                          ) {
                            setDialogState(() => selectedIcon = icon);
                          }),
                          _buildIconOption(Icons.pets, selectedIcon, (icon) {
                            setDialogState(() => selectedIcon = icon);
                          }),
                          _buildIconOption(Icons.card_giftcard, selectedIcon, (
                            icon,
                          ) {
                            setDialogState(() => selectedIcon = icon);
                          }),
                          _buildIconOption(Icons.category, selectedIcon, (
                            icon,
                          ) {
                            setDialogState(() => selectedIcon = icon);
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              foregroundColor: Colors.black,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (nameController.text.trim().isNotEmpty) {
                                final newCategory = {
                                  'name': nameController.text.trim(),
                                  'icon': selectedIcon,
                                  'gradient': _getRandomGradient(
                                    _customCategories.length,
                                  ),
                                };

                                _customCategories.add(newCategory);
                                await _saveCustomCategories();
                                Navigator.pop(dialogContext);
                                setState(() {});
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Save',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildIconOption(
    IconData icon,
    IconData selectedIcon,
    Function(IconData) onTap,
  ) {
    final bool isSelected = icon == selectedIcon;
    return GestureDetector(
      onTap: () => onTap(icon),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.black54,
          size: 24,
        ),
      ),
    );
  }

  LinearGradient _getRandomGradient(int index) {
    final gradients = [
      // أحمر فاتح + برتقالي
      const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
      ),
      // بنفسجي + وردي
      const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
      ),
      // برتقالي + أصفر
      const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFF9800), Color(0xFFFFA726)],
      ),
      // أزرق + تيركواز
      const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2196F3), Color(0xFF00BCD4)],
      ),
      // وردي + برتقالي فاتح
      const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFE91E63), Color(0xFFFF6F00)],
      ),
      // تيركواز + أخضر
      const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF00BCD4), Color(0xFF4CAF50)],
      ),
      // أحمر غامق + وردي
      const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFD32F2F), Color(0xFFE91E63)],
      ),
      // أزرق غامق + بنفسجي
      const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1976D2), Color(0xFF7B1FA2)],
      ),
    ];
    return gradients[index % gradients.length];
  }

  Widget _buildTransactionItem(
    String title,
    String amount,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(color: Colors.grey[200], height: 1),
    );
  }

  void _showCategoryDialog(
    String category,
    IconData icon,
    LinearGradient gradient,
  ) {
    showDialog(
      context: context,
      builder: (context) => CategoryDialog(
        category: category,
        icon: icon,
        gradient: gradient,
        onManualEntry: () => _showManualEntry(category, icon, gradient),
        onVoiceRecording: () => _showVoiceRecording(category, icon, gradient),
        onViewAnalysis: () => _showCategoryAnalysis(category, icon, gradient),
      ),
    );
  }

  void _showManualEntry(
    String category,
    IconData icon,
    LinearGradient gradient,
  ) {
    final expenseBloc = context.read<ExpenseBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: expenseBloc,
        child: ManualEntryDialog(
          category: category,
          icon: icon,
          gradient: gradient,
          onSuccess: _showSuccessMessage,
        ),
      ),
    );
  }

  void _showVoiceRecording(
    String category,
    IconData icon,
    LinearGradient gradient,
  ) {
    final expenseBloc = context.read<ExpenseBloc>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: expenseBloc,
        child: VoiceRecordingDialog(
          category: category,
          icon: icon,
          gradient: gradient,
          onSuccess: _showSuccessMessage,
        ),
      ),
    );
  }

  void _showSuccessMessage() {
    showDialog(context: context, builder: (context) => const SuccessDialog());
  }

  void _showCategoryAnalysis(
    String category,
    IconData icon,
    LinearGradient gradient,
  ) {
    final expenseBloc = context.read<ExpenseBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: expenseBloc,
        child: CategoryAnalysisDialog(
          category: category,
          icon: icon,
          gradient: gradient,
        ),
      ),
    );
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Navigate back to Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        break;
      case 1:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Offers - Coming soon!'),
            backgroundColor: AppColors.primary,
          ),
        );
        break;
      case 2:
        // Navigate to Analysis
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider.value(
              value: _expenseBloc!,
              child: const AnalysisPage(),
            ),
          ),
        );
        break;
      case 3:
        // Navigate to Profile
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider.value(
              value: _expenseBloc!,
              child: const ProfilePage(),
            ),
          ),
        );
        break;
    }
  }
}
