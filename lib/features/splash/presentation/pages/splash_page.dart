// Splash Page - صفحة البداية
// Shows app logo and navigates based on auth state

import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/auth_api_service.dart';
import '../../../../core/services/local_storage_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _navigateToNextScreen();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
  }

  Future<void> _navigateToNextScreen() async {
    // Wait for splash duration
    await Future.delayed(AppConstants.splashDuration);

    if (!mounted) return;

    // Check if user is logged in (API backend)
    final authService = AuthApiService();
    final storageService = LocalStorageService();

    // Initialize auth service to load saved token
    await authService.initialize();

    // Check if onboarding is complete
    final onboardingComplete = await storageService.isOnboardingComplete();

    if (!mounted) return;

    if (authService.isLoggedIn) {
      // User is logged in, go to home
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else if (onboardingComplete) {
      // Onboarding done but not logged in, go to auth
      Navigator.pushReplacementNamed(context, AppRoutes.auth);
    } else {
      // First time user, go to onboarding
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: Image.asset(
                          'assets/images/bluelogosavelet.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // App Name
                      const Text(
                        'SaveIt',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Tagline
                      Text(
                        'Smart Finance Tracker',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 60),
                      // Loading indicator
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
