// اختبار الـ Chart الديناميكي للكمية
// Test Dynamic Count Chart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'lib/features/home/bloc/expense_bloc.dart';
import 'lib/features/home/bloc/expense_event.dart';
import 'lib/core/models/expense.dart';
import 'lib/features/items/items_page.dart';

void main() {
  runApp(const DynamicCountChartTestApp());
}

class DynamicCountChartTestApp extends StatelessWidget {
  const DynamicCountChartTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamic Count Chart Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: GoogleFonts.inter().fontFamily,
      ),
      home: BlocProvider(
        create: (context) => ExpenseBloc(),
        child: const DynamicCountChartTestPage(),
      ),
    );
  }
}

class DynamicCountChartTestPage extends StatefulWidget {
  const DynamicCountChartTestPage({super.key});

  @override
  State<DynamicCountChartTestPage> createState() => _DynamicCountChartTestPageState();
}

class _DynamicCountChartTestPageState extends State<DynamicCountChartTestPage> {
  int _coffeeCount = 0;
  int _pizzaCount = 0;
  int _breadCount = 0;
  int _waterCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic Count Chart Test'),
        backgroundColor: const Color(0xFF0D5DB8),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Dynamic Count Chart',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'الـ Chart يعرض عدد المرات مش المبلغ',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Add Sample Data Buttons
            Text(
              'Add Sample Data:',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 12),

            // Coffee Button
            _buildAddButton(
              'Add Coffee',
              Icons.local_cafe,
              Colors.brown,
              () => _addExpense('coffee', 30.0),
              _coffeeCount,
            ),

            // Pizza Button
            _buildAddButton(
              'Add Pizza',
              Icons.local_pizza,
              Colors.orange,
              () => _addExpense('pizza', 120.0),
              _pizzaCount,
            ),

            // Bread Button
            _buildAddButton(
              'Add Bread',
              Icons.bakery_dining,
              Colors.amber,
              () => _addExpense('bread', 15.0),
              _breadCount,
            ),

            // Water Button
            _buildAddButton(
              'Add Water',
              Icons.water_drop,
              Colors.blue,
              () => _addExpense('water', 5.0),
              _waterCount,
            ),

            const SizedBox(height: 24),

            // View Chart Button
            ElevatedButton.icon(
              onPressed: _viewChart,
              icon: const Icon(Icons.bar_chart_rounded, size: 24),
              label: const Text(
                'View Dynamic Count Chart',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),

            const SizedBox(height: 16),

            // Clear Data Button
            OutlinedButton.icon(
              onPressed: _clearData,
              icon: const Icon(Icons.clear_all, size: 20),
              label: const Text('Clear All Data'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_rounded, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'كيفية الاختبار:',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1️⃣ اضغط على الأزرار لإضافة عناصر مختلفة\n'
                    '2️⃣ اضغط على نفس العنصر عدة مرات\n'
                    '3️⃣ اضغط "View Dynamic Count Chart"\n'
                    '4️⃣ شوف الـ Chart يعرض عدد المرات (2x, 3x, إلخ)\n'
                    '5️⃣ اضغط على الـ bars لرؤية التفاصيل',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.blue[700],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Expected Results
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'النتائج المتوقعة:',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '✅ الـ Y-axis يعرض "Count" بدل "EGP"\n'
                    '✅ الأرقام فوق الـ bars تعرض "2x", "3x"\n'
                    '✅ الـ Chart يرتب العناصر حسب الكمية\n'
                    '✅ الضغط على الـ bar يعرض "purchased X times"\n'
                    '✅ الـ Chart ديناميكي ويتغير مع البيانات',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.green[700],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
    int count,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Row(
          children: [
            Text(label),
            const Spacer(),
            if (count > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${count}x',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  void _addExpense(String itemName, double amount) {
    final expense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: itemName,
      amount: amount,
      category: 'Food & Drink',
      date: DateTime.now(),
    );

    context.read<ExpenseBloc>().add(AddExpense(expense));

    setState(() {
      switch (itemName) {
        case 'coffee':
          _coffeeCount++;
          break;
        case 'pizza':
          _pizzaCount++;
          break;
        case 'bread':
          _breadCount++;
          break;
        case 'water':
          _waterCount++;
          break;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $itemName (${_getCount(itemName)}x total)'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  int _getCount(String itemName) {
    switch (itemName) {
      case 'coffee':
        return _coffeeCount;
      case 'pizza':
        return _pizzaCount;
      case 'bread':
        return _breadCount;
      case 'water':
        return _waterCount;
      default:
        return 0;
    }
  }

  void _viewChart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<ExpenseBloc>(),
          child: const ItemsPage(
            categoryName: 'Food & Drink',
            categoryIcon: Icons.restaurant,
            categoryColor: Color(0xFF10B981),
          ),
        ),
      ),
    );
  }

  void _clearData() {
    // This would require implementing a clear all method in ExpenseBloc
    // For now, just reset the counters
    setState(() {
      _coffeeCount = 0;
      _pizzaCount = 0;
      _breadCount = 0;
      _waterCount = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data cleared (counters reset)'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}