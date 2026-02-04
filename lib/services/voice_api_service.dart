// Voice API Service - New Render API Integration
// Service for Voice & Text Finance Analyzer API
// API: https://gradution-project-u39v.onrender.com

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';

/// Voice API Service for financial text analysis
/// Integrates with the new Render-based API for fast and accurate analysis
class VoiceApiService {
  static final VoiceApiService _instance = VoiceApiService._internal();
  factory VoiceApiService() => _instance;
  VoiceApiService._internal();

  // Analyze text using the Voice API (original format)
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
      
      // Try multiple endpoints to find working one
      final endpoints = [
        '${ApiConfig.voiceApiBaseUrl}/',
        '${ApiConfig.voiceApiBaseUrl}/health',
        '${ApiConfig.voiceApiBaseUrl}/api',
      ];
      
      for (String endpoint in endpoints) {
        try {
          final response = await http.get(
            Uri.parse(endpoint),
            headers: {
              'Content-Type': 'application/json',
            },
          ).timeout(const Duration(seconds: 10));

          print('📊 Testing $endpoint: ${response.statusCode}');
          
          if (response.statusCode == 200) {
            print('✅ Voice API available at: $endpoint');
            return true;
          }
        } catch (e) {
          print('❌ Failed $endpoint: $e');
          continue;
        }
      }
      
      print('❌ All voice API endpoints failed');
      return false;
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

  // Helper methods to extract data from new API format
  String? get extractedText => data?['data']?['original_text'];
  double? get amount {
    final transactions = data?['data']?['analysis']?['transactions'];
    if (transactions != null && transactions.isNotEmpty) {
      return (transactions[0]['amount'] as num?)?.toDouble();
    }
    return null;
  }
  String? get category {
    final transactions = data?['data']?['analysis']?['transactions'];
    if (transactions != null && transactions.isNotEmpty) {
      return transactions[0]['category'] as String?;
    }
    return null;
  }
  String? get item {
    final transactions = data?['data']?['analysis']?['transactions'];
    if (transactions != null && transactions.isNotEmpty) {
      return transactions[0]['item'] as String?;
    }
    return null;
  }
  String? get description => item;
}