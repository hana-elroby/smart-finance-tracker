import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/home_header_widget.dart';
import '../widgets/offers_section_widget.dart';
import '../widgets/action_buttons_widget.dart';
import '../widgets/expense_chart_widget.dart';
import '../widgets/add_expense_bottom_sheet.dart';
import '../dialogs/voice_recording_dialog.dart';
import '../dialogs/qr_scanner_bottom_sheet.dart';
import '../bloc/expense_bloc.dart';
import '../../categories/categories_page.dart';
import '../../reminders/reminders_page.dart';
import '../../offers/offers_page.dart';
import '../../../widgets/main_layout.dart';
import '../../../core/constants/app_constants.dart';

/// Refactored Home Page - Clean and modular
/// Uses extracted widgets for better maintainability
class HomePageRefactored extends StatefulWidget {
  const HomePageRefactored({super.key});

  @override
  State<HomePageRefactored> createState() => _HomePageRefactoredState();
}

class _HomePageRefactoredState extends State<HomePageRefactored> {
  String _userName = "Bassant";
  late ExpenseBloc _expenseBloc;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _expenseBloc = context.read<ExpenseBloc>();
    _initDates();
    _loadUserData();
  }

  void _initDates() {
    _fromDate = AppConstants.defaultStartDate;
    _toDate = DateTime.now();
  }

  Future<void> _loadUserData() async {
    // TODO: Load from Firebase Auth
    setState(() {
      _userName = "Bassant";
    });
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
              const SizedBox(height: 24),

              // Header
              HomeHeader(
                userName: _userName,
                onNotificationTap: _onNotificationTap,
              ),

              const SizedBox(height: 24),

              // Offers Section
              OffersSection(
                onShowMore: _navigateToOffers,
                onOfferTap: (_) => _navigateToOffers(),
              ),

              const SizedBox(height: 28),

              // Action Buttons
              ActionButtonsRow(
                actions: [
                  ActionButtonData(
                    icon: Icons.edit_rounded,
                    text: 'Manual',
                    onTap: _showManualEntry,
                  ),
                  ActionButtonData(
                    icon: Icons.notifications_rounded,
                    text: 'Reminders',
                    onTap: _navigateToReminders,
                  ),
                  ActionButtonData(
                    icon: Icons.grid_view_rounded,
                    text: 'Categories',
                    onTap: _navigateToCategories,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Chart Section
              ChartSection(
                fromDate: _fromDate,
                toDate: _toDate,
                onFromDateTap: () => _selectDate(isFromDate: true),
                onToDateTap: () => _selectDate(isFromDate: false),
              ),

              const SizedBox(height: 100), // Space for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  // ============ Navigation Methods ============

  void _onNotificationTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notifications - Coming soon!'),
        backgroundColor: Color(0xFF1687F0),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _navigateToOffers() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OffersPage()),
    );
  }

  void _navigateToReminders() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RemindersPage()),
    );
  }

  void _navigateToCategories() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MainLayout(initialIndex: 2),
      ),
    );
  }

  // ============ Expense Methods ============

  void _showManualEntry() {
    // TODO: Implement manual entry dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Manual entry - Coming soon!'),
        backgroundColor: Color(0xFF1687F0),
      ),
    );
  }

  void _showAddExpenseSheet() {
    AddExpenseBottomSheet.show(
      context: context,
      onVoiceInput: _showVoiceRecording,
      onScanReceipt: _showOCROptions,
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
    OCROptionsBottomSheet.show(
      context: context,
      onTakePhoto: _showQRScanner,
      onPickFromGallery: _pickImageFromGallery,
    );
  }

  void _showQRScanner() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => const QRScannerBottomSheet(),
    );
  }

  void _pickImageFromGallery() {
    // TODO: Implement image picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gallery picker - Coming soon!'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  // ============ Date Picker Methods ============

  Future<void> _selectDate({required bool isFromDate}) async {
    final initialDate = isFromDate
        ? _fromDate ?? DateTime.now()
        : _toDate ?? _fromDate ?? DateTime.now();

    final firstDate = isFromDate
        ? DateTime(1900)
        : (_fromDate ?? DateTime(1900));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2100),
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

    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
          // Reset to date if it's before from date
          if (_toDate != null && _toDate!.isBefore(picked)) {
            _toDate = null;
          }
        } else {
          _toDate = picked;
        }
      });
    }
  }
}
