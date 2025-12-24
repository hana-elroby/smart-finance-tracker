import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class HomeProgressBar extends StatelessWidget {
  const HomeProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Motivational quotes rotation
    final List<String> quotes = [
      "Every penny counts! Keep tracking!",
      "Smart spending starts here!",
      "Your wallet will thank you!",
      "Small steps, big savings!",
      "Financial freedom is a journey!",
      "Track today, save tomorrow!",
    ];

    // Pick a quote based on day of month (simple rotation)
    final int dayOfMonth = DateTime.now().day;
    final String quote = quotes[dayOfMonth % quotes.length];

    return Row(
      children: [
        const Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 26),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            quote,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}



