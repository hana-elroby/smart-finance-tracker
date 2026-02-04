import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MaterialApp(home: QuickSignupTest()));
}

class QuickSignupTest extends StatefulWidget {
  @override
  _QuickSignupTestState createState() => _QuickSignupTestState();
}

class _QuickSignupTestState extends State<QuickSignupTest> {
  final _emailController = TextEditingController();
  String _result = 'Ready...';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Use a fresh email each time
    _emailController.text = 'test${DateTime.now().millisecondsSinceEpoch}@gmail.com';
  }

  Future<void> testSignup() async {
    setState(() {
      _loading = true;
      _result = 'Testing signup...';
    });

    try {
      final response = await http.post(
        Uri.parse('https://graduation-project-21p3.onrender.com/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': 'Test User',
          'email': _emailController.text,
          'password': 'password123',
        }),
      ).timeout(Duration(seconds: 30));

      setState(() {
        _loading = false;
        _result = 'Status: ${response.statusCode}\n'
                 'Response: ${response.body}';
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _result = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quick Signup Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : testSignup,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.all(16),
              ),
              child: Text(_loading ? 'Testing...' : 'Test Signup'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: SingleChildScrollView(
                  child: Text(_result),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}