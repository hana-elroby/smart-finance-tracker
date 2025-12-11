import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../categories/categories_page.dart';
import '../analysis/analysis_page.dart';
import 'widgets/home_header.dart';
import 'widgets/home_progress_bar.dart';
import 'widgets/home_categories.dart';
import 'widgets/home_spending_chart.dart';
import 'widgets/home_bottom_nav.dart';
import 'dialogs/category_dialog.dart';
import 'dialogs/manual_entry_dialog.dart';
import 'dialogs/voice_recording_dialog.dart';
import 'dialogs/success_dialog.dart';
import 'dialogs/qr_scanner_bottom_sheet.dart';
import 'dialogs/category_analysis_dialog.dart';
import 'bloc/expense_bloc.dart';

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
  int _selectedIndex = 0;
  String userName = "User"; // Default value, will be fetched from Firebase

  @override
  void initState() {
    super.initState();
    _loadUserData();
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(userName: userName),
              const SizedBox(height: 16),
              const HomeProgressBar(),
              const SizedBox(height: 24),
              HomeCategories(onCategoryTap: _showCategoryDialog),
              const SizedBox(height: 24),
              const Expanded(child: HomeSpendingChart()),
              const SizedBox(height: 8),
            ],
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
          // QR Scanner Button - positioned above nav bar
          Positioned(
            bottom: 40,
            left: MediaQuery.of(context).size.width / 2 - 45,
            child: GestureDetector(
              onTap: _showQRScannerOptions,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.qr_code_scanner,
                  color: Colors.black,
                  size: 45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Already on Home
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CategoriesPage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AnalysisPage()),
        );
        break;
      case 3:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile page - Coming soon!'),
            backgroundColor: AppColors.primary,
          ),
        );
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
      builder: (context) => const QRScannerBottomSheet(),
    );
  }

  void _showCategoryAnalysis(
    String category,
    IconData icon,
    LinearGradient gradient,
  ) {
    showDialog(
      context: context,
      builder: (context) => CategoryAnalysisDialog(
        category: category,
        icon: icon,
        gradient: gradient,
      ),
    );
  }
}
