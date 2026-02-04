import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const OTPCleanupTestApp());
}

class OTPCleanupTestApp extends StatelessWidget {
  const OTPCleanupTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OTP Test with Cleanup',
      home: const OTPCleanupTestPage(),
    );
  }
}

class OTPCleanupTestPage extends StatefulWidget {
  const OTPCleanupTestPage({super.key});

  @override
  State<OTPCleanupTestPage> createState() => _OTPCleanupTestPageState();
}

class _OTPCleanupTestPageState extends State<OTPCleanupTestPage> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  String _status = 'Ready to test...';
  bool _isLoading = false;
  bool _showOTPField = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = 'test${DateTime.now().millisecondsSinceEpoch}@gmail.com';
  }

  Future<void> _testSignup() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing signup...';
    });

    try {
      // Try different field combinations
      final testCases = [
        {
          'fullName': 'Test User',
          'email': _emailController.text,
          'password': 'password123',
        },
        {
          'name': 'Test User',
          'email': _emailController.text,
          'password': 'password123',
        },
        {
          'firstName': 'Test',
          'lastName': 'User',
          'email': _emailController.text,
          'password': 'password123',
        },
      ];

      for (int i = 0; i < testCases.length; i++) {
        try {
          final response = await http.post(
            Uri.parse('https://graduation-project-21p3.onrender.com/auth/signup'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(testCases[i]),
          ).timeout(const Duration(seconds: 30));

          if (response.statusCode == 200 || response.statusCode == 201) {
            setState(() {
              _isLoading = false;
              _status = '✅ SUCCESS with test case ${i + 1}!\n'
                       'Fields: ${testCases[i].keys.join(', ')}\n'
                       'Response: ${response.body}\n\n'
                       '📧 Check your email for OTP!\n'
                       'If no OTP received, the server email is not configured.';
              _showOTPField = true;
            });
            return;
          } else {
            setState(() {
              _status = 'Test case ${i + 1} failed: ${response.statusCode}\n${response.body}';
            });
          }
        } catch (e) {
          setState(() {
            _status = 'Test case ${i + 1} error: $e';
          });
        }
      }

      setState(() {
        _isLoading = false;
        _status = '❌ All test cases failed. Server might have issues.';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = '❌ Error: $e';
      });
    }
  }

  Future<void> _testOTPVerification() async {
    if (_otpController.text.isEmpty) {
      setState(() {
        _status = '❌ Please enter OTP';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Verifying OTP...';
    });

    try {
      final response = await http.post(
        Uri.parse('https://graduation-project-21p3.onrender.com/auth/signup/configurationOTP'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'otp': _otpController.text}),
      ).timeout(const Duration(seconds: 30));

      setState(() {
        _isLoading = false;
        _status = 'OTP Verification:\n'
                 'Status: ${response.statusCode}\n'
                 'Response: ${response.body}';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = '❌ OTP verification error: $e';
      });
    }
  }

  Future<void> _generateNewEmail() async {
    setState(() {
      _emailController.text = 'test${DateTime.now().millisecondsSinceEpoch}@gmail.com';
      _showOTPField = false;
      _otpController.clear();
      _status = 'New email generated. Ready to test...';
    });
  }

  Future<void> _testManualOTP() async {
    setState(() {
      _showOTPField = true;
      _status = 'Manual OTP mode enabled.\n'
               'If you received OTP via email, enter it below.\n'
               'If not, the server email configuration needs fixing.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Test with Cleanup'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Email Field
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Test Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _testSignup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Test Signup'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _generateNewEmail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('New Email'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Manual OTP Button
            ElevatedButton(
              onPressed: _testManualOTP,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('Enable Manual OTP Entry'),
            ),

            // OTP Field
            if (_showOTPField) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Enter OTP',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _otpController,
                        decoration: const InputDecoration(
                          labelText: 'OTP Code',
                          hintText: '6-digit code',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.security),
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _testOTPVerification,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Verify OTP'),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Status Display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_status),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Instructions
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🔧 Troubleshooting:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. If signup succeeds but no OTP email:\n'
                      '   → Server email configuration issue\n'
                      '   → You need to configure SMTP in your server\n\n'
                      '2. If "email already taken" error:\n'
                      '   → Click "New Email" to generate fresh email\n\n'
                      '3. If you have OTP from previous attempts:\n'
                      '   → Click "Enable Manual OTP Entry"\n'
                      '   → Enter the OTP you received',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}