import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/navigation_helper.dart';
import '../widgets/auth_button.dart';
import 'login_page.dart';
import 'signup_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EAF6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Logo and Title
              Image.asset(
                'assets/images/saveletlogo.png',
                width: 180,
                height: 180,
              ),
              const SizedBox(height: 12),
              const Text(
                'Manage your money smarter',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF5A6C7D),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(flex: 3),
              // Buttons
              AuthButton(
                text: 'Log In',
                onPressed: () {
                  NavigationHelper.push(context, const LoginPage());
                },
                backgroundColor: const Color(0xFF00BCD4),
                textColor: Colors.white,
              ),
              const SizedBox(height: 16),
              AuthButton(
                text: 'Sign Up',
                onPressed: () {
                  NavigationHelper.push(context, const SignUpPage());
                },
                backgroundColor: AppColors.primary,
                textColor: Colors.white,
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
