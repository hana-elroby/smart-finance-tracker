import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Date range filter widget for expense charts
class DateRangeFilter extends StatelessWidget {
  final DateTime? fromDate;
  final DateTime? toDate;
  final VoidCallback onFromDateTap;
  final VoidCallback onToDateTap;

  const DateRangeFilter({
    super.key,
    required this.fromDate,
    required this.toDate,
    required this.onFromDateTap,
    required this.onToDateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: _DateField(
            label: 'From',
            date: fromDate,
            onTap: onFromDateTap,
          ),
        ),
        const Spacer(),
        SizedBox(
          width: 120,
          child: _DateField(label: 'To', date: toDate, onTap: onToDateTap),
        ),
      ],
    );
  }
}

/// Individual date field widget
class _DateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateField({
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
              '$label: ${_formatDate(date)}',
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select';
    return '${date.day}/${date.month}';
  }
}


