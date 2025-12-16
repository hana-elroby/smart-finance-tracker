import 'package:flutter/material.dart';
import '../home/widgets/simple_bottom_nav.dart';
import '../categories/categories_page.dart';
import '../profile/profile_page.dart';

/// Reminders Page - صفحة التذكيرات
class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  int _selectedIndex = 0; // Default to Home since Reminders isn't in nav

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Reminders',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
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
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Payment Reminders',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Track your payment due dates',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // Reminder Cards
            _buildReminderCard(
              'Electricity Bill',
              'Due in 3 days',
              'EGP 250',
              Icons.flash_on,
              const Color(0xFFFF9800),
            ),
            const SizedBox(height: 16),
            _buildReminderCard(
              'Internet Bill',
              'Due in 5 days',
              'EGP 180',
              Icons.wifi,
              const Color(0xFF2196F3),
            ),
            const SizedBox(height: 16),
            _buildReminderCard(
              'Phone Bill',
              'Due in 7 days',
              'EGP 120',
              Icons.phone,
              const Color(0xFF4CAF50),
            ),
            const SizedBox(height: 16),
            _buildReminderCard(
              'Water Bill',
              'Due in 10 days',
              'EGP 80',
              Icons.water_drop,
              const Color(0xFF00BCD4),
            ),
            const SizedBox(height: 16),
            _buildReminderCard(
              'Gas Bill',
              'Due in 12 days',
              'EGP 150',
              Icons.local_gas_station,
              const Color(0xFFE91E63),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SimpleBottomNav(
        selectedIndex: _selectedIndex,
        onItemSelected: _onNavItemTapped,
      ),
    );
  }

  Widget _buildReminderCard(
    String title,
    String dueDate,
    String amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dueDate,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
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
        // Go to Home
        Navigator.pop(context);
        break;
      case 1:
        // Offers - Coming soon
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Offers - Coming soon!'),
            backgroundColor: Color(0xFF1976D2),
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
        // Go to Categories
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const CategoriesPage(),
          ),
        );
        break;
      case 3:
        // Go to Profile
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfilePage(),
          ),
        );
        break;
    }
  }
}