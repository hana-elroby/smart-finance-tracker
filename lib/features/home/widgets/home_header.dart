import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class HomeHeader extends StatelessWidget {
  final String userName;

  const HomeHeader({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Hi $userName!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('👋', style: TextStyle(fontSize: 24)),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Welcome Back',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
        // Notification Icon with Gradient border
        Container(
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
      ],
    );
  }
}
