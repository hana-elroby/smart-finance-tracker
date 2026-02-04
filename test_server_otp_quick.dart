import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const ServerOTPTestApp());
}

class ServerOTPTestApp extends StatelessWidget {
  const ServerOTPTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Server OTP Quick Test',
      home: const ServerOTPTestPage(),
    );
  }
}

class ServerOTPTestPage extends StatefulWidget {
  const ServerOTPTestPage({super.key});

  @override
  State<ServerOTPTestPage> createState() => _ServerOTPTestPageState();
}

class _ServerOTPTestPageState extends State<ServerOTPTestPage> {
  final _emailController = TextEditingController();
  String _status = 'Ready to test server...';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = 'maram.yassin@gmail.com'; // Your email from the screenshot
  }

  Future<void> _testServerHealth() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing server connection...';
    });

    try {
      final response = await http.get(
        Uri.parse('https://graduation-project-21p3.onrender.com/api'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      setState(() {
        _isLoading = false;
        if (response.statusCode == 200) {
          _status = '✅ Server is ALIVE!\nResponse: ${response.body}';
        } else {
          _status = '⚠️ Server responded with status: ${response.statusCode}\nBody: ${response.body}';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = '❌ Server connection failed: $e';
      });
    }
  }

  Future<void> _testSignupOTP() async {
    if (_emailController.text.isEmpty) {
      setState(() {
        _status = '❌ Please enter your email';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Testing different field combinations...';
    });

    // Test 1: Try with 'name' field
    try {
      final response1 = await http.post(
        Uri.parse('https://graduation-project-21p3.onrender.com/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': 'Test User',
          'email': _emailController.text,
          'password': 'password123',
        }),
      ).timeout(const Duration(seconds: 30));

      if (response1.statusCode == 200 || response1.statusCode == 201) {
        setState(() {
          _isLoading = false;
          _status = '✅ SUCCESS with "name" field!\n'
                   'Status: ${response1.statusCode}\n'
                   'Response: ${response1.body}\n\n'
                   '📧 Check your email for OTP!';
        });
        return;
      }
    } catch (e) {
      // Continue to next test
    }

    // Test 2: Try with firstName/lastName
    try {
      final response2 = await http.post(
        Uri.parse('https://graduation-project-21p3.onrender.com/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': 'Test',
          'lastName': 'User',
          'email': _emailController.text,
          'password': 'password123',
        }),
      ).timeout(const Duration(seconds: 30));

      if (response2.statusCode == 200 || response2.statusCode == 201) {
        setState(() {
          _isLoading = false;
          _status = '✅ SUCCESS with firstName/lastName!\n'
                   'Status: ${response2.statusCode}\n'
                   'Response: ${response2.body}\n\n'
                   '📧 Check your email for OTP!';
        });
        return;
      }
    } catch (e) {
      // Continue to next test
    }

    // Test 3: Try with fullName
    try {
      final response3 = await http.post(
        Uri.parse('https://graduation-project-21p3.onrender.com/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': 'Test User',
          'email': _emailController.text,
          'password': 'password123',
        }),
      ).timeout(const Duration(seconds: 30));

      setState(() {
        _isLoading = false;
        _status = 'Test 3 (fullName) - Status: ${response3.statusCode}\n'
                 'Response: ${response3.body}\n\n'
                 '${response3.statusCode == 200 || response3.statusCode == 201 ? 
                   "✅ Check your email for OTP!" : 
                   "❌ Still failed"}';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = '❌ All tests failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Server OTP Quick Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.cloud, size: 48, color: Colors.blue),
                    const SizedBox(height: 8),
                    const Text(
                      'Testing Server',
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
            
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _testServerHealth,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('1. Test Server Health'),
            ),
            
            const SizedBox(height: 16),
            
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Your Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _testSignupOTP,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('2. Test Signup & OTP'),
            ),
            
            const SizedBox(height: 20),
            
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