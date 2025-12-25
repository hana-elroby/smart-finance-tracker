// Analytics Page - صفحة التحليلات
// Shows transaction analytics and charts from API

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/transaction_model.dart';
import '../../transactions/presentation/bloc/transaction_bloc.dart';
import '../../transactions/presentation/bloc/transaction_event.dart';
import '../../transactions/presentation/bloc/transaction_state.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      // Load transactions if not already loaded
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final state = context.read<TransactionBloc>().state;
          if (state.transactions.isEmpty) {
            context.read<TransactionBloc>().add(const LoadTransactions());
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state.isLoading && state.transactions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Calculate analytics data
          final analytics = _calculateAnalytics(state.transactions);

          return RefreshIndicator(
            onRefresh: () async {
              context.read<TransactionBloc>().add(const LoadTransactions());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'This Week',
                          analytics.weekTotal,
                          Icons.date_range,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          'This Month',
                          analytics.monthTotal,
                          Icons.calendar_month,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Weekly Chart
                  _buildSectionTitle('Last 7 Days'),
                  const SizedBox(height: 12),
                  _buildWeeklyChart(analytics.dailyExpenses),
                  const SizedBox(height: 24),

                  // Category Breakdown
                  _buildSectionTitle('Spending by Category'),
                  const SizedBox(height: 12),
                  _buildCategoryList(analytics),
                  const SizedBox(height: 24),

                  // Category Pie Chart
                  if (analytics.categoryTotals.isNotEmpty) ...[
                    _buildSectionTitle('Category Distribution'),
                    const SizedBox(height: 12),
                    _buildCategoryPieChart(analytics),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  _AnalyticsData _calculateAnalytics(List<TransactionModel> transactions) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    double totalAmount = 0;
    double weekTotal = 0;
    double monthTotal = 0;
    final categoryTotals = <String, double>{};
    final dailyMap = <String, double>{};

    // Initialize daily map for last 7 days
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = '${date.day}/${date.month}';
      dailyMap[key] = 0;
    }

    for (final t in transactions) {
      totalAmount += t.price;

      // Week total
      if (t.createdAt.isAfter(weekStart.subtract(const Duration(days: 1)))) {
        weekTotal += t.price;
      }

      // Month total
      if (t.createdAt.isAfter(monthStart.subtract(const Duration(days: 1)))) {
        monthTotal += t.price;
      }

      // Category totals
      final category = t.categoryName ?? 'Other';
      categoryTotals[category] = (categoryTotals[category] ?? 0) + t.price;

      // Daily expenses (last 7 days)
      final daysDiff = now.difference(t.createdAt).inDays;
      if (daysDiff >= 0 && daysDiff < 7) {
        final key = '${t.createdAt.day}/${t.createdAt.month}';
        dailyMap[key] = (dailyMap[key] ?? 0) + t.price;
      }
    }

    return _AnalyticsData(
      totalAmount: totalAmount,
      weekTotal: weekTotal,
      monthTotal: monthTotal,
      categoryTotals: categoryTotals,
      dailyExpenses: dailyMap.entries
          .map((e) => _DailyExpense(e.key, e.value))
          .toList(),
    );
  }

  Widget _buildSummaryCard(
    String title,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            '${amount.toStringAsFixed(0)} EGP',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildWeeklyChart(List<_DailyExpense> dailyExpenses) {
    final maxAmount = dailyExpenses.isEmpty
        ? 100.0
        : dailyExpenses.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
    final chartMax = maxAmount == 0 ? 100.0 : maxAmount * 1.2;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: dailyExpenses.map((daily) {
                final height = chartMax > 0
                    ? (daily.amount / chartMax * 120)
                    : 0.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (daily.amount > 0)
                          Text(
                            '${daily.amount.toInt()}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Container(
                          height: height.clamp(4.0, 120.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withOpacity(0.6),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: dailyExpenses.map((daily) {
              return Expanded(
                child: Text(
                  daily.date,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(_AnalyticsData analytics) {
    if (analytics.categoryTotals.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'No transactions to analyze',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final sortedCategories = analytics.categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: sortedCategories.map((entry) {
          final percentage = analytics.totalAmount > 0
              ? (entry.value / analytics.totalAmount * 100)
              : 0.0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(Icons.category, size: 18, color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation(
                            AppColors.primary,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${entry.value.toStringAsFixed(0)} EGP',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryPieChart(_AnalyticsData analytics) {
    final sortedCategories = analytics.categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
      Colors.cyan,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          // Simple pie representation
          SizedBox(
            width: 100,
            height: 100,
            child: CustomPaint(
              painter: _SimplePieChartPainter(
                values: sortedCategories.map((e) => e.value).toList(),
                colors: colors,
                total: analytics.totalAmount,
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Legend
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: sortedCategories.take(5).toList().asMap().entries.map((entry) {
                final index = entry.key;
                final category = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: colors[index % colors.length],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          category.key,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
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
    );
  }
}

class _AnalyticsData {
  final double totalAmount;
  final double weekTotal;
  final double monthTotal;
  final Map<String, double> categoryTotals;
  final List<_DailyExpense> dailyExpenses;

  _AnalyticsData({
    required this.totalAmount,
    required this.weekTotal,
    required this.monthTotal,
    required this.categoryTotals,
    required this.dailyExpenses,
  });
}

class _DailyExpense {
  final String date;
  final double amount;

  _DailyExpense(this.date, this.amount);
}

class _SimplePieChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final double total;

  _SimplePieChartPainter({
    required this.values,
    required this.colors,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    double startAngle = -90 * 3.14159 / 180;

    for (int i = 0; i < values.length; i++) {
      final sweepAngle = total > 0
          ? (values[i] / total) * 2 * 3.14159
          : 0.0;

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

      startAngle += sweepAngle;
    }

    // Draw center circle for donut effect
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.5, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
