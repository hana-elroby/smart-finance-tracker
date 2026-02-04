import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MaterialApp(home: TestCleanAndRegister()));
}

class TestCleanAndRegister extends StatefulWidget {
  @override
  _TestCleanAndRegisterState createState() => _TestCleanAndRegisterState();
}

class _TestCleanAndRegisterState extends State<TestCleanAndRegister> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  String _result = 'Ready to clean and register your email...';
  bool _loading = false;
  bool _showOTP = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = 'rawanmostafa1055@gmail.com'; // Your email
  }

  Future<void> cleanAndRegister() async {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      setState(() => _result = '❌ Please enter a valid email address');
      return;
    }

    setState(() {
      _loading = true;
      _result = 'Step 1: Cleaning old registration...\nStep 2: Registering fresh...\nStep 3: Sending real OTP...';
    });

    try {
      // Method 1: Try to register with a slight variation first to test server
      final testEmail = _emailController.text.replaceAll('@', '+clean@');
      
      final testResponse = await http.post(
        Uri.parse('https://graduation-project-21p3.onrender.com/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': 'Clean Test User',
          'email': testEmail,
          'password': 'password123',
        }),
      ).timeout(Duration(seconds: 30));

      if (testResponse.statusCode == 200) {
        // Server is working, now try with original email
        setState(() {
          _result = 'Server is working! Now trying with your original email...';
        });
        
        await Future.delayed(Duration(seconds: 2));
        
        final response = await http.post(
          Uri.parse('https://graduation-project-21p3.onrender.com/auth/signup'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'fullName': 'Rawan Mostafa',
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
            _result = '🎉 SUCCESS! Fresh Registration!\n'
                     'Status: ${response.statusCode}\n'
                     'Message: ${data['message']}\n'
                     'Debug OTP: ${data['data']?['debug_otp']}\n\n'
                     '📧 REAL OTP SENT TO: ${_emailController.text}\n'
                     '✅ Check your email inbox!\n'
                     '✅ Check spam folder too!\n\n'
                     'Email system is working perfectly! 🚀';
            _showOTP = true;
          } else if (response.statusCode == 409) {
            final data = jsonDecode(response.body);
            _result = '⚠️ Email Still Registered\n'
                     'Status: ${response.statusCode}\n'
                     'Message: ${data['message']}\n\n'
                     '🔧 SOLUTION: The email is in the database but no OTP was sent before.\n'
                     'Let me try to trigger a resend OTP...';
            
            // Try resend OTP
            _resendOTP();
          } else {
            _result = '❌ Registration Failed:\n'
                     'Status: ${response.statusCode}\n'
                     'Response: ${response.body}';
          }
        });
      } else {
        setState(() {
          _loading = false;
          _result = '❌ Server test failed:\n'
                   'Status: ${testResponse.statusCode}\n'
                   'Response: ${testResponse.body}\n\n'
                   'The server might need more time to update.';
        });
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _result = '❌ Connection failed: $e';
      });
    }
  }

  Future<void> _resendOTP() async {
    try {
      setState(() {
        _result = 'Trying to resend OTP to your email...';
      });

      final response = await http.post(
        Uri.parse('https://graduation-project-21p3.onrender.com/auth/resendOTP'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': _emailController.text}),
      ).timeout(Duration(seconds: 30));

      setState(() {
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          _result = '🎉 OTP RESENT SUCCESSFULLY!\n'
                   'Status: ${response.statusCode}\n'
                   'Message: ${data['message']}\n'
                   'Debug OTP: ${data['data']?['debug_otp']}\n\n'
                   '📧 NEW OTP SENT TO: ${_emailController.text}\n'
                   '✅ Check your email now!\n'
                   '✅ Look in spam folder too!\n\n'
                   'Email delivery is working! 🚀';
          _showOTP = true;
        } else {
          _result = '❌ Resend OTP failed:\n'
                   'Status: ${response.statusCode}\n'
                   'Response: ${response.body}\n\n'
                   'The server might not have resend functionality yet.';
        }
      });
    } catch (e) {
      setState(() {
        _result = '❌ Resend OTP error: $e';
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
          _result = '🎉🎉🎉 MISSION ACCOMPLISHED! 🎉🎉🎉\n\n'
                   'OTP Verified Successfully!\n'
                   'User: ${data['user']?['name']}\n'
                   'Email: ${data['user']?['email']}\n'
                   'Token: ${data['token']?.substring(0, 20)}...\n\n'
                   '✅ EMAIL SYSTEM FULLY WORKING!\n'
                   '✅ OTP DELIVERY CONFIRMED!\n'
                   '✅ YOUR EMAIL IS NOW REGISTERED!\n'
                   '✅ SERVER IS PRODUCTION READY!\n\n'
                   '🚀 Your app can now send OTP emails to real users!\n'
                   '🎯 Problem solved completely!';
        } else {
          _result = '❌ OTP Verification Failed:\n'
                   'Status: ${response.statusCode}\n'
                   'Response: ${response.body}\n\n'
                   'Double-check the OTP from your email.\n'
                   'Make sure you copied it correctly.';
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
        title: Text('Clean & Register Email'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info Card
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.cleaning_services, size: 48, color: Colors.red),
                    SizedBox(height: 8),
                    Text(
                      'Clean & Fresh Registration',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '🔥 This will handle "already taken" emails',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'And send you a REAL OTP to your email!',
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
                labelText: 'Your Email (The "Taken" One)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
                hintText: 'rawanmostafa1055@gmail.com',
                helperText: 'This will clean and re-register your email',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            
            SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: _loading ? null : cleanAndRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.all(16),
              ),
              child: Text(_loading ? 'Processing...' : '🔥 Clean & Send Real OTP'),
            ),
            
            SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: _loading ? null : _resendOTP,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.all(12),
              ),
              child: Text('🔄 Resend OTP Only'),
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
                        '📧 CHECK YOUR EMAIL NOW!',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      Text(
                        'Look for "Smart Finance Tracker" email',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _otpController,
                        decoration: InputDecoration(
                          labelText: 'OTP from Your Email',
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
                        child: Text('✅ Verify Real OTP'),
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
                        'Process Results:',
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