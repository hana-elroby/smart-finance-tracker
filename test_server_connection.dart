import 'package:flutter/material.dart';
import 'lib/core/services/auth_api_service.dart';

void main() {
  runApp(const ServerTestApp());
}

class ServerTestApp extends StatelessWidget {
  const ServerTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Server Connection Test',
      home: const ServerTestPage(),
    );
  }
}

class ServerTestPage extends StatefulWidget {
  const ServerTestPage({super.key});

  @override
  State<ServerTestPage> createState() => _ServerTestPageState();
}

class _ServerTestPageState extends State<ServerTestPage> {
  String _status = 'Ready to test...';
  bool _isLoading = false;

  Future<void> _testServerConnection() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing server connection...';
    });

    try {
      // Test signup with fake data to see if server responds
      final result = await AuthApiService.instance.signup(
        firstName: 'Test',
        lastName: 'User',
        email: 'test@example.com',
        password: 'test123',
      );

      setState(() {
        _isLoading = false;
        if (result.isSuccess) {
          _status = '✅ Server is working! Response: ${result.message}';
        } else {
          _status = '⚠️ Server responded with error: ${result.message}';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = '❌ Server connection failed: $e';
      });
    }
  }

  Future<void> _testRealSignup() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing real signup...';
    });

    try {
      // Test with a real email (replace with your email)
      final result = await AuthApiService.instance.signup(
        firstName: 'Hana',
        lastName: 'Ahmed',
        email: 'your-email@gmail.com', // Replace with your real email
        password: 'password123',
      );

      setState(() {
        _isLoading = false;
        if (result.isSuccess) {
          _status = '✅ Signup successful! Check your email for OTP: ${result.message}';
        } else {
          _status = '⚠️ Signup failed: ${result.message}';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = '❌ Signup error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Server Connection Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.cloud,
                      size: 48,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Server Connection Test',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Server: https://graduation-project-21p3.onrender.com',
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
            ElevatedButton(
              onPressed: _isLoading ? null : _testServerConnection,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Test Server Connection'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isLoading ? null : _testRealSignup,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Test Real Signup (Check Email)'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Card(
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
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            _status,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Card(
              color: Colors.orange,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  '💡 Instructions:\n'
                  '1. Test Server Connection first\n'
                  '2. If server works, edit the code to add your real email\n'
                  '3. Test Real Signup to get OTP on your email',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
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