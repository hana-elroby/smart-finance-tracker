import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
   bool _tokenSent = false; // prevents duplicate calls
   String? _userName;

    @override
  void initState() {
    super.initState();
    _getUserName();
    _getIdToken();    // CALL THE FUNCTION HERE
  }
  

  Future<void> _getUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userName = user.displayName ?? user.email?.split('@')[0] ?? 'User';
      });
    }
  }
  

  Future<void> _getIdToken() async {
    final user = FirebaseAuth.instance.currentUser;

   if (user == null) return;
   

    String? idToken;

    try {
      // ✅ Get ID token AFTER navigation
      idToken = await user.getIdToken(true);
      debugPrint("Firebase ID Token (JWT): $idToken");

      // ✅ Send token to backend ONCE
      if (!_tokenSent && idToken != null) {
        _tokenSent = true;
        await ApiService.verifyUser(idToken);
      }
    } catch (e) {
      debugPrint("Backend verification failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_userName != null ? 'Hi $_userName!' : 'Smart Finance Tracker'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          'Home Page - Coming Soon',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
  
}