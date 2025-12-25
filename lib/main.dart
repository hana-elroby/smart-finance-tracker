import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_colors.dart';
import 'core/services/sync_service.dart';
import 'core/services/auth_api_service.dart';
import 'features/splash/presentation/pages/splash_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/auth/presentation/pages/auth_page.dart';
import 'features/home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (optional - can use custom backend instead)
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint('Firebase initialization skipped: $e');
  }

  // Initialize Auth API Service (load saved token)
  try {
    await AuthApiService().initialize();
  } catch (e) {
    debugPrint('Auth service initialization error: $e');
  }

  // Initialize Sync Service
  try {
    final syncService = SyncService();
    syncService.startListening();
  } catch (e) {
    debugPrint('Sync service initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SaveIt - Smart Finance Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashPage(),
        AppRoutes.onboarding: (context) => const OnboardingPage(),
        AppRoutes.auth: (context) => const AuthPage(),
        AppRoutes.home: (context) => const HomePage(),
      },
    );
  }
}
