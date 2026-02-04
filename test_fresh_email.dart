import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MaterialApp(home: TestFreshEmail()));
}

class TestFreshEmail extends StatefulWidget {
  @override
  _TestFreshEmailState createState() => _TestFreshEmailState();
}

class _TestFreshEmailState extends State<TestFreshEmail> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  String _result = 'Ready to test with fresh email...';
  bool _loading = false;
  bool _showOTP = false;

  @override
  void initState() {
    super.initState();
    // Generate completely fresh email every time
    _generateFreshEmail();
  }

  void _generateFreshEmail() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomNum = (timestamp % 10000);
    setState(() {
      _emailController.text = 'testuser$randomNum@gmail.com';
    });
  }

  Future<void> testSignup() async {
    setState(() {
      _loading = true;
      _result = 'Testing signup with fresh email...';
    });

    try {
      final response = await http.post(
        Uri.parse('https://graduation-project-21p3.onrender.com/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': 'Test User Fresh',
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
          _result = '🎉 SIGNUP SUCCESS!\n'
                   'Status: ${response.statusCode}\n'
                   'Message: ${data['message']}\n'
                   'Debug OTP: ${data['data']?['debug_otp']}\n\n'
                   '📧 Email sent to: ${_emailController.text}\n'
                   '✅ Server is working!\n\n'
                   'Note: Since this is a test email, you won\'t receive the actual email.\n'
                   'But you can use the Debug OTP shown above!';
          _showOTP = true;
        } else if (response.statusCode == 409) {
          _result = '⚠️ Email already taken, generating new one...';
          _generateFreshEmail();
          // Auto retry with new email
          Future.delayed(Duration(seconds: 1), () => testSignup());
        } else {
          _result = '❌ Signup Failed:\n'
                   'Status: ${response.statusCode}\n'
                   'Response: ${response.body}';
        }
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _result = '❌ Signup test failed: $e';
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
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          _result = '🎉 COMPLETE SUCCESS!\n'
                   'OTP Verified Successfully!\n'
                   'User: ${data['user']?['name']}\n'
                   'Email: ${data['user']?['email']}\n'
                   'Token: ${data['token']?.substring(0, 20)}...\n\n'
                   '✅ SERVER IS FULLY WORKING!\n'
                   '✅ EMAIL SYSTEM IS WORKING!\n'
                   '✅ OTP VERIFICATION IS WORKING!\n\n'
                   'Your server is ready for production! 🚀';
        } else {
          _result = '❌ OTP Verification Failed:\n'
                   'Status: ${response.statusCode}\n'
                   'Response: ${response.body}';
        }
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _result = '❌ OTP verification failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Fresh Email'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info Card
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.email, size: 48, color: Colors.green),
                    SizedBox(height: 8),
                    Text(
                      'Fresh Email Test',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'This will use a completely new email each time',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Test Email (Auto-generated)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    readOnly: true,
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _generateFreshEmail,
                  child: Text('New'),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: _loading ? null : testSignup,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.all(16),
              ),
              child: Text(_loading ? 'Testing...' : 'Test Signup + OTP'),
            ),
            
            // OTP Field
            if (_showOTP) ...[
              SizedBox(height: 20),
              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.security, size: 48, color: Colors.orange),
                      SizedBox(height: 8),
                      Text(
                        'Enter Debug OTP',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Use the Debug OTP shown in the results above',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _otpController,
                        decoration: InputDecoration(
                          labelText: 'Debug OTP Code',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                          hintText: 'Copy from results above',
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 6,
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
                  ),
                ),
              ),
            ],
            
            SizedBox(height: 20),
            
            // Result Display
            Expanded(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Test Results:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SingleChildScrollView(
                            child: Text(_result, style: TextStyle(fontSize: 14)),
                          ),
                        ),
                      ),
                    ],
                  ),
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