// Real Auth Test - اختبار حقيقي للتسجيل
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> quickAuthTest() async {
  const baseUrl = 'https://graduation-project-21p3.onrender.com';
  
  print('🔐 Testing Real Auth Signup...');
  print('⚠️ This will create a real test user!');
  
  // Generate unique test email
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final testEmail = 'test_user_$timestamp@example.com';
  
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'firstName': 'Test',
        'lastName': 'User',
        'email': testEmail,
        'password': 'test123456',
        'phone': '01234567890',
        'countryCode': '+20',
        'country': 'Egypt',
      }),
    ).timeout(const Duration(seconds: 15));
    
    print('📧 Test Email: $testEmail');
    print('📊 Status Code: ${response.statusCode}');
    print('📝 Response Body: ${response.body}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ SUCCESS: Signup endpoint is working perfectly!');
      print('🎉 Real user was created successfully!');
      
      // Try to parse response
      try {
        final data = jsonDecode(response.body);
        print('📋 Parsed Response: $data');
        
        // Check if OTP is required
        if (data.containsKey('message')) {
          print('💬 Server Message: ${data['message']}');
        }
        
        if (data.containsKey('otp') || (data['message']?.toString().contains('OTP') ?? false)) {
          print('📱 OTP verification may be required');
        }
        
      } catch (e) {
        print('⚠️ Could not parse JSON response: $e');
      }
      
    } else if (response.statusCode == 400) {
      print('⚠️ BAD REQUEST: Check the data format');
      print('   This might mean the endpoint expects different data');
      
    } else if (response.statusCode == 409) {
      print('⚠️ CONFLICT: User might already exist');
      print('   This is actually good - means the endpoint works!');
      
    } else if (response.statusCode == 404) {
      print('❌ NOT FOUND: Auth endpoint doesn\'t exist');
      
    } else if (response.statusCode == 500) {
      print('❌ SERVER ERROR: Backend has internal issues');
      
    } else {
      print('⚠️ UNEXPECTED: Status ${response.statusCode}');
      print('   Response: ${response.body}');
    }
    
  } catch (e) {
    print('❌ CONNECTION ERROR: $e');
    print('   This might mean:');
    print('   - Server is down');
    print('   - Network issues');
    print('   - Wrong URL');
  }
  
  print('\n🎯 Real Auth Test Completed!');
}