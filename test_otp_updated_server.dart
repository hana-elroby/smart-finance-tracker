import 'package:flutter/material.dart';
import 'lib/core/services/auth_api_service.dart';

void main() {
  runApp(const OTPTestApp());
}

class OTPTestApp extends StatelessWidget {
  const OTPTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OTP Test - Updated Server',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const OTPTestPage(),
    );
  }
}

class OTPTestPage extends StatefulWidget {
  const OTPTestPage({super.key});

  @override
  State<OTPTestPage> createState() => _OTPTestPageState();
}

class _OTPTestPageState extends State<OTPTestPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _otpController = TextEditingController();
  
  String _status = 'Ready to test OTP...';
  bool _isLoading = false;
  bool _showOTPField = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with test data
    _firstNameController.text = 'Test';
    _lastNameController.text = 'User';
    _emailController.text = 'your-email@gmail.com'; // Replace with your email
    _passwordController.text = 'password123';
  }

  Future<void> _testSignup() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _updateStatus('❌ Please fill in all fields');
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Testing signup with updated server...';
    });

    try {
      final result = await AuthApiService.instance.signup(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      setState(() {
        _isLoading = false;
        if (result.isSuccess) {
          _status = '✅ SUCCESS! ${result.message}\n\n📧 Check your email for OTP!';
          _showOTPField = true;
        } else {
          _status = '⚠️ Signup failed: ${result.message}';
        }
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
      _updateStatus('❌ Please enter the OTP from your email');
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Verifying OTP...';
    });

    try {
      final result = await AuthApiService.instance.confirmOtp(_otpController.text);

      setState(() {
        _isLoading = false;
        if (result.isSuccess) {
          _status = '🎉 SUCCESS! Account verified!\n\n'
                   'User: ${result.user?.displayName ?? 'N/A'}\n'
                   'Email: ${result.user?.email}\n'
                   'Token: ${result.token?.substring(0, 20)}...';
        } else {
          _status = '❌ OTP verification failed: ${result.message}';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = '❌ Error: $e';
      });
    }
  }

  void _updateStatus(String message) {
    setState(() {
      _status = message;
    });
  }

  void _reset() {
    setState(() {
      _status = 'Ready to test OTP...';
      _showOTPField = false;
      _otpController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Test - Updated Server'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reset,
            tooltip: 'Reset',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Server Info
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.cloud_done,
                      size: 48,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Testing Updated Server',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'https://graduation-project-21p3.onrender.com',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Form Fields
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'User Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _firstNameController,
                            decoration: const InputDecoration(
                              labelText: 'First Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _lastNameController,
                            decoration: const InputDecoration(
                              labelText: 'Last Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email (Your Real Email)',
                        hintText: 'Enter your real email to receive OTP',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Signup Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _testSignup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Test Signup & Send OTP'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // OTP Field (shows after successful signup)
            if (_showOTPField) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.mark_email_read,
                        size: 48,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Check Your Email!',
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
                          labelText: 'Enter OTP from Email',
                          hintText: '6-digit code',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.security),
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _testOTPVerification,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Verify OTP'),
                        ),
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _status,
                        style: const TextStyle(fontSize: 14),
                      ),
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
                    const Row(
                      children: [
                        Icon(Icons.info, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Instructions:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Enter your REAL email address\n'
                      '2. Click "Test Signup & Send OTP"\n'
                      '3. Check your email for the OTP code\n'
                      '4. Enter the OTP and click "Verify OTP"\n'
                      '5. Success! Account will be verified',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}