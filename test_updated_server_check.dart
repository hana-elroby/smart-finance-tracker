import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MaterialApp(home: TestUpdatedServer()));
}

class TestUpdatedServer extends StatefulWidget {
  @override
  _TestUpdatedServerState createState() => _TestUpdatedServerState();
}

class _TestUpdatedServerState extends State<TestUpdatedServer> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  String _result = 'Ready to test updated server...';
  bool _loading = false;
  bool _showOTP = false;

  @override
  void initState() {
    super.initState();
    // Fresh email for testing
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _emailController.text = 'test$timestamp@gmail.com';
  }

  Future<void> testServerHealth() async {
    setState(() {
      _loading = true;
      _result = 'Checking server health...';
    });

    try {
      final response = await http.get(
        Uri.parse('https://graduation-project-21p3.onrender.com/api'),
      ).timeout(Duration(seconds: 30));

      setState(() {
        _loading = false;
        _result = '✅ Server Health Check:\n'
                 'Status: ${response.statusCode}\n'
                 'Response: ${response.body}\n\n'
                 '${response.body.contains('emailConfigured') ? 
                   "🎉 Server appears to be updated!" : 
                   "⚠️ Server might not be fully updated"}';
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _result = '❌ Server health check failed: $e';
      });
    }
  }

  Future<void> testDirectEmail() async {
    if (_emailController.text.isEmpty) {
      setState(() => _result = '❌ Please enter email');
      return;
    }

    setState(() {
      _loading = true;
      _result = 'Testing direct email endpoint...';
    });

    try {
      final response = await http.post(
        Uri.parse('https://graduation-project-21p3.onrender.com/test-email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': _emailController.text}),
      ).timeout(Duration(seconds: 30));

      setState(() {
        _loading = false;
        if (response.statusCode == 200) {
          _result = '🎉 DIRECT EMAIL TEST SUCCESS!\n'
                   'Status: ${response.statusCode}\n'
                   'Response: ${response.body}\n\n'
                   '📧 Check your email for test message!\n'
                   'Server is definitely updated! ✅';
        } else if (response.statusCode == 404) {
          _result = '⚠️ Direct email endpoint not found (404)\n'
                   'Server might not be fully updated.\n'
                   'Let\'s try signup instead...';
        } else {
          _result = '📧 Direct Email Test:\n'
                   'Status: ${response.statusCode}\n'
                   'Response: ${response.body}';
        }
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _result = '❌ Direct email test failed: $e';
      });
    }
  }

  Future<void> testSignupOTP() async {
    if (_emailController.text.isEmpty) {
      setState(() => _result = '❌ Please enter email');
      return;
    }

    setState(() {
      _loading = true;
      _result = 'Testing signup with OTP...';
    });

    try {
      final response = await http.post(
        Uri.parse('https://graduation-project-21p3.onrender.com/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': 'Test User Updated',
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
                   'Debug OTP: ${data['data']?['debug_otp']}\n'
                   'Email ID: ${data['data']?['messageId']}\n\n'
                   '📧 Check your email for OTP!\n'
                   'Server is working perfectly! ✅';
          _showOTP = true;
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
          _result = '🎉 OTP VERIFICATION SUCCESS!\n'
                   'User: ${data['user']?['name']}\n'
                   'Email: ${data['user']?['email']}\n'
                   'Token: ${data['token']?.substring(0, 20)}...\n\n'
                   '✅ COMPLETE SUCCESS! Server is fully working!';
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
        title: Text('Test Updated Server'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Server Info
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.cloud_done, size: 48, color: Colors.green),
                    SizedBox(height: 8),
                    Text(
                      'Testing Updated Server',
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
              onPressed: _loading ? null : testServerHealth,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.all(16),
              ),
              child: Text('1. Check Server Health'),
            ),
            
            SizedBox(height: 12),
            
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Your Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
                helperText: 'Use your real email to receive OTP',
              ),
            ),
            
            SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: _loading ? null : testDirectEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.all(16),
              ),
              child: Text('2. Test Direct Email'),
            ),
            
            SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: _loading ? null : testSignupOTP,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.all(16),
              ),
              child: Text('3. Test Signup + OTP'),
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
                        onPressed: _loading ? null : verifyOTP,
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
            
            // Result Display
            Card(
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
                    Container(
                      width: double.infinity,
                      constraints: BoxConstraints(minHeight: 200),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        child: Text(_result, style: TextStyle(fontSize: 14)),
                      ),
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