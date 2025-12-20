import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../reminders/reminders_page.dart';
import '../../../offers/offers_page.dart';
import '../../../../widgets/main_layout.dart';
import '../widgets/widgets.dart';

/// Clean Home Page - Refactored following Clean Architecture
///
/// This page follows these principles:
/// - Single responsibility: Only handles UI orchestration
/// - No business logic - delegated to BLoC
/// - Uses small, reusable widgets
/// - Under 150 lines
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String _userName = 'Bassant';

  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _setDefaultDates();
  }

  void _setDefaultDates() {
    _fromDate = DateTime(2024, 1, 1);
    _toDate = DateTime.now();
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
              const HomeHeader(userName: _userName),
              const SizedBox(height: 24),
              OffersSection(
                onShowMoreTap: _navigateToOffers,
                onOfferTap: _onOfferTap,
              ),
              const SizedBox(height: 28),
              _buildActionButtons(),
              const SizedBox(height: 28),
              ExpenseChartSection(
                fromDate: _fromDate,
                toDate: _toDate,
                onFromDateTap: () => _selectFromDate(context),
                onToDateTap: () => _selectToDate(context),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return ActionButtonsRow(
      buttons: [
        ActionButtonData(
          icon: Icons.edit_rounded,
          text: 'Manual',
          onTap: _onManualTap,
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
    );
  }

  // ============ Navigation Methods ============

  void _navigateToOffers() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OffersPage()),
    );
  }

  void _navigateToReminders() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RemindersPage()),
    );
  }

  void _navigateToCategories() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainLayout(initialIndex: 2)),
    );
  }

  void _onOfferTap(int index) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening offers...'),
        backgroundColor: Color(0xFF1D86D0),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _onManualTap() {
    // TODO: Navigate to manual expense entry
  }

  // ============ Date Selection Methods ============

  Future<void> _selectFromDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) => _datePickerTheme(context, child),
    );

    if (picked != null && picked != _fromDate) {
      setState(() {
        _fromDate = picked;
        if (_toDate != null && _toDate!.isBefore(picked)) {
          _toDate = null;
        }
      });
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? _fromDate ?? DateTime.now(),
      firstDate: _fromDate ?? DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) => _datePickerTheme(context, child),
    );

    if (picked != null && picked != _toDate) {
      setState(() => _toDate = picked);
    }
  }

  Widget _datePickerTheme(BuildContext context, Widget? child) {
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
  }
}
