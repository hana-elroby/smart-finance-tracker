import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const VoiceServerTestApp());
}

class VoiceServerTestApp extends StatelessWidget {
  const VoiceServerTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Server Test',
      home: const VoiceServerTestPage(),
    );
  }
}

class VoiceServerTestPage extends StatefulWidget {
  const VoiceServerTestPage({super.key});

  @override
  State<VoiceServerTestPage> createState() => _VoiceServerTestPageState();
}

class _VoiceServerTestPageState extends State<VoiceServerTestPage> {
  final _textController = TextEditingController();
  String _result = 'Ready to test voice server...';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _textController.text = 'دفعت 50 جنيه في كارفور على خضار';
  }

  Future<void> _testTextAnalysis() async {
    if (_textController.text.trim().isEmpty) {
      setState(() => _result = '❌ Please enter text to analyze');
      return;
    }

    setState(() {
      _isLoading = true;
      _result = 'Testing text analysis...';
    });

    try {
      // Test POST to /analyze endpoint
      final response = await http.post(
        Uri.parse('https://gradution-project-u39v.onrender.com/analyze'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'text': _textController.text.trim(),
        }),
      ).timeout(const Duration(seconds: 30));

      setState(() {
        _isLoading = false;
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          _result = '✅ SUCCESS!\n'
                   'Status: ${response.statusCode}\n'
                   'Response: ${jsonEncode(data)}\n\n'
                   'Parsed Data:\n'
                   '${_parseResponse(data)}';
        } else {
          _result = '❌ FAILED\n'
                   'Status: ${response.statusCode}\n'
                   'Response: ${response.body}';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _result = '❌ Error: $e';
      });
    }
  }

  String _parseResponse(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        final amount = data['amount'] ?? data['price'] ?? data['cost'] ?? 'Not found';
        final category = data['category'] ?? data['type'] ?? 'Not found';
        final description = data['description'] ?? data['item'] ?? data['note'] ?? 'Not found';
        
        return 'Amount: $amount\n'
               'Category: $category\n'
               'Description: $description';
      }
      return 'Raw data: $data';
    } catch (e) {
      return 'Parse error: $e';
    }
  }

  Future<void> _testServerHealth() async {
    setState(() {
      _isLoading = true;
      _result = 'Testing server health...';
    });

    try {
      final response = await http.get(
        Uri.parse('https://gradution-project-u39v.onrender.com/'),
        headers: {'Accept': 'text/html,application/json'},
      ).timeout(const Duration(seconds: 15));

      setState(() {
        _isLoading = false;
        _result = '✅ Server is ALIVE!\n'
                 'Status: ${response.statusCode}\n'
                 'Content-Type: ${response.headers['content-type']}\n'
                 'Response Length: ${response.body.length} chars\n\n'
                 'Server Response:\n${response.body.substring(0, 200)}...';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _result = '❌ Server health check failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Server Test'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.purple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.cloud, size: 48, color: Colors.purple),
                    const SizedBox(height: 8),
                    const Text(
                      'Voice Server Test',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'https://gradution-project-u39v.onrender.com',
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
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Text to Analyze',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.text_fields),
                helperText: 'Enter Arabic or English expense text',
              ),
              maxLines: 2,
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _testTextAnalysis,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('2. Test Text Analysis'),
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
                        'Test Results:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SingleChildScrollView(
                            child: Text(_result, style: const TextStyle(fontSize: 14)),
                          ),
                        ),
                      ),
                    ],
                  ),
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