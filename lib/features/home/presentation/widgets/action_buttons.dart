import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Action button data model
class ActionButtonData {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const ActionButtonData({
    required this.icon,
    required this.text,
    required this.onTap,
  });
}

/// Modern action buttons row widget
class ActionButtonsRow extends StatelessWidget {
  final List<ActionButtonData> buttons;

  const ActionButtonsRow({super.key, required this.buttons});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: buttons.asMap().entries.map((entry) {
        final index = entry.key;
        final button = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index < buttons.length - 1 ? 12 : 0,
            ),
            child: ModernActionButton(
              icon: button.icon,
              text: button.text,
              onTap: button.onTap,
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Modern action button widget - reusable throughout the app
class ModernActionButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final List<Color>? gradientColors;

  const ModernActionButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
    this.gradientColors,
  });

  static const _defaultGradient = [Color(0xFF42A5F5), Color(0xFF1976D2)];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors ?? _defaultGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (gradientColors?.first ?? _defaultGradient.first)
                  .withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


