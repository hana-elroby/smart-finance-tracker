import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MaterialApp(home: TestWithoutServerUpdate()));
}

class TestWithoutServerUpdate extends StatefulWidget {
  @override
  _TestWithoutServerUpdateState createState() => _TestWithoutServerUpdateState();
}

class _TestWithoutServerUpdateState extends State<TestWithoutServerUpdate> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  String _result = 'Ready to test...';
  bool _loading = false;
  bool _showOTP = false;

  @override
  void initState() {
    super.initState();
    // Use different email each time to avoid "already taken" error
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _emailController.text = 'test$timestamp@gmail.com';
  }

  Future<void> testSignup() async {
    setState(() {
      _loading = true;
      _result = 'Testing signup with current server...';
    });

    try {
      // Try different field combinations to work with current server
      final tests = [
        // Test 1: fullName
        {
          'fullName': 'Test User',
          'email': _emailController.text,
          'password': 'password123',
        },
        // Test 2: name
        {
          'name': 'Test User',
          'email': _emailController.text,
          'password': 'password123',
        },
        // Test 3: firstName + lastName
        {
          'firstName': 'Test',
          'lastName': 'User',
          'email': _emailController.text,
          'password': 'password123',
        },
      ];

      for (int i = 0; i < tests.length; i++) {
        try {
          final response = await http.post(
            Uri.parse('https://graduation-project-21p3.onrender.com/auth/signup'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(tests[i]),
          ).timeout(Duration(seconds: 30));

          if (response.statusCode == 200 || response.statusCode == 201) {
            setState(() {
              _loading = false;
              _result = '✅ SUCCESS with test ${i + 1}!\n'
                       'Status: ${response.statusCode}\n'
                       'Response: ${response.body}\n\n'
                       '📧 Check your email for OTP!\n'
                       'If no email received, the server needs updating.';
              _showOTP = true;
            });
            return;
          }
        } catch (e) {
          // Continue to next test
        }
      }

      // If all tests failed
      setState(() {
        _loading = false;
        _result = '❌ All signup attempts failed.\n'
                 'The server needs to be updated with the new code.\n\n'
                 'Please update the server on Render with the fixed code.';
      });

    } catch (e) {
      setState(() {
        _loading = false;
        _result = '❌ Network error: $e';
      });
    }
  }

  Future<void> verifyOTP() async {
    if (_otpController.text.isEmpty) {
      setState(() => _result = '❌ Please enter OTP');
      return;
    }

    setState(() {
      _loading = true;
      _result = 'Verifying OTP...';
    });

    try {
      final response = await http.post(
        Uri.parse('https://graduation-project-21p3.onrender.com/auth/signup/configurationOTP'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'otp': _otpController.text}),
      ).timeout(Duration(seconds: 30));

      setState(() {
        _loading = false;
        _result = 'OTP Verification:\n'
                 'Status: ${response.statusCode}\n'
                 'Response: ${response.body}';
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _result = '❌ OTP verification error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Current Server'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.warning, size: 48, color: Colors.orange),
                    SizedBox(height: 8),
                    Text(
                      'Testing Current Server',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'This will test the server as-is without updates',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Test Email (Auto-generated)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            
            SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: _loading ? null : testSignup,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.all(16),
              ),
              child: Text(_loading ? 'Testing...' : 'Test Signup'),
            ),
            
            if (_showOTP) ...[
              SizedBox(height: 20),
              TextField(
                controller: _otpController,
                decoration: InputDecoration(
                  labelText: 'Enter OTP from Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.security),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loading ? null : verifyOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.all(16),
                ),
                child: Text('Verify OTP'),
              ),
            ],
            
            SizedBox(height: 20),
            
            Expanded(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Result:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(_result),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}