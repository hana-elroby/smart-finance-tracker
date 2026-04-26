import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../features/home/home_page.dart';
import '../features/transactions/transactions_page.dart';
import '../features/profile/profile_page.dart';
import '../features/offers/offers_page.dart';
import '../features/home/bloc/expense_bloc.dart';
import '../features/reminders/bloc/reminder_bloc.dart';
import '../features/profile/bloc/user_bloc.dart';
import '../features/categories/bloc/category_bloc.dart';
import 'dialogs/simple_voice_dialog.dart';
import '../core/services/ocr_scanner_service.dart';
import '../core/models/expense.dart';
import '../features/home/bloc/expense_event.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;

  const MainLayout({super.key, this.initialIndex = 0});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _selectedIndex;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  late PageController _pageController;
  bool _showFloatingOptions = false; // Track if floating options are visible

  // Navy Blue Colors - أزرق
  static const Color _navyBlue = Color(0xFF0D5DB8);
  static const Color _navyLight = Color(0xFF1478E0);

  // Pages list - 4 pages
  final List<Widget> _pages = const [
    HomePage(),
    OffersPage(),
    TransactionsPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pageController = PageController(
      initialPage: widget.initialIndex,
      keepPage: true, // Keep pages in memory
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _isHomePage => _selectedIndex == 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _pages.length,
            itemBuilder: (context, index) => _pages[index],
          ),
          // Floating options overlay
          if (_showFloatingOptions && _isHomePage) _buildFloatingOptions(),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: _isHomePage
          ? _buildCurvedNavWithPlus()
          : _buildCurvedNavWithoutPlus(),
    );
  }

  // Floating Scan and Voice buttons above Plus
  Widget _buildFloatingOptions() {
    return GestureDetector(
      onTap: () {
        setState(() => _showFloatingOptions = false);
      },
      child: Container(
        color: Colors.black.withValues(alpha: 0.3),
        child: Stack(
          children: [
            // Scan button (left)
            Positioned(
              bottom: 100,
              left: MediaQuery.of(context).size.width / 2 - 90,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _showFloatingOptions = false);
                  _showScanOptions();
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Color(0xFF374151),
                    size: 26,
                  ),
                ),
              ),
            ),
            // Voice button (right)
            Positioned(
              bottom: 100,
              right: MediaQuery.of(context).size.width / 2 - 90,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _showFloatingOptions = false);
                  _showVoiceInput();
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.mic_rounded,
                        color: const Color(0xFF3B82F6),
                        size: 28,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Curved Nav Bar مع Plus Button - للـ Home فقط
  Widget _buildCurvedNavWithPlus() {
    return CurvedNavigationBar(
      key: _bottomNavigationKey,
      index: 0, // Home is always selected when on home
      height: 65.0,
      items: <Widget>[
        _buildNavIcon(Icons.home_rounded, 'Home', isSelected: true),
        _buildNavIcon(Icons.local_offer_rounded, 'Offers', isSelected: false),
        _buildCenterButton(), // Plus button
        _buildNavIcon(Icons.receipt_long_rounded, 'Transactions', isSelected: false),
        _buildNavIcon(Icons.person_rounded, 'Profile', isSelected: false),
      ],
      color: Colors.white,
      buttonBackgroundColor: _navyBlue,
      backgroundColor: Colors.transparent,
      animationCurve: Curves.easeInOutCubic,
      animationDuration: const Duration(milliseconds: 400),
      onTap: _onNavTappedWithPlus,
      letIndexChange: (index) => true,
    );
  }

  /// Curved Nav Bar بدون Plus - لباقي الصفحات
  Widget _buildCurvedNavWithoutPlus() {
    return CurvedNavigationBar(
      index: _selectedIndex,
      height: 65.0,
      items: <Widget>[
        _buildNavIcon(
          Icons.home_rounded,
          'Home',
          isSelected: _selectedIndex == 0,
        ),
        _buildNavIcon(
          Icons.local_offer_rounded,
          'Offers',
          isSelected: _selectedIndex == 1,
        ),
        _buildNavIcon(
          Icons.receipt_long_rounded,
          'Transactions',
          isSelected: _selectedIndex == 2,
        ),
        _buildNavIcon(
          Icons.person_rounded,
          'Profile',
          isSelected: _selectedIndex == 3,
        ),
      ],
      color: Colors.white,
      buttonBackgroundColor: _navyBlue,
      backgroundColor: Colors.transparent,
      animationCurve: Curves.easeInOutCubic,
      animationDuration: const Duration(milliseconds: 400),
      onTap: _onNavTappedWithoutPlus,
      letIndexChange: (index) => true,
    );
  }

  Widget _buildCenterButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _showFloatingOptions = !_showFloatingOptions;
        });
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_navyLight, _navyBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _navyBlue.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: AnimatedRotation(
          turns: _showFloatingOptions ? 0.125 : 0, // Rotate 45 degrees when open
          duration: const Duration(milliseconds: 200),
          child: const Icon(Icons.add_rounded, size: 32, color: Colors.white),
        ),
      ),
    );
  }

  /// Navigation handler for Home page (5 items with Plus)
  void _onNavTappedWithPlus(int index) {
    HapticFeedback.lightImpact();

    // If center button (Plus) tapped - do nothing, GestureDetector handles it
    if (index == 2) {
      return;
    }

    // Convert 5-item nav index to page index
    int pageIndex;
    if (index < 2) {
      pageIndex = index; // 0, 1 -> 0, 1
    } else {
      pageIndex = index - 1; // 3, 4 -> 2, 3
    }

    setState(() {
      _selectedIndex = pageIndex;
    });

    _pageController.jumpToPage(pageIndex); // Use jumpToPage instead of animateToPage for faster navigation
  }

  /// Navigation handler for other pages (4 items without Plus)
  void _onNavTappedWithoutPlus(int index) {
    HapticFeedback.lightImpact();

    setState(() {
      _selectedIndex = index;
    });

    _pageController.jumpToPage(index); // Use jumpToPage for instant navigation
  }

  Widget _buildNavIcon(
    IconData icon,
    String label, {
    required bool isSelected,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: isSelected ? 28 : 24,
            color: isSelected ? Colors.white : _navyBlue,
          ),
          if (!isSelected) ...[
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: _navyBlue,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showScanOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Scan Receipt',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _navyBlue,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Camera
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(ctx);
                    _runOcrScan(fromCamera: true);
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Color(0xFF3B82F6),
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Camera',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),
                // Gallery
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(ctx);
                    _runOcrScan(fromCamera: false);
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEC4899).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFEC4899).withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.photo_library_rounded,
                          color: Color(0xFFEC4899),
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Gallery',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _runOcrScan({required bool fromCamera}) async {
    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(
              fromCamera ? 'Opening camera...' : 'Opening gallery...',
              style: GoogleFonts.inter(fontSize: 14),
            ),
          ],
        ),
        backgroundColor: _navyBlue,
        duration: const Duration(seconds: 30),
      ),
    );

    final result = fromCamera
        ? await OcrScannerService.instance.scanFromCamera()
        : await OcrScannerService.instance.scanFromGallery();

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (result.isCancelled) return;

    if (result.isSuccess) {
      // Add to ExpenseBloc for immediate UI update
      try {
        final expense = Expense(
          id: result.transactionId!,
          title: result.text ?? 'Receipt scan',
          amount: result.amount ?? 0,
          category: result.category ?? 'Shopping',
          date: DateTime.now(),
        );
        context.read<ExpenseBloc>().add(AddExpense(expense));
      } catch (_) {}

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Receipt scanned: ${result.text} — ${result.amount?.toStringAsFixed(2)} EGP',
            style: GoogleFonts.inter(fontSize: 14),
          ),
          backgroundColor: const Color(0xFF10B981),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.message ?? 'Failed to scan receipt',
            style: GoogleFonts.inter(fontSize: 14),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showVoiceInput() async {
    final expenseBloc = context.read<ExpenseBloc>();
    final categoryBloc = context.read<CategoryBloc>();
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => SimpleVoiceDialog(
        expenseBloc: expenseBloc,
        categoryBloc: categoryBloc,
      ),
    );
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم الإضافة: $result'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    }
  }
}

/// Plus Button مع Animation
class _PlusButtonWithAnimation extends StatefulWidget {
  final VoidCallback onTap;

  const _PlusButtonWithAnimation({required this.onTap});

  @override
  State<_PlusButtonWithAnimation> createState() =>
      _PlusButtonWithAnimationState();
}

class _PlusButtonWithAnimationState extends State<_PlusButtonWithAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  static const Color _navyBlue = Color(0xFF0D5DB8);
  static const Color _navyLight = Color(0xFF1478E0);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    setState(() => _isPressed = false);
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isPressed
                      ? [_navyBlue, _navyLight] // لون مختلف لما متداس
                      : [_navyLight, _navyBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _navyBlue.withValues(alpha: _isPressed ? 0.6 : 0.4),
                    blurRadius: _isPressed ? 16 : 12,
                    offset: Offset(0, _isPressed ? 8 : 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 32,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }
}


