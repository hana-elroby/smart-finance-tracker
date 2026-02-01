import 'package:flutter/material.dart';

class SimpleCategoriesPage extends StatelessWidget {
  const SimpleCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: const Center(child: Text('Categories Page')),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SimpleCategoriesPage(),
  ));
}