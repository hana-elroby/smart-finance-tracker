import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Chart Placeholder Widget
/// Shows when no data exists - indicates charts will appear after adding items
class ChartPlaceholder extends StatelessWidget {
  final String title;
  final double height;
  final ChartPlaceholderType type;

  const ChartPlaceholder({
    super.key,
    this.title = 'Your Spending Overview',
    this.height = 240,
    this.type = ChartPlaceholderType.line,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF003566),
            ),
          ),
          const SizedBox(height: 12),
          _buildPlaceholderContent(),
        ],
      ),
    );
  }

  Widget _buildPlaceholderContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Placeholder illustration based on type
        _buildPlaceholderIllustration(),
        const SizedBox(height: 12),
        // Message
        Text(
          'No data yet',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Add items to see your charts',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF9CA3AF),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        // Add button hint
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF003566).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.add_circle_outline_rounded,
                size: 14,
                color: Color(0xFF003566),
              ),
              const SizedBox(width: 4),
              Text(
                'Tap + to add expense',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF003566),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderIllustration() {
    switch (type) {
      case ChartPlaceholderType.line:
        return _buildLinePlaceholder();
      case ChartPlaceholderType.pie:
        return _buildPiePlaceholder();
      case ChartPlaceholderType.bar:
        return _buildBarPlaceholder();
    }
  }

  Widget _buildLinePlaceholder() {
    // Create a nice animated-looking line chart preview
    return SizedBox(
      height: 60,
      child: CustomPaint(
        size: const Size(double.infinity, 60),
        painter: _LinePlaceholderPainter(),
      ),
    );
  }

  Widget _buildPiePlaceholder() {
    // Create a colorful pie chart preview
    return SizedBox(
      width: 80,
      height: 80,
      child: CustomPaint(painter: _PiePlaceholderPainter()),
    );
  }

  Widget _buildBarPlaceholder() {
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(5, (index) {
          final heights = [30.0, 50.0, 25.0, 40.0, 35.0];
          final colors = [
            const Color(0xFF003566).withValues(alpha: 0.3),
            const Color(0xFF003566).withValues(alpha: 0.5),
            const Color(0xFF003566).withValues(alpha: 0.25),
            const Color(0xFF003566).withValues(alpha: 0.4),
            const Color(0xFF003566).withValues(alpha: 0.35),
          ];
          return Container(
            width: 35,
            height: heights[index],
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors[index], colors[index].withValues(alpha: 0.1)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          );
        }),
      ),
    );
  }
}

class _LinePlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF003566).withValues(alpha: 0.3)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF003566).withValues(alpha: 0.15),
          const Color(0xFF003566).withValues(alpha: 0.02),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Create smooth curve points
    final points = [
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.15, size.height * 0.5),
      Offset(size.width * 0.3, size.height * 0.6),
      Offset(size.width * 0.45, size.height * 0.3),
      Offset(size.width * 0.6, size.height * 0.45),
      Offset(size.width * 0.75, size.height * 0.25),
      Offset(size.width * 0.9, size.height * 0.4),
      Offset(size.width, size.height * 0.35),
    ];

    // Draw filled area
    final fillPath = Path()..moveTo(0, size.height);
    for (int i = 0; i < points.length; i++) {
      if (i == 0) {
        fillPath.lineTo(points[i].dx, points[i].dy);
      } else {
        final cp1 = Offset(
          points[i - 1].dx + (points[i].dx - points[i - 1].dx) / 2,
          points[i - 1].dy,
        );
        final cp2 = Offset(
          points[i - 1].dx + (points[i].dx - points[i - 1].dx) / 2,
          points[i].dy,
        );
        fillPath.cubicTo(
          cp1.dx,
          cp1.dy,
          cp2.dx,
          cp2.dy,
          points[i].dx,
          points[i].dy,
        );
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final cp1 = Offset(
        points[i - 1].dx + (points[i].dx - points[i - 1].dx) / 2,
        points[i - 1].dy,
      );
      final cp2 = Offset(
        points[i - 1].dx + (points[i].dx - points[i - 1].dx) / 2,
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

    // Draw dots at each point
    final dotPaint = Paint()
      ..color = const Color(0xFF003566).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    for (var point in points) {
      canvas.drawCircle(point, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PiePlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Colors for pie segments
    final colors = [
      const Color(0xFF003566),
      const Color(0xFF1687F0),
      const Color(0xFF64B5F6),
      const Color(0xFFBBDEFB),
    ];

    // Draw pie segments
    double startAngle = -1.57; // Start from top
    final sweeps = [0.35, 0.25, 0.22, 0.18]; // Percentages

    for (int i = 0; i < colors.length; i++) {
      final sweepAngle = sweeps[i] * 2 * 3.14159;
      final paint = Paint()
        ..color = colors[i].withValues(alpha: 0.6)
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

    // Draw center hole for donut effect
    final holePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.5, holePaint);

    // Draw percentage text in center
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '0%',
        style: TextStyle(
          color: Color(0xFF003566),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum ChartPlaceholderType { line, pie, bar }
