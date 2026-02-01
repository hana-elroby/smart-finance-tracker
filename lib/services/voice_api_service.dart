// Voice API Service - خدمة الـ Voice API اللي صحبتك عملتها
// Service for Voice & Text Finance Analyzer API

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';

class VoiceApiService {
  static final VoiceApiService _instance = VoiceApiService._internal();
  factory VoiceApiService() => _instance;
  VoiceApiService._internal();

  // Analyze text using the Voice API
  Future<VoiceApiResult> analyzeText(String text) async {
    try {
      print('🔍 Analyzing text: $text');
      
      final response = await http.post(
        Uri.parse('${ApiConfig.voiceApiBaseUrl}${ApiConfig.voiceAnalyzeText}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'text': text,
        }),
      ).timeout(const Duration(seconds: 30));

      print('📊 Response Status: ${response.statusCode}');
      print('📝 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return VoiceApiResult.success(data);
      } else {
        return VoiceApiResult.error('Failed to analyze text: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Text analysis error: $e');
      return VoiceApiResult.error('Network error: $e');
    }
  }

  // Analyze voice file using the Voice API
  Future<VoiceApiResult> analyzeVoice(File audioFile) async {
    try {
      print('🎤 Analyzing voice file: ${audioFile.path}');
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.voiceApiBaseUrl}${ApiConfig.voiceAnalyzeAudio}'),
      );

      // Add the audio file
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          audioFile.path,
        ),
      );

      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);

      print('📊 Voice Response Status: ${response.statusCode}');
      print('📝 Voice Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return VoiceApiResult.success(data);
      } else {
        return VoiceApiResult.error('Failed to analyze voice: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Voice analysis error: $e');
      return VoiceApiResult.error('Network error: $e');
    }
  }

  // Test the Voice API connection
  Future<bool> testConnection() async {
    try {
      print('🔍 Testing Voice API connection...');
      
      final response = await http.get(
        Uri.parse('${ApiConfig.voiceApiBaseUrl}/'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('📊 Connection Test Status: ${response.statusCode}');
      
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Connection test error: $e');
      return false;
    }
  }
}

// Voice API Result wrapper
class VoiceApiResult {
  final bool isSuccess;
  final dynamic data;
  final String? message;

  VoiceApiResult._({
    required this.isSuccess,
    this.data,
    this.message,
  });

  factory VoiceApiResult.success(dynamic data) {
    return VoiceApiResult._(
      isSuccess: true,
      data: data,
    );
  }

  factory VoiceApiResult.error(String message) {
    return VoiceApiResult._(
      isSuccess: false,
      message: message,
    );
  }

  // Helper methods to extract data
  String? get extractedText => data?['text'];
  double? get amount => data?['amount']?.toDouble();
  String? get category => data?['category'];
  String? get description => data?['description'];
}