import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TokenBackendPage extends StatefulWidget {
  @override
  _TokenBackendPageState createState() => _TokenBackendPageState();
}

class _TokenBackendPageState extends State<TokenBackendPage> {
  String? _idToken;
  String _backendResponse = "";

  Future<void> _sendTokenToBackend() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Get the actual ID token (force refresh to ensure it's valid)
      final String token = (await user.getIdToken(true))!;

      setState(() {
        _idToken = token;
      });

      print("Firebase ID Token: $token"); // full token string

      // Send token to backend
      final url = Uri.parse("http://10.0.2.2:60550/api/verify-token"); // replace with your backend
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // send token in Authorization header
        },
        body: jsonEncode({'someData': 'example'}), // optional payload
      );

      if (response.statusCode == 200) {
        setState(() {
          _backendResponse = "Token verified successfully!";
        });
      } else {
        setState(() {
          _backendResponse = "Backend verification failed: ${response.statusCode}";
        });
      }
    } else {
      print("No user is signed in.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Firebase ID Token + Backend")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _sendTokenToBackend,
              child: Text("Get ID Token and Verify"),
            ),
            SizedBox(height: 20),
            SelectableText("Firebase ID Token:\n${_idToken ?? "Not available"}"),
            SizedBox(height: 20),
            Text("Backend response: $_backendResponse"),
          ],
        ),
      ),
    );
  }
}


