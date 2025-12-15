import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});
  static Future<void> verifyUser( idToken) async {
    final url = Uri.parse('https://10.0.2.2:3000/api/verify-token');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({'someData': 'example'}), 
    );

    if (response.statusCode == 200) {
      print('Backend verification successful!');
    } else {
      print('Backend verification failed: ${response.body}');
    }
  }
}
 