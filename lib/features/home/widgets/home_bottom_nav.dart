import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class HomeBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const HomeBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFE8E9F3),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Icons.home_rounded, 0, true),
              _buildNavItem(Icons.notifications_outlined, 1, false),
              const SizedBox(width: 70),
              _buildNavItem(Icons.access_time, 2, false),
              _buildNavItem(Icons.person_outline, 3, false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, bool isHome) {
    final isSelected = selectedIndex == index;

    if (isHome && isSelected) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      );
    }

    return GestureDetector(
      onTap: () => onItemSelected(index),
      child: Icon(icon, color: Colors.black, size: 28),
    );
  }
}
