import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

// Core imports
import 'core/theme/app_theme.dart';

// Feature imports
import 'features/home/bloc/expense_bloc.dart';
import 'features/categories/bloc/category_bloc.dart';
import 'features/reminders/bloc/reminder_bloc.dart';
import 'features/profile/bloc/user_bloc.dart';
import 'features/profile/bloc/user_event.dart';

// Widget imports
import 'widgets/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Run app with Sentry in release mode only
  if (const bool.fromEnvironment('dart.vm.product')) {
    await SentryFlutter.init(
      (options) {
        options.dsn = 'YOUR_SENTRY_DSN_HERE';
        options.tracesSampleRate = 1.0;
      },
      appRunner: () => runApp(const SkipAuthApp()),
    );
  } else {
    runApp(const SkipAuthApp());
  }
}

class SkipAuthApp extends StatelessWidget {
  const SkipAuthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ExpenseBloc()),
        BlocProvider(create: (_) => CategoryBloc()),
        BlocProvider(create: (_) => ReminderBloc()),
        BlocProvider(create: (_) => UserBloc()),
      ],
      child: MaterialApp(
        title: 'Smart Finance Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme.copyWith(
          textTheme: GoogleFonts.interTextTheme(
            AppTheme.lightTheme.textTheme,
          ),
        ),
        home: const SkipAuthWrapper(),
      ),
    );
  }
}

class SkipAuthWrapper extends StatelessWidget {
  const SkipAuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Set fake user data for testing
    context.read<UserBloc>().add(const UpdateUserProfile(
      name: 'Test User',
      email: 'test@example.com',
    ));
    
    return const MainLayout(initialIndex: 0);
  }
}