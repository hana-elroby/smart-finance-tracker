import 'package:flutter/material.dart';
import 'lib/features/database_test/simple_database_test_page.dart';

void main() {
  runApp(const SimpleDatabaseTestApp());
}

class SimpleDatabaseTestApp extends StatelessWidget {
  const SimpleDatabaseTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Database Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SimpleDatabaseTestPage(),
    );
  }
}