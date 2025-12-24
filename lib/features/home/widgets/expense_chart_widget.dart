import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom painter for modern expense chart
class ExpenseChartPainter extends CustomPainter {
  final DateTime? fromDate;
  final DateTime? toDate;
  final List<double>? data;
  final Color lineColor;
  final Color fillColor;

  ExpenseChartPainter({
    this.fromDate,
    this.toDate,
    this.data,
    this.lineColor = const Color(0xFF1478E0),
    this.fillColor = const Color(0xFF1478E0),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          fillColor.withValues(alpha: 0.25),
          const Color(0xFF8B5CF6).withValues(alpha: 0.08),
          const Color(0xFFEC4899).withValues(alpha: 0.04),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Generate data
    final chartData = data ?? _generateMockData();
    final points = _calculatePoints(chartData, size);

    // Draw grid lines
    _drawGridLines(canvas, size);

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
    _drawDataPoints(canvas, points);

    // Draw labels
    _drawLabels(canvas, size, chartData);
  }

  void _drawGridLines(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1;

    for (int i = 1; i < 5; i++) {
      final y = (size.height / 5) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawDataPoints(Canvas canvas, List<Offset> points) {
    final pointPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    final pointBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 6, pointBorderPaint);
      canvas.drawCircle(point, 4, pointPaint);
    }
  }

  void _drawLabels(Canvas canvas, Size size, List<double> chartData) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Y-axis labels
    final yLabels = _generateYAxisLabels(chartData);
    for (int i = 0; i < yLabels.length; i++) {
      textPainter.text = TextSpan(
        text: yLabels[i],
        style: GoogleFonts.inter(
          color: const Color(0xFF6B7280),
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(-40, (size.height / 5) * (i + 1) - textPainter.height / 2),
      );
    }

    // X-axis labels
    final xLabels = _generateXAxisLabels();
    for (int i = 0; i < xLabels.length; i++) {
      textPainter.text = TextSpan(
        text: xLabels[i],
        style: GoogleFonts.inter(
          color: const Color(0xFF6B7280),
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (size.width / (xLabels.length - 1)) * i - textPainter.width / 2,
          size.height + 10,
        ),
      );
    }
  }

  List<double> _generateMockData() {
    if (fromDate == null || toDate == null) {
      return [850, 1200, 950, 1400, 800, 1100, 750];
    }

    final daysDiff = toDate!.difference(fromDate!).inDays;
    final dataPoints = (daysDiff / 7).ceil().clamp(3, 12);
    final random = DateTime.now().millisecond;

    return List.generate(dataPoints, (i) {
      final baseAmount = 800 + (random % 600);
      final variation = (random * (i + 1)) % 400 - 200;
      return (baseAmount + variation).clamp(200, 1600).toDouble();
    });
  }

  List<Offset> _calculatePoints(List<double> chartData, Size size) {
    if (chartData.isEmpty) return [];

    final maxAmount = chartData.reduce((a, b) => a > b ? a : b);
    final minAmount = chartData.reduce((a, b) => a < b ? a : b);
    final range = maxAmount - minAmount;

    return chartData.asMap().entries.map((entry) {
      final index = entry.key;
      final amount = entry.value;

      final x = (size.width / (chartData.length - 1)) * index;
      final normalizedAmount = range > 0 ? (amount - minAmount) / range : 0.5;
      final y = size.height * (1 - (normalizedAmount * 0.7 + 0.15));

      return Offset(x, y);
    }).toList();
  }

  List<String> _generateXAxisLabels() {
    if (fromDate == null || toDate == null) {
      return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];
    }

    final daysDiff = toDate!.difference(fromDate!).inDays;

    if (daysDiff <= 7) {
      return List.generate(7, (i) {
        final date = fromDate!.add(Duration(days: i));
        return '${date.day}';
      });
    } else if (daysDiff <= 31) {
      return ['W1', 'W2', 'W3', 'W4'];
    } else {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final startMonth = fromDate!.month - 1;
      final monthCount =
          ((toDate!.year - fromDate!.year) * 12 +
                  toDate!.month -
                  fromDate!.month +
                  1)
              .clamp(1, 12);

      return List.generate(monthCount, (i) {
        final monthIndex = (startMonth + i) % 12;
        return months[monthIndex];
      });
    }
  }

  List<String> _generateYAxisLabels(List<double> chartData) {
    if (chartData.isEmpty) {
      return ['1.6k', '1.2k', '800', '400', '0'];
    }

    final maxAmount = chartData.reduce((a, b) => a > b ? a : b);
    final minAmount = chartData.reduce((a, b) => a < b ? a : b);
    final range = maxAmount - minAmount;
    final step = (range / 4).ceil();
    final roundedMax = ((maxAmount / 100).ceil() * 100).toDouble();

    return List.generate(5, (i) {
      final amount = roundedMax - (step * i);
      if (amount >= 1000) {
        return '${(amount / 1000).toStringAsFixed(amount % 1000 == 0 ? 0 : 1)}k';
      } else if (amount <= 0) {
        return '0';
      }
      return amount.toInt().toString();
    });
  }

  @override
  bool shouldRepaint(covariant ExpenseChartPainter oldDelegate) {
    return oldDelegate.fromDate != fromDate ||
        oldDelegate.toDate != toDate ||
        oldDelegate.data != data;
  }
}

/// Chart section widget with date filters
class ChartSection extends StatelessWidget {
  final DateTime? fromDate;
  final DateTime? toDate;
  final VoidCallback onFromDateTap;
  final VoidCallback onToDateTap;
  final List<double>? data;

  const ChartSection({
    super.key,
    this.fromDate,
    this.toDate,
    required this.onFromDateTap,
    required this.onToDateTap,
    this.data,
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
          // Date range filter
          Row(
            children: [
              _buildDateButton('From', fromDate, onFromDateTap),
              const Spacer(),
              _buildDateButton('To', toDate, onToDateTap),
            ],
          ),
          const SizedBox(height: 20),
          // Chart
          SizedBox(
            height: 200,
            child: CustomPaint(
              size: const Size(double.infinity, 200),
              painter: ExpenseChartPainter(
                fromDate: fromDate,
                toDate: toDate,
                data: data,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton(String label, DateTime? date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
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
            Flexible(
              child: Text(
                '$label: ${date != null ? '${date.day}/${date.month}' : 'Select'}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF374151),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


