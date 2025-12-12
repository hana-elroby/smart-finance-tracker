import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<void> sendTokenToBackend(String idToken) async {
    final url = Uri.parse('$baseUrl/verifyToken');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: '{}', // optional
    );

    if (response.statusCode == 200) {
      print("Token verified by backend!");
    } else {
      print("Backend verification failed: ${response.statusCode}");
    }
  }
  
}
 