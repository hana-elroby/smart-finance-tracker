import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MaterialApp(home: SimpleOTPTest()));
}

class SimpleOTPTest extends StatefulWidget {
  @override
  _SimpleOTPTestState createState() => _SimpleOTPTestState();
}

class _SimpleOTPTestState extends State<SimpleOTPTest> {
  String result = 'Ready...';
  bool loading = false;

  Future<void> testOTP() async {
    setState(() {
      loading = true;
      result = 'Testing...';
    });

    try {
      // Test the exact format that might work
      final response = await http.post(
        Uri.parse('https://graduation-project-21p3.onrender.com/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': 'Test User',
          'email': 'rawanmostafa1055@gmail.com',
          'password': 'password123',
          'phone': '+201234567890',
          'countryCode': '+20',
          'country': 'Egypt',
        }),
      );

      setState(() {
        loading = false;
        result = 'Status: ${response.statusCode}\n'
                'Body: ${response.body}';
      });
    } catch (e) {
      setState(() {
        loading = false;
        result = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Simple OTP Test')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: loading ? null : testOTP,
              child: Text('Test OTP'),
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
                child: Text(result),
              ),
            ),
          ],
        ),
      ),
    );
  }
}