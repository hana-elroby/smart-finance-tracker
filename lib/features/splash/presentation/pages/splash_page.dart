import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/auth_api_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  void _checkAuthAndNavigate() {
    Timer(AppConstants.splashDuration, () async {
      if (mounted) {
        final authService = AuthApiService.instance;
        final isAuthenticated = await authService.isAuthenticated();
        
        if (isAuthenticated) {
          // User is logged in -> go to Home
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        } else {
          // No user -> go to Onboarding
          Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 200,
            height: 200,
            child: Image.asset(
              'assets/images/bluelogosavelet.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}


