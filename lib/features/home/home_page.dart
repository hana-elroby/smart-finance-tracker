import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../widgets/modern_action_button.dart';
import '../../widgets/chart_placeholder.dart';

import 'dialogs/voice_recording_dialog.dart';
import 'dialogs/qr_scanner_bottom_sheet.dart';
import 'bloc/expense_bloc.dart';
import 'bloc/expense_state.dart';
import 'package:graduation_project/features/categories/categories_page.dart';
import 'package:graduation_project/features/reminders/reminders_page.dart';
import '../offers/offers_page.dart';
import '../../widgets/main_layout.dart';

/// Professional Home Page - Modern Expense Tracking
/// Features: Header, Navigation Cards, Date Filter, Chart, FAB
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomePageContent();
  }
}

class _HomePageContent extends StatefulWidget {
  const _HomePageContent();

  @override
  State<_HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<_HomePageContent>
    with TickerProviderStateMixin {
  String userName = "Bassant";
  late ExpenseBloc _expenseBloc;
  DateTime? _fromDate;
  DateTime? _toDate;

  // Animation controllers
  late AnimationController _fabAnimationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _fabScaleAnimation;
  late Animation<double> _cardScaleAnimation;

  @override
  void initState() {
    super.initState();
    _expenseBloc = context.read<ExpenseBloc>();
    _initializeAnimations();
    _loadUserData();
    _setDefaultDates();
  }

  void _initializeAnimations() {
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );

    _cardScaleAnimation =
        Tween<double>(
          begin: 1.0,
          end: 0.96, // Precise scale down (0.96-0.97 range)
        ).animate(
          CurvedAnimation(
            parent: _cardAnimationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  void _setDefaultDates() {
    // Set default dates: from = app first use, to = current date
    setState(() {
      _fromDate = DateTime(2024, 1, 1); // Default start date
      _toDate = DateTime.now();
    });
  }

  Future<void> _loadUserData() async {
    // TODO: Replace with Firebase Auth
    setState(() {
      userName = "Bassant ";
    });
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24), // مسافة أكبر من الأعلى
              // Header Section
              _buildHeader(),

              const SizedBox(height: 24), // مسافة بعد الهيدر
              // Offers Section (Noon-style)
              _buildOffersSection(),

              const SizedBox(height: 28), // مسافة بعد العروض
              // Modern Action Buttons
              _buildModernActionButtons(),

              const SizedBox(height: 28), // مسافة قبل الشارت
              // Chart Section with integrated date filters
              _buildChartSection(),

              const SizedBox(height: 100), // Space for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // النص والكوتة
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi $userName',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF003B73),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(width: 2, color: Colors.transparent),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0814F9), Color(0xFFF907A8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFF0814F9), Color(0xFFF907A8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Smart spending leads to bright savings!',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF4B5563),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // الجرس الجميل زي الصورة
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RemindersPage()),
            );
          },
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF0814F9), // أزرق
                  Color(0xFF8B5CF6), // بنفسجي
                  Color(0xFFEC4899), // وردي
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Container(
              margin: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Stack(
                children: [
                  // الجرس البرتقالي/الأصفر
                  Center(
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFFFFE994), // أصفر فاتح
                          Color(0xFFFF8C00), // برتقالي
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ).createShader(bounds),
                      child: const Icon(
                        Icons.notifications,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  // النقطة الحمراء (notification badge)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444), // أحمر
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOffersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Offers',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF003B73),
              ),
            ),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                // Navigate to Offers tab in MainLayout
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MainLayout(initialIndex: 1),
                  ),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Show More',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color(0xFF374151),
                    size: 14,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180, // ارتفاع أطول للإعلانات
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) {
              return _buildNoonStyleOfferCard(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNoonStyleOfferCard(int index) {
    final offers = [
      {
        'title': 'Smart Savings',
        'subtitle': 'Track & Save More',
        'brand': 'FinTrack',
        'brandColor': const Color(0xFF1687F0),
        'imageUrl':
            'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=400&h=200&fit=crop&crop=center',
        'fallbackGradient': [const Color(0xFF1687F0), const Color(0xFF0F446A)],
      },
      {
        'title': 'Budget Goals',
        'subtitle': 'Achieve your targets',
        'brand': 'MoneyWise',
        'brandColor': const Color(0xFF6B7280),
        'imageUrl':
            'https://images.unsplash.com/photo-1566576912321-d58ddd7a6088?w=400&h=200&fit=crop&crop=center',
        'fallbackGradient': [const Color(0xFF6B7280), const Color(0xFF4B5563)],
      },
      {
        'title': 'Expense Tips',
        'subtitle': 'Smart spending habits',
        'brand': 'SaveMore',
        'brandColor': const Color(0xFF10B981),
        'imageUrl':
            'https://images.unsplash.com/photo-1604719312566-878836d2c3b9?w=400&h=200&fit=crop&crop=center',
        'fallbackGradient': [const Color(0xFF10B981), const Color(0xFF059669)],
      },
    ];

    final offer = offers[index];

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opening offers...'),
            backgroundColor: Color(0xFF1D86D0),
            duration: Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        width: 300,
        margin: EdgeInsets.only(right: index < 2 ? 16 : 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Main image background
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: offer['fallbackGradient'] as List<Color>,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Image.network(
                  offer['imageUrl'] as String,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: offer['fallbackGradient'] as List<Color>,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.6),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              // Brand logo
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    offer['brand'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: offer['brandColor'] as Color,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              // Text overlay
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      offer['title'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.1,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    Text(
                      offer['subtitle'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.9),
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernActionButtons() {
    return Row(
      children: [
        // Reminders Button
        Expanded(
          child: ModernActionButton(
            icon: Icons.notifications_rounded,
            text: 'Reminders',
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RemindersPage()),
              );
            },
          ),
        ),

        const SizedBox(width: 8),

        // Categories Button
        Expanded(
          child: ModernActionButton(
            icon: Icons.grid_view_rounded,
            text: 'Categories',
            onTap: () {
              HapticFeedback.lightImpact();
              // Navigate to Categories tab in MainLayout
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainLayout(initialIndex: 2),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCompactActionButton({
    required String title,
    required IconData icon,
    required List<Color> gradientColors,
    required Color shadowColor,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: _cardScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardScaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _cardAnimationController.forward(),
            onTapUp: (_) => _cardAnimationController.reverse(),
            onTapCancel: () => _cardAnimationController.reverse(),
            onTap: onTap,
            child: Container(
              height: 65,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors, // الألوان الأصلية الجميلة
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // أيقونة بيضاء
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: Colors.white, size: 18),
                    ),

                    const SizedBox(width: 10),

                    // النص كامل وبولد وكبير
                    Flexible(
                      child: Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(width: 8),

                    // سهم صغير
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButtonBackgroundHints(String title) {
    if (title == 'Categories') {
      // Subtle grid shapes for Categories
      return Stack(
        children: [
          Positioned(
            right: 12,
            top: 8,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFF1D86D0).withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          Positioned(
            right: 32,
            top: 8,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF1D86D0).withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 8,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFF1D86D0).withValues(alpha: 0.025),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      );
    } else {
      // Subtle wave shapes for Reminders
      return Stack(
        children: [
          Positioned(
            right: 16,
            top: 12,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF1D86D0).withValues(alpha: 0.03),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: 16,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF1D86D0).withValues(alpha: 0.02),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildNavigationCards() {
    return Column(
      children: [
        // Reminders Professional Button
        _buildProfessionalButton(
          title: 'Reminders',
          icon: Icons.notifications_rounded,
          gradientColors: const [
            Color(0xFF42A5F5),
            Color(0xFF1976D2),
          ], // ألوان أزرق فاتح
          shadowColor: const Color(0xFF42A5F5),
          onTap: () {
            HapticFeedback.lightImpact();
            _animateCardTap(() {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RemindersPage()),
              );
            });
          },
        ),

        const SizedBox(height: 16),

        // Categories Professional Button
        _buildProfessionalButton(
          title: 'Categories',
          icon: Icons.grid_view_rounded,
          gradientColors: const [
            Color(0xFF42A5F5),
            Color(0xFF1976D2),
          ], // نفس الألوان للتناسق
          shadowColor: const Color(0xFF42A5F5),
          onTap: () {
            HapticFeedback.lightImpact();
            _animateCardTap(() {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CategoriesPage()),
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildProfessionalButton({
    required String title,
    required IconData icon,
    required List<Color> gradientColors,
    required Color shadowColor,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: _cardScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardScaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _cardAnimationController.forward(),
            onTapUp: (_) => _cardAnimationController.reverse(),
            onTapCancel: () => _cardAnimationController.reverse(),
            onTap: onTap,
            child: Container(
              width: double.infinity,
              height: 80, // ارتفاع أكبر شوية زي الصورة
              decoration: BoxDecoration(
                // ميكس ألوان جميل
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28), // شكل pill زي الصورة
                boxShadow: [
                  BoxShadow(
                    color: shadowColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  // باك جراوند كبير وراء النص - يدل على الوظيفة
                  Positioned(
                    right: -20,
                    top: -10,
                    bottom: -10,
                    child: Icon(
                      icon,
                      color: Colors.white.withValues(
                        alpha: 0.15,
                      ), // أكثر وضوحاً من قبل
                      size: 120, // حجم كبير زي الصورة
                    ),
                  ),

                  // أيقونة صغيرة على الشمال
                  Positioned(
                    left: 24,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: Colors.white, size: 22),
                      ),
                    ),
                  ),

                  // النص في النص - بولد
                  Center(
                    child: Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 22, // حجم كبير وواضح
                        fontWeight: FontWeight.w700, // بولد زي ما طلبت
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),

                  // أنيميشن بسيط لما تكليك
                  AnimatedBuilder(
                    animation: _cardAnimationController,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(
                            alpha: _cardAnimationController.value * 0.1,
                          ),
                          borderRadius: BorderRadius.circular(28),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateRangeFilter() {
    return Row(
      children: [
        Expanded(
          child: _buildDateField(
            label: 'From',
            date: _fromDate,
            onTap: () => _selectFromDate(context),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDateField(
            label: 'To',
            date: _toDate,
            onTap: () => _selectToDate(context),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    final isFrom = label == 'From';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1D86D0).withValues(alpha: 0.08),
              const Color(0xFF0F446A).withValues(alpha: 0.04),
            ],
            begin: isFrom ? Alignment.topLeft : Alignment.topRight,
            end: isFrom ? Alignment.bottomRight : Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF1D86D0).withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1D86D0).withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // أيقونة التاريخ
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1D86D0), Color(0xFF0F446A)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isFrom ? Icons.calendar_today_rounded : Icons.event_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),

            const SizedBox(width: 10),

            // النص
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500, // أخف شوية
                      color: const Color(0xFF1D86D0),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date != null
                        ? '${date.day}/${date.month}/${date.year}'
                        : 'Select',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600, // أخف شوية
                      color: const Color(0xFF003B73),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF1687F0).withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1687F0).withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              color: const Color(0xFF1687F0),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              '$label: ${date != null ? '${date.day}/${date.month}' : 'Select'}',
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

  Widget _buildDateRangeSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // From Date
          Expanded(
            child: GestureDetector(
              onTap: () => _selectFromDate(context),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1976D2).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calendar_today,
                      color: Color(0xFF1976D2),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'From',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _fromDate != null
                            ? '${_fromDate!.day}/${_fromDate!.month}/${_fromDate!.year}'
                            : 'Select Date',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Divider
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade200,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),

          // To Date
          Expanded(
            child: GestureDetector(
              onTap: () => _selectToDate(context),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1976D2).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.event,
                      color: Color(0xFF1976D2),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'To',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _toDate != null
                            ? '${_toDate!.day}/${_toDate!.month}/${_toDate!.year}'
                            : 'Select Date',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDateRangeText() {
    if (_fromDate != null && _toDate != null) {
      final fromMonth = _getMonthName(_fromDate!.month);
      final toMonth = _getMonthName(_toDate!.month);

      if (_fromDate!.year == _toDate!.year) {
        if (_fromDate!.month == _toDate!.month) {
          return '$fromMonth ${_fromDate!.year}';
        }
        return '$fromMonth – $toMonth ${_fromDate!.year}';
      }
      return '$fromMonth ${_fromDate!.year} – $toMonth ${_toDate!.year}';
    }
    return 'Select date range';
  }

  String _getMonthName(int month) {
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
    return months[month - 1];
  }

  void _showDateRangeBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Date Range',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 20),

            // Quick presets
            _buildDatePreset('This month', () => _setThisMonth()),
            _buildDatePreset('Last 30 days', () => _setLast30Days()),
            _buildDatePreset('Last 6 months', () => _setLast6Months()),
            _buildDatePreset('Custom range', () => _showCustomDatePicker()),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePreset(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
          ),
        ),
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF374151),
          ),
        ),
      ),
    );
  }

  void _setThisMonth() {
    final now = DateTime.now();
    setState(() {
      _fromDate = DateTime(now.year, now.month, 1);
      _toDate = now;
    });
  }

  void _setLast30Days() {
    final now = DateTime.now();
    setState(() {
      _fromDate = now.subtract(const Duration(days: 30));
      _toDate = now;
    });
  }

  void _setLast6Months() {
    final now = DateTime.now();
    setState(() {
      _fromDate = DateTime(now.year, now.month - 6, now.day);
      _toDate = now;
    });
  }

  void _showCustomDatePicker() {
    // TODO: Implement custom date range picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Custom date picker - Coming soon!')),
    );
  }

  Widget _buildDynamicChartSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Live indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Expense Trends',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Live',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Chart
          SizedBox(
            height: 200,
            child: CustomPaint(
              size: const Size(double.infinity, 200),
              painter: ModernExpenseChartPainter(
                fromDate: _fromDate,
                toDate: _toDate,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        // Show placeholder when no data exists
        if (state is ExpenseLoaded && state.isEmpty) {
          return const ChartPlaceholder(
            title: 'Your Spending Overview',
            height: 160,
            type: ChartPlaceholderType.line,
          );
        }

        // Show real chart when data exists
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
                color: const Color(0xFF003B73).withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with better title
              Text(
                'Your Spending Overview',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF374151),
                ),
              ),

              const SizedBox(height: 16),

              // Date Range Filter - From left, To right
              Row(
                children: [
                  Expanded(
                    child: _buildSimpleDateField(
                      label: 'From',
                      date: _fromDate,
                      onTap: () => _selectFromDate(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSimpleDateField(
                      label: 'To',
                      date: _toDate,
                      onTap: () => _selectToDate(context),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              SizedBox(
                height: 240,
                child: CustomPaint(
                  size: const Size(double.infinity, 240),
                  painter: ModernExpenseChartPainter(
                    fromDate: _fromDate,
                    toDate: _toDate,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _animateCardTap(VoidCallback onComplete) {
    _cardAnimationController.forward().then((_) {
      _cardAnimationController.reverse();
      onComplete();
    });
  }

  void _showQRScannerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => const QRScannerBottomSheet(),
    );
  }

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now(),
      firstDate: DateTime(1900), // من سنة 1900
      lastDate: DateTime(2100), // لحد سنة 2100
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1976D2),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _fromDate) {
      setState(() {
        _fromDate = picked;
        // If to date is before from date, reset it
        if (_toDate != null && _toDate!.isBefore(picked)) {
          _toDate = null;
        }
      });
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? _fromDate ?? DateTime.now(),
      firstDate: _fromDate ?? DateTime(1900), // من سنة 1900
      lastDate: DateTime(2100), // لحد سنة 2100
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1976D2),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _toDate) {
      setState(() {
        _toDate = picked;
      });
    }
  }

  void _showAddExpenseBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.45,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Column(
          children: [
            // Drag Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 24),

            // Title Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    'Add Expense',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF003B73),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose how you\'d like to add an expense',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B7280),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Action Rows
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Add by Voice (Primary)
                    _buildActionRow(
                      icon: Icons.mic_rounded,
                      title: 'Add by voice',
                      subtitle: 'Speak naturally and we\'ll handle the rest',
                      isPrimary: true,
                      onTap: () {
                        Navigator.pop(context);
                        HapticFeedback.lightImpact();
                        _showVoiceRecording();
                      },
                    ),

                    const SizedBox(height: 16),

                    // Scan Receipt (Secondary)
                    _buildActionRow(
                      icon: Icons.camera_alt_rounded,
                      title: 'Scan receipt',
                      subtitle: 'Automatically detect amount and details',
                      isPrimary: false,
                      onTap: () {
                        Navigator.pop(context);
                        HapticFeedback.lightImpact();
                        _showOCROptions();
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? const LinearGradient(
                  colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: isPrimary ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPrimary ? Colors.transparent : const Color(0xFFE5E7EB),
            width: 1,
          ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: const Color(0xFF42A5F5).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isPrimary
                    ? Colors.white.withValues(alpha: 0.2)
                    : const Color(0xFF6B7280).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isPrimary ? Colors.white : const Color(0xFF6B7280),
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isPrimary ? Colors.white : const Color(0xFF003B73),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: isPrimary
                          ? Colors.white.withValues(alpha: 0.8)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),

            // Arrow Icon
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: isPrimary ? Colors.white : const Color(0xFF6B7280),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showVoiceRecording() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: _expenseBloc,
        child: VoiceRecordingDialog(
          category: 'General',
          icon: Icons.mic_rounded,
          gradient: const LinearGradient(
            colors: [Color(0xFF1E5F9D), Color(0xFF003B73)],
          ),
          onSuccess: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Expense added successfully!'),
                backgroundColor: Color(0xFF4CAF50),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showOCROptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.35,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Column(
          children: [
            // Drag Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 24),

            // Title Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    'Scan Receipt',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF003B73),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose how you\'d like to capture your receipt',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B7280),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // OCR Options
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Take Photo
                    _buildActionRow(
                      icon: Icons.camera_alt_rounded,
                      title: 'Take photo',
                      subtitle: 'Capture receipt with camera',
                      isPrimary: true,
                      onTap: () {
                        Navigator.pop(context);
                        HapticFeedback.lightImpact();
                        _showQRScannerOptions();
                      },
                    ),

                    const SizedBox(height: 16),

                    // Choose from Gallery
                    _buildActionRow(
                      icon: Icons.photo_library_rounded,
                      title: 'Choose from gallery',
                      subtitle: 'Select existing photo from gallery',
                      isPrimary: false,
                      onTap: () {
                        Navigator.pop(context);
                        HapticFeedback.lightImpact();
                        _pickImageFromGallery();
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _pickImageFromGallery() {
    // TODO: Implement image picker from gallery
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gallery picker - Coming soon!'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }
}

class ModernExpenseChartPainter extends CustomPainter {
  final DateTime? fromDate;
  final DateTime? toDate;

  ModernExpenseChartPainter({this.fromDate, this.toDate});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          const Color(0xFF1687F0) // أزرق أساسي زي الصورة
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF1687F0).withValues(alpha: 0.25), // أزرق فاتح
          const Color(0xFF8B5CF6).withValues(alpha: 0.08), // بنفسجي أقل
          const Color(0xFFEC4899).withValues(alpha: 0.04), // وردي أقل جداً
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Generate dynamic mock data based on date range
    final mockData = _generateMockData();
    final points = _calculatePoints(mockData, size);

    // Create smooth curve path
    final path = Path();
    path.moveTo(0, size.height);

    // Add first point
    path.lineTo(points.first.dx, points.first.dy);

    // Create smooth curves between points
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

    // Close path for fill
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
    final pointPaint = Paint()
      ..color = const Color(0xFF1687F0)
      ..style = PaintingStyle.fill;

    final pointBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (final point in points) {
      // Draw white border
      canvas.drawCircle(point, 6, pointBorderPaint);
      // Draw colored center
      canvas.drawCircle(point, 4, pointPaint);
    }

    // Draw grid lines (subtle)
    final gridPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1;

    // Horizontal grid lines
    for (int i = 1; i < 5; i++) {
      final y = (size.height / 5) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw axis labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Y-axis labels (dynamic amounts)
    final yLabels = _generateYAxisLabels(mockData);
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

    // X-axis labels (dynamic based on date range)
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

  // Generate mock expense data based on date range
  List<double> _generateMockData() {
    if (fromDate == null || toDate == null) {
      // Default data if no dates selected
      return [850, 1200, 950, 1400, 800, 1100, 750];
    }

    final daysDiff = toDate!.difference(fromDate!).inDays;
    final dataPoints = (daysDiff / 7).ceil().clamp(3, 12); // 3-12 points

    // Generate realistic expense data
    final List<double> data = [];
    final random = DateTime.now().millisecond; // Simple seed

    for (int i = 0; i < dataPoints; i++) {
      // Base amount with some variation
      final baseAmount = 800 + (random % 600); // 800-1400 range
      final variation = (random * (i + 1)) % 400 - 200; // ±200 variation
      final amount = (baseAmount + variation).clamp(200, 1600).toDouble();
      data.add(amount);
    }

    return data;
  }

  // Calculate chart points from data
  List<Offset> _calculatePoints(List<double> data, Size size) {
    if (data.isEmpty) return [];

    final maxAmount = data.reduce((a, b) => a > b ? a : b);
    final minAmount = data.reduce((a, b) => a < b ? a : b);
    final range = maxAmount - minAmount;

    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final amount = entry.value;

      final x = (size.width / (data.length - 1)) * index;
      final normalizedAmount = range > 0 ? (amount - minAmount) / range : 0.5;
      final y =
          size.height *
          (1 - (normalizedAmount * 0.7 + 0.15)); // Use 70% of height

      return Offset(x, y);
    }).toList();
  }

  // Generate X-axis labels based on date range
  List<String> _generateXAxisLabels() {
    if (fromDate == null || toDate == null) {
      return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];
    }

    final daysDiff = toDate!.difference(fromDate!).inDays;

    if (daysDiff <= 7) {
      // Show days for week view
      return List.generate(7, (i) {
        final date = fromDate!.add(Duration(days: i));
        return '${date.day}';
      });
    } else if (daysDiff <= 31) {
      // Show weeks for month view
      return ['W1', 'W2', 'W3', 'W4'];
    } else {
      // Show months for longer periods
      final months = [
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

  // Generate Y-axis labels based on data range
  List<String> _generateYAxisLabels(List<double> data) {
    if (data.isEmpty) {
      return ['1.6k', '1.2k', '800', '400', '0'];
    }

    final maxAmount = data.reduce((a, b) => a > b ? a : b);
    final minAmount = data.reduce((a, b) => a < b ? a : b);

    // Create nice round numbers for Y-axis
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
  bool shouldRepaint(CustomPainter oldDelegate) {
    if (oldDelegate is! ModernExpenseChartPainter) return true;
    return oldDelegate.fromDate != fromDate || oldDelegate.toDate != toDate;
  }
}

class ExpenseChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1976D2)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF1976D2).withValues(alpha: 0.3),
          const Color(0xFF1976D2).withValues(alpha: 0.1),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Sample data points
    final points = [
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.2, size.height * 0.4),
      Offset(size.width * 0.4, size.height * 0.6),
      Offset(size.width * 0.6, size.height * 0.2),
      Offset(size.width * 0.8, size.height * 0.5),
      Offset(size.width, size.height * 0.3),
    ];

    // Draw filled area
    final path = Path();
    path.moveTo(points.first.dx, size.height);
    for (int i = 0; i < points.length; i++) {
      if (i == 0) {
        path.lineTo(points[i].dx, points[i].dy);
      } else {
        final cp1 = Offset(
          points[i - 1].dx + (points[i].dx - points[i - 1].dx) / 3,
          points[i - 1].dy,
        );
        final cp2 = Offset(
          points[i].dx - (points[i].dx - points[i - 1].dx) / 3,
          points[i].dy,
        );
        path.cubicTo(
          cp1.dx,
          cp1.dy,
          cp2.dx,
          cp2.dy,
          points[i].dx,
          points[i].dy,
        );
      }
    }
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, fillPaint);

    // Draw line
    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final cp1 = Offset(
        points[i - 1].dx + (points[i].dx - points[i - 1].dx) / 3,
        points[i - 1].dy,
      );
      final cp2 = Offset(
        points[i].dx - (points[i].dx - points[i - 1].dx) / 3,
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

    // Draw data points with values
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // final values = ['2', '700', '4', '948', '10', '12']; // Unused variable
    for (int i = 0; i < points.length; i++) {
      // Draw point
      canvas.drawCircle(points[i], 6, Paint()..color = const Color(0xFF1976D2));
      canvas.drawCircle(points[i], 4, Paint()..color = Colors.white);

      // Draw value labels for some points
      if (i == 1 || i == 3) {
        final value = i == 1 ? '700' : '948';
        textPainter.text = TextSpan(
          text: value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        );
        textPainter.layout();

        // Draw background circle for text
        canvas.drawCircle(
          Offset(points[i].dx, points[i].dy - 25),
          20,
          Paint()..color = const Color(0xFF1976D2),
        );

        textPainter.paint(
          canvas,
          Offset(
            points[i].dx - textPainter.width / 2,
            points[i].dy - 25 - textPainter.height / 2,
          ),
        );
      }
    }

    // Draw x-axis labels
    final xLabels = ['2', '4', '6', '8', '10', '12'];
    for (int i = 0; i < xLabels.length; i++) {
      textPainter.text = TextSpan(
        text: xLabels[i],
        style: const TextStyle(color: Colors.grey, fontSize: 12),
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

    // Draw y-axis labels
    final yLabels = ['1,000', '900', '800', '700', '600', '500'];
    for (int i = 0; i < yLabels.length; i++) {
      textPainter.text = TextSpan(
        text: yLabels[i],
        style: const TextStyle(color: Colors.grey, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          -50,
          (size.height / (yLabels.length - 1)) * i - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
