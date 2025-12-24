import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Expense chart section widget
class ExpenseChartSection extends StatelessWidget {
  final DateTime? fromDate;
  final DateTime? toDate;
  final VoidCallback onFromDateTap;
  final VoidCallback onToDateTap;

  const ExpenseChartSection({
    super.key,
    required this.fromDate,
    required this.toDate,
    required this.onFromDateTap,
    required this.onToDateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF8FAFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D5DB8).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Spending Overview',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 16),
          _buildDateFilters(),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: CustomPaint(
              size: const Size(double.infinity, 200),
              painter: _ExpenseChartPainter(fromDate: fromDate, toDate: toDate),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilters() {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: _SimpleDateField(
            label: 'From',
            date: fromDate,
            onTap: onFromDateTap,
          ),
        ),
        const Spacer(),
        SizedBox(
          width: 120,
          child: _SimpleDateField(
            label: 'To',
            date: toDate,
            onTap: onToDateTap,
          ),
        ),
      ],
    );
  }
}

/// Simple date field widget
class _SimpleDateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _SimpleDateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            const Icon(
              Icons.calendar_today_outlined,
              color: Color(0xFF1478E0),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              '$label: ${date != null ? '${date!.day}/${date!.month}' : 'Select'}',
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
}

/// Custom painter for expense chart
class _ExpenseChartPainter extends CustomPainter {
  final DateTime? fromDate;
  final DateTime? toDate;

  _ExpenseChartPainter({this.fromDate, this.toDate});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1478E0)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF1478E0).withValues(alpha: 0.25),
          const Color(0xFF8B5CF6).withValues(alpha: 0.08),
          const Color(0xFFEC4899).withValues(alpha: 0.04),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final mockData = _generateMockData();
    final points = _calculatePoints(mockData, size);

    if (points.isEmpty) return;

    // Create smooth curve path for fill
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      final cp1 = Offset(
        points[i - 1].dx + (points[i].dx - points[i - 1].dx) * 0.4,
        points[i - 1].dy,
      );
      final cp2 = Offset(
        points[i].dx - (points[i].dx - points[i - 1].dx) * 0.4,
        points[i].dy,
      );
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i].dx, points[i].dy);
    }

    path.lineTo(size.width, size.height);
    path.close();

    // Draw filled area
    canvas.drawPath(path, fillPaint);

    // Draw line
    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final cp1 = Offset(
        points[i - 1].dx + (points[i].dx - points[i - 1].dx) * 0.4,
        points[i - 1].dy,
      );
      final cp2 = Offset(
        points[i].dx - (points[i].dx - points[i - 1].dx) * 0.4,
        points[i].dy,
      );
      linePath.cubicTo(
        cp1.dx,
        cp1.dy,
        cp2.dx,
        cp2.dy,
        points[i].dx,
        points[i].dy,
      );
    }
    canvas.drawPath(linePath, paint);

    // Draw data points
    final pointPaint = Paint()
      ..color = const Color(0xFF1478E0)
      ..style = PaintingStyle.fill;

    final pointBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 6, pointBorderPaint);
      canvas.drawCircle(point, 4, pointPaint);
    }

    // Draw grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1;

    for (int i = 1; i < 5; i++) {
      final y = (size.height / 5) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  List<double> _generateMockData() {
    if (fromDate == null || toDate == null) {
      return [850, 1200, 950, 1400, 800, 1100, 750];
    }

    final daysDiff = toDate!.difference(fromDate!).inDays;
    final dataPoints = (daysDiff / 7).ceil().clamp(3, 12);

    final List<double> data = [];
    final random = DateTime.now().millisecond;

    for (int i = 0; i < dataPoints; i++) {
      final baseAmount = 800 + (random % 600);
      final variation = (random * (i + 1)) % 400 - 200;
      final amount = (baseAmount + variation).clamp(200, 1600).toDouble();
      data.add(amount);
    }

    return data;
  }

  List<Offset> _calculatePoints(List<double> data, Size size) {
    if (data.isEmpty) return [];

    final maxAmount = data.reduce((a, b) => a > b ? a : b);
    final minAmount = data.reduce((a, b) => a < b ? a : b);
    final range = maxAmount - minAmount;

    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final amount = entry.value;

      final x = (size.width / (data.length - 1)) * index;
      final normalizedAmount = range > 0 ? (amount - minAmount) / range : 0.5;
      final y = size.height * (1 - (normalizedAmount * 0.7 + 0.15));

      return Offset(x, y);
    }).toList();
  }

  @override
  bool shouldRepaint(covariant _ExpenseChartPainter oldDelegate) {
    return oldDelegate.fromDate != fromDate || oldDelegate.toDate != toDate;
  }
}


