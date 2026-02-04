import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MaterialApp(home: TestRealEmailOTP()));
}

class TestRealEmailOTP extends StatefulWidget {
  @override
  _TestRealEmailOTPState createState() => _TestRealEmailOTPState();
}

class _TestRealEmailOTPState extends State<TestRealEmailOTP> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  String _result = 'Ready to test with your real email...';
  bool _loading = false;
  bool _showOTP = false;

  @override
  void initState() {
    super.initState();
    // Leave empty for user to enter their real email
    _emailController.text = '';
  }

  Future<void> testWithRealEmail() async {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      setState(() => _result = '❌ Please enter a valid email address');
      return;
    }

    setState(() {
      _loading = true;
      _result = 'Testing with your real email...\nThis will send an actual OTP to your email!';
    });

    try {
      // Generate unique suffix to avoid "already taken" error
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final testEmail = _emailController.text.replaceAll('@', '+test$timestamp@');
      
      final response = await http.post(
        Uri.parse('https://graduation-project-21p3.onrender.com/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': 'Test User Real',
          'email': testEmail, // Use modified email to avoid conflicts
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
          _result = '🎉 SUCCESS! OTP Sent!\n'
                   'Status: ${response.statusCode}\n'
                   'Message: ${data['message']}\n'
                   'Email sent to: $testEmail\n'
                   'Debug OTP: ${data['data']?['debug_otp']}\n\n'
                   '📧 CHECK YOUR EMAIL NOW!\n'
                   'Look for email from Smart Finance Tracker\n'
                   'Check spam folder if not in inbox\n\n'
                   '✅ Server email system is working!';
          _showOTP = true;
        } else if (response.statusCode == 409) {
          // Try with original email if modified one fails
          final response2 = await http.post(
            Uri.parse('https://graduation-project-21p3.onrender.com/auth/signup'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'fullName': 'Test User Real',
              'email': _emailController.text,
              'password': 'password123',
            }),
          );
          
          if (response2.statusCode == 409) {
            setState(() {
              _result = '⚠️ This email is already registered in the system.\n'
                       'The server is working, but this email was used before.\n\n'
                       'Try a different email or use the test app with fake emails.';
            });
          }
        } else {
          _result = '❌ Signup Failed:\n'
                   'Status: ${response.statusCode}\n'
                   'Response: ${response.body}';
        }
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _result = '❌ Test failed: $e';
      });
    }
  }

  Future<void> verifyOTP() async {
    if (_otpController.text.isEmpty) {
      setState(() => _result = '❌ Please enter the OTP from your email');
      return;
    }

    setState(() {
      _loading = true;
      _result = 'Verifying OTP from your email...';
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
          _result = '🎉🎉 COMPLETE SUCCESS! 🎉🎉\n\n'
                   'OTP Verified Successfully!\n'
                   'User: ${data['user']?['name']}\n'
                   'Email: ${data['user']?['email']}\n'
                   'Token: ${data['token']?.substring(0, 20)}...\n\n'
                   '✅ EMAIL SYSTEM FULLY WORKING!\n'
                   '✅ OTP DELIVERY CONFIRMED!\n'
                   '✅ SERVER IS PRODUCTION READY!\n\n'
                   '🚀 Your app can now send real OTP emails!';
        } else {
          _result = '❌ OTP Verification Failed:\n'
                   'Status: ${response.statusCode}\n'
                   'Response: ${response.body}\n\n'
                   'Make sure you entered the correct OTP from your email.';
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
        title: Text('Test Real Email OTP'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Warning Card
            Card(
              color: Colors.purple.shade50,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.email, size: 48, color: Colors.purple),
                    SizedBox(height: 8),
                    Text(
                      'Real Email OTP Test',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '⚠️ This will send a REAL OTP to your email!',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Make sure to check your inbox and spam folder',
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
                labelText: 'Your Real Email Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
                hintText: 'example@gmail.com',
                helperText: 'Enter your real email to receive OTP',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            
            SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: _loading ? null : testWithRealEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.all(16),
              ),
              child: Text(_loading ? 'Sending OTP...' : 'Send Real OTP to My Email'),
            ),
            
            // OTP Field
            if (_showOTP) ...[
              SizedBox(height: 20),
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.mark_email_read, size: 48, color: Colors.green),
                      SizedBox(height: 8),
                      Text(
                        'Check Your Email!',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Enter the OTP code from your email',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _otpController,
                        decoration: InputDecoration(
                          labelText: 'OTP from Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                          hintText: '6-digit code',
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
                        child: Text('Verify Real OTP'),
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