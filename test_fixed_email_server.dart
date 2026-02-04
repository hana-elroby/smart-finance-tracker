import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MaterialApp(home: TestFixedEmailServer()));
}

class TestFixedEmailServer extends StatefulWidget {
  @override
  _TestFixedEmailServerState createState() => _TestFixedEmailServerState();
}

class _TestFixedEmailServerState extends State<TestFixedEmailServer> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  String _status = 'Ready to test fixed email server...';
  bool _loading = false;
  bool _showOTPField = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = 'rawanmostafa1055@gmail.com';
  }

  Future<void> _testServerHealth() async {
    setState(() {
      _loading = true;
      _status = 'Testing server health...';
    });

    try {
      final response = await http.get(
        Uri.parse('https://graduation-project-21p3.onrender.com/api'),
      ).timeout(Duration(seconds: 30));

      setState(() {
        _loading = false;
        _status = '✅ Server Health Check:\n'
                 'Status: ${response.statusCode}\n'
                 'Response: ${response.body}';
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _status = '❌ Server health check failed: $e';
      });
    }
  }

  Future<void> _testEmailDirectly() async {
    if (_emailController.text.isEmpty) {
      setState(() => _status = '❌ Please enter email');
      return;
    }

    setState(() {
      _loading = true;
      _status = 'Testing email sending directly...';
    });

    try {
      final response = await http.post(
        Uri.parse('https://graduation-project-21p3.onrender.com/test-email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': _emailController.text}),
      ).timeout(Duration(seconds: 30));

      setState(() {
        _loading = false;
        _status = '📧 Direct Email Test:\n'
                 'Status: ${response.statusCode}\n'
                 'Response: ${response.body}\n\n'
                 '${response.statusCode == 200 ? "✅ Check your email!" : "❌ Email failed"}';
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _status = '❌ Direct email test failed: $e';
      });
    }
  }

  Future<void> _testSignupWithOTP() async {
    if (_emailController.text.isEmpty) {
      setState(() => _status = '❌ Please enter email');
      return;
    }

    setState(() {
      _loading = true;
      _status = 'Testing signup with OTP...';
    });

    try {
      final response = await http.post(
        Uri.parse('https://graduation-project-21p3.onrender.com/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': 'Test User',
          'email': _emailController.text,
          'password': 'password123',
          'phone': '+201234567890',
          'countryCode': '+20',
          'country': 'Egypt',
        }),
      ).timeout(Duration(seconds: 30));

      setState(() {
        _loading = false;
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          _status = '✅ Signup Success!\n'
                   'Message: ${data['message']}\n'
                   'Debug OTP: ${data['data']?['debug_otp']}\n\n'
                   '📧 Check your email for OTP!';
          _showOTPField = true;
        } else {
          _status = '❌ Signup Failed:\n'
                   'Status: ${response.statusCode}\n'
                   'Response: ${response.body}';
        }
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _status = '❌ Signup request failed: $e';
      });
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.isEmpty) {
      setState(() => _status = '❌ Please enter OTP');
      return;
    }

    setState(() {
      _loading = true;
      _status = 'Verifying OTP...';
    });

    try {
      final response = await http.post(
        Uri.parse('https://graduation-project-21p3.onrender.com/auth/signup/configurationOTP'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'otp': _otpController.text}),
      ).timeout(Duration(seconds: 30));

      setState(() {
        _loading = false;
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          _status = '🎉 OTP Verification Success!\n'
                   'User: ${data['user']?['name']}\n'
                   'Email: ${data['user']?['email']}\n'
                   'Token: ${data['token']?.substring(0, 20)}...';
        } else {
          _status = '❌ OTP Verification Failed:\n'
                   'Status: ${response.statusCode}\n'
                   'Response: ${response.body}';
        }
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _status = '❌ OTP verification failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Fixed Email Server'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Server Info
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.cloud_done, size: 48, color: Colors.blue),
                    SizedBox(height: 8),
                    Text(
                      'Fixed Email Server Test',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'https://graduation-project-21p3.onrender.com',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Test Buttons
            ElevatedButton(
              onPressed: _loading ? null : _testServerHealth,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.all(16),
              ),
              child: Text('1. Test Server Health'),
            ),
            
            SizedBox(height: 12),
            
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Your Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            
            SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: _loading ? null : _testEmailDirectly,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.all(16),
              ),
              child: Text('2. Test Email Directly'),
            ),
            
            SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: _loading ? null : _testSignupWithOTP,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.all(16),
              ),
              child: Text('3. Test Signup + OTP'),
            ),
            
            // OTP Field
            if (_showOTPField) ...[
              SizedBox(height: 20),
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.security, size: 48, color: Colors.green),
                      SizedBox(height: 8),
                      Text(
                        'Enter OTP from Email',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _otpController,
                        decoration: InputDecoration(
                          labelText: 'OTP Code',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loading ? null : _verifyOTP,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.all(16),
                        ),
                        child: Text('4. Verify OTP'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            
            SizedBox(height: 20),
            
            // Status Display
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_status, style: TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
              ),
            ),
            
            if (_loading)
              Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}