import 'package:flutter/material.dart';
import 'lib/widgets/modern_action_button.dart';

void main() {
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Reminders Button
                    ModernActionButton(
                      icon: Icons.notifications_rounded,
                      text: 'Reminders',
                      onTap: () {
                        debugPrint('Reminders tapped');
                      },
                    ),

                    const SizedBox(width: 16),

                    // Categories Button
                    ModernActionButton(
                      icon: Icons.grid_view_rounded,
                      text: 'Categories',
                      onTap: () {
                        debugPrint('Categories tapped');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
