import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/home/home_page.dart';
import '../features/categories/categories_page.dart';
import '../features/profile/profile_page.dart';
import '../features/offers/offers_page.dart';
import '../features/home/bloc/expense_bloc.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;
  
  const MainLayout({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout>
    with TickerProviderStateMixin {
  late int _selectedIndex;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _fabScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExpenseBloc(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        body: _getPage(_selectedIndex),
        bottomNavigationBar: _buildCustomBottomNav(),
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const HomePage();
      case 1:
        return const OffersPage();
      case 2:
        return const CategoriesPage();
      case 3:
        return const ProfilePage();
      default:
        return const HomePage();
    }
  }



  Widget _buildCustomBottomNav() {
    return Container(
      height: 75,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Custom shaped navigation bar with conditional notch
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 75),
            painter: BottomNavPainter(showNotch: _shouldShowFAB()),
          ),
          
          // Navigation content - نفس اللي في الـ Home
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: _shouldShowFAB() 
                ? Row(
                    children: [
                      // Left side navigation items
                      Expanded(child: _buildSimpleNavItem(Icons.home_rounded, 'Home', 0)),
                      Expanded(child: _buildSimpleNavItem(Icons.local_offer_rounded, 'Offers', 1)),
                      
                      // Center space for FAB
                      const SizedBox(width: 80),
                      
                      // Right side navigation items
                      Expanded(child: _buildSimpleNavItem(Icons.grid_view_rounded, 'Categories', 2)),
                      Expanded(child: _buildSimpleNavItem(Icons.person_rounded, 'Profile', 3)),
                    ],
                  )
                : Row(
                    children: [
                      // All navigation items evenly distributed without center gap
                      Expanded(child: _buildSimpleNavItem(Icons.home_rounded, 'Home', 0)),
                      Expanded(child: _buildSimpleNavItem(Icons.local_offer_rounded, 'Offers', 1)),
                      Expanded(child: _buildSimpleNavItem(Icons.grid_view_rounded, 'Categories', 2)),
                      Expanded(child: _buildSimpleNavItem(Icons.person_rounded, 'Profile', 3)),
                    ],
                  ),
            ),
          ),
          
          // Center FAB positioned in the notch (only on Home and Categories)
          if (_shouldShowFAB())
            Positioned(
              left: MediaQuery.of(context).size.width / 2 - 35,
              top: -12,
              child: _buildCenterFAB(),
            ),
        ],
      ),
    );
  }

  bool _shouldShowFAB() {
    return _selectedIndex == 0 || _selectedIndex == 2; // Home or Categories
  }

  Widget _buildSimpleNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    const selectedColor = Color(0xFF003B73);
    
    return GestureDetector(
      onTap: () => _onNavItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container - حجم ثابت وصغير
            Container(
              width: 36, // حجم صغير ثابت
              height: 36,
              decoration: BoxDecoration(
                color: isSelected ? selectedColor.withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isSelected ? _getFilledIcon(icon) : icon,
                color: isSelected ? selectedColor : Colors.grey.shade500,
                size: 20, // أيقونة صغيرة
              ),
            ),
            
            const SizedBox(height: 4), // زودت المساحة من 2 لـ 4
            
            // Text أكبر وأوضح
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12, // كبرت من 10 لـ 12
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600, // زودت الـ weight
                color: isSelected ? selectedColor : Colors.grey.shade700, // غمقت اللون
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFilledIcon(IconData icon) {
    switch (icon) {
      case Icons.home_rounded:
        return Icons.home;
      case Icons.local_offer_rounded:
        return Icons.local_offer;
      case Icons.grid_view_rounded:
        return Icons.grid_view;
      case Icons.person_rounded:
        return Icons.person;
      default:
        return icon;
    }
  }

  Widget _buildCenterFAB() {
    return GestureDetector(
      onTapDown: (_) => _fabAnimationController.forward(),
      onTapUp: (_) => _fabAnimationController.reverse(),
      onTapCancel: () => _fabAnimationController.reverse(),
      onTap: () {
        HapticFeedback.mediumImpact();
        _showAddExpenseBottomSheet();
      },
      child: AnimatedBuilder(
        animation: _fabScaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabScaleAnimation.value,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF42A5F5).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: const Color(0xFF1976D2).withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                  BoxShadow(
                    color: Colors.white,
                    blurRadius: 0,
                    offset: const Offset(0, 0),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          );
        },
      ),
    );
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showAddExpenseBottomSheet() {
    // TODO: Implement add expense bottom sheet
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add Expense - Coming soon!'),
        backgroundColor: Color(0xFF1687F0),
        duration: Duration(seconds: 1),
      ),
    );
  }
}

/// Custom painter for bottom navigation bar with conditional center notch
class BottomNavPainter extends CustomPainter {
  final bool showNotch;
  
  const BottomNavPainter({this.showNotch = true});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final path = Path();
    final shadowPath = Path();

    // Start from bottom left
    path.moveTo(0, size.height);
    shadowPath.moveTo(0, size.height);

    // Left side of navigation bar
    path.lineTo(0, 0);
    shadowPath.lineTo(0, -2);

    if (showNotch) {
      // Draw with notch
      const double notchRadius = 40.0;
      const double notchMargin = 7.0;
      final double centerX = size.width / 2;

      // Top left to start of notch
      path.lineTo(centerX - notchRadius - notchMargin, 0);
      shadowPath.lineTo(centerX - notchRadius - notchMargin, -2);

      // Create smooth notch curve
      path.quadraticBezierTo(
        centerX - notchRadius, 0,
        centerX - notchRadius, notchMargin,
      );
      shadowPath.quadraticBezierTo(
        centerX - notchRadius, -2,
        centerX - notchRadius, notchMargin - 2,
      );

      // Notch curve - left side
      path.arcToPoint(
        Offset(centerX + notchRadius, notchMargin),
        radius: const Radius.circular(notchRadius),
        clockwise: false,
      );
      shadowPath.arcToPoint(
        Offset(centerX + notchRadius, notchMargin - 2),
        radius: const Radius.circular(notchRadius),
        clockwise: false,
      );

      // Notch curve - right side
      path.quadraticBezierTo(
        centerX + notchRadius, 0,
        centerX + notchRadius + notchMargin, 0,
      );
      shadowPath.quadraticBezierTo(
        centerX + notchRadius, -2,
        centerX + notchRadius + notchMargin, -2,
      );
    } else {
      // Draw straight line without notch
      path.lineTo(size.width, 0);
      shadowPath.lineTo(size.width, -2);
    }

    // Right side of navigation bar (if notch was drawn, this continues from notch end)
    if (showNotch) {
      path.lineTo(size.width, 0);
      shadowPath.lineTo(size.width, -2);
    }

    // Bottom right
    path.lineTo(size.width, size.height);
    shadowPath.lineTo(size.width, size.height);

    // Close the path
    path.close();
    shadowPath.close();

    // Draw shadow first
    canvas.drawPath(shadowPath, shadowPaint);

    // Draw the main navigation bar
    canvas.drawPath(path, paint);

    // Add subtle inner shadow for depth
    final innerShadowPaint = Paint()
      ..color = Colors.grey.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawPath(path, innerShadowPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}