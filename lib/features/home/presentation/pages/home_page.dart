import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.secondary,
      ),
      body: Center(
        child: Text(
          'Welcome to ${AppConstants.appName}!',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
