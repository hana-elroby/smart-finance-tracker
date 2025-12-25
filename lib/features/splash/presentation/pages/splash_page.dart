import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';

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
    Timer(AppConstants.splashDuration, () {
      if (mounted) {
        final user = FirebaseAuth.instance.currentUser;
        
        if (user != null && user.emailVerified) {
          // User is logged in and verified -> go to Home
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        } else {
          // No user or not verified -> go to Onboarding
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


