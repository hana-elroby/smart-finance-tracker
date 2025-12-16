import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';

import '../profile/profile_page.dart';

import 'widgets/home_bottom_nav.dart';
import 'dialogs/category_dialog.dart';
import 'dialogs/manual_entry_dialog.dart';
import 'dialogs/voice_recording_dialog.dart';
import 'dialogs/success_dialog.dart';
import 'dialogs/qr_scanner_bottom_sheet.dart';
import 'dialogs/category_analysis_dialog.dart';
import 'bloc/expense_bloc.dart';
import 'package:graduation_project/features/categories/categories_page.dart';
import 'package:graduation_project/features/reminders/reminders_page.dart';

/// Home Page - الصفحة الرئيسية
/// تحتوي على: Header, Progress Bar, Categories, Spending Chart
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExpenseBloc(),
      child: const _HomePageContent(),
    );
  }
}

class _HomePageContent extends StatefulWidget {
  const _HomePageContent();

  @override
  State<_HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<_HomePageContent> {
  int _selectedIndex = 0; // Home page is index 0
  String userName = "User"; // Default value, will be fetched from Firebase
  late ExpenseBloc _expenseBloc;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _expenseBloc = context.read<ExpenseBloc>();
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure home is always selected when on this page
    if (_selectedIndex != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedIndex = 0;
          });
        }
      });
    }
  }

  // TODO: Fetch user data from Firebase
  Future<void> _loadUserData() async {
    // TODO: Replace with Firebase Auth
    // final user = FirebaseAuth.instance.currentUser;
    // if (user != null) {
    //   final userDoc = await FirebaseFirestore.instance
    //       .collection('users')
    //       .doc(user.uid)
    //       .get();
    //   setState(() {
    //     userName = userDoc.data()?['name'] ?? 'User';
    //   });
    // }

    // For now, using dummy data
    setState(() {
      userName =
          "Bassant"; // This will be replaced with actual user name from Firebase
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
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
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('👋', style: TextStyle(fontSize: 24)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Welcome Back',
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ],
                    ),
                    // Notification Icon
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0814F9), Color(0xFFF907A8)],
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
                ),
                
                const SizedBox(height: 24),
                
                // Progress Text
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0814F9), Color(0xFFF509D6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.check, 
                          color: Colors.white, 
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '30% Of Your Expenses, Looks Good.',
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Reminders Button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RemindersPage(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1D86D0), Color(0xFF0F446A)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.none,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Background transparent icon (can overflow)
                        Positioned(
                          right: -10,
                          top: -30,
                          child: Icon(
                            Icons.notifications_outlined,
                            color: Colors.white.withOpacity(0.15),
                            size: 100,
                          ),
                        ),
                        // Main content
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.notifications_outlined, 
                                color: Colors.white, 
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Reminders',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Track Payment due dates',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Categories Button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CategoriesPage()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1D86D0), Color(0xFF0F446A)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.none,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Background transparent grid (can overflow)
                        Positioned(
                          right: -5,
                          top: -10,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 25,
                                    height: 25,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    width: 25,
                                    height: 25,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Container(
                                    width: 25,
                                    height: 25,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    width: 25,
                                    height: 25,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Main content
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.grid_view, 
                                color: Colors.white, 
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Categories',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Track your money, category by category',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Date Range Selector
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectFromDate(context),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'From',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    _fromDate != null 
                                        ? '${_fromDate!.day}/${_fromDate!.month}/${_fromDate!.year}'
                                        : 'Select Date',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectToDate(context),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'To',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    _toDate != null 
                                        ? '${_toDate!.day}/${_toDate!.month}/${_toDate!.year}'
                                        : 'Select Date',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Chart Container
                Container(
                  height: 300,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Chart area with sample data
                      Expanded(
                        child: CustomPaint(
                          size: const Size(double.infinity, 200),
                          painter: ExpenseChartPainter(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        children: [
          HomeBottomNav(
            selectedIndex: _selectedIndex,
            onItemSelected: _onNavItemTapped,
          ),

          // Center Button - positioned above nav bar
          Positioned(
            bottom: 30,
            left: MediaQuery.of(context).size.width / 2 - 45,
            child: GestureDetector(
              onTap: _showAddExpenseOptions,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1D86D0), Color(0xFF0F446A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Container(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onNavItemTapped(int index) {
    // Always update selection immediately for visual feedback
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Already on Home - selection already updated above
        break;
      case 1:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Offers - Coming soon!'),
            backgroundColor: AppColors.primary,
          ),
        );
        // Reset selection back to home after showing snackbar
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() {
              _selectedIndex = 0;
            });
          }
        });
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CategoriesPage(),
          ),
        ).then((_) {
          // Reset to home selection when returning
          if (mounted) {
            setState(() {
              _selectedIndex = 0;
            });
          }
        });
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider.value(
              value: _expenseBloc,
              child: const ProfilePage(),
            ),
          ),
        ).then((_) {
          // Reset to home selection when returning
          if (mounted) {
            setState(() {
              _selectedIndex = 0;
            });
          }
        });
        break;
    }
  }

  void _showCategoryDialog(
    String category,
    IconData icon,
    LinearGradient gradient,
  ) {
    showDialog(
      context: context,
      builder: (context) => CategoryDialog(
        category: category,
        icon: icon,
        gradient: gradient,
        onManualEntry: () => _showManualEntry(category, icon, gradient),
        onVoiceRecording: () => _showVoiceRecording(category, icon, gradient),
        onViewAnalysis: () => _showCategoryAnalysis(category, icon, gradient),
      ),
    );
  }

  void _showManualEntry(
    String category,
    IconData icon,
    LinearGradient gradient,
  ) {
    final expenseBloc = context.read<ExpenseBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: expenseBloc,
        child: ManualEntryDialog(
          category: category,
          icon: icon,
          gradient: gradient,
          onSuccess: _showSuccessMessage,
        ),
      ),
    );
  }

  void _showVoiceRecording(
    String category,
    IconData icon,
    LinearGradient gradient,
  ) {
    final expenseBloc = context.read<ExpenseBloc>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: expenseBloc,
        child: VoiceRecordingDialog(
          category: category,
          icon: icon,
          gradient: gradient,
          onSuccess: _showSuccessMessage,
        ),
      ),
    );
  }

  void _showSuccessMessage() {
    showDialog(context: context, builder: (context) => const SuccessDialog());
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

  void _showAddExpenseOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Add Expense',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Voice Recording - Coming soon!'),
                          backgroundColor: Color(0xFF1976D2),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1D86D0), Color(0xFF0F446A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1976D2).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.mic, color: Colors.white, size: 36),
                          SizedBox(height: 12),
                          Text(
                            'Voice',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _showQRScannerOptions();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1D86D0), Color(0xFF0F446A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1976D2).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.camera_alt, color: Colors.white, size: 36),
                          SizedBox(height: 12),
                          Text(
                            'OCR',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showCategoryAnalysis(
    String category,
    IconData icon,
    LinearGradient gradient,
  ) {
    final expenseBloc = context.read<ExpenseBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: expenseBloc,
        child: CategoryAnalysisDialog(
          category: category,
          icon: icon,
          gradient: gradient,
        ),
      ),
    );
  }

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
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
      firstDate: _fromDate ?? DateTime(2020),
      lastDate: DateTime.now(),
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
          const Color(0xFF1976D2).withOpacity(0.3),
          const Color(0xFF1976D2).withOpacity(0.1),
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
        path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i].dx, points[i].dy);
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
      linePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, paint);

    // Draw data points with values
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final values = ['2', '700', '4', '948', '10', '12'];
    for (int i = 0; i < points.length; i++) {
      // Draw point
      canvas.drawCircle(
        points[i],
        6,
        Paint()..color = const Color(0xFF1976D2),
      );
      canvas.drawCircle(
        points[i],
        4,
        Paint()..color = Colors.white,
      );

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
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
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

    // Draw y-axis labels
    final yLabels = ['1,000', '900', '800', '700', '600', '500'];
    for (int i = 0; i < yLabels.length; i++) {
      textPainter.text = TextSpan(
        text: yLabels[i],
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 10,
        ),
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