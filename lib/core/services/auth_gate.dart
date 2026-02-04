import 'package:flutter/material.dart';
import 'auth_api_service.dart';
import '../../features/auth/presentation/pages/auth_page.dart';
import '../../widgets/main_layout.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: AuthApiService.instance.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Check if user is logged in
        if (AuthApiService.instance.isLoggedIn) {
          return const MainLayout();
        }

        // User not logged in → Auth
        return const AuthPage();
      },
    );
  }
}