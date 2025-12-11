import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SimpleBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const SimpleBottomNav({
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(Icons.home_rounded, 0,),
              _buildNavItem(Icons.notifications_outlined, 1),
              _buildNavItem(Icons.analytics_outlined, 2),
              _buildNavItem(Icons.person_outline, 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = selectedIndex == index;
    
    // Debug: Force color for testing
    Color iconColor = Colors.grey;
    Color bgColor = Colors.transparent;
    
    if (isSelected) {
      iconColor = Colors.white;
      bgColor = AppColors.primary;
    }

    return GestureDetector(
      onTap: () {
        print('Tapped index: $index, selectedIndex: $selectedIndex');
        onItemSelected(index);
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            icon, 
            color: iconColor, 
            size: 28,
          ),
        ),
      ),
    );
  }
}