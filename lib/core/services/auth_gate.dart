import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:graduation_project/features/auth/presentation/pages/login_page.dart';
import 'package:graduation_project/features/home/home_page.dart';
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User signed in → Home
        if (snapshot.hasData) {
          return const HomePage();
        }

        // User signed out → Login
        return const LoginPage();
      },
    );
  }
}
