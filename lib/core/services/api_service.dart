// API Service - خدمة الـ API
// Handles all HTTP requests to the backend server

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import '../config/api_config.dart';

class ApiService {
  static final ApiService instance = ApiService._internal();
  ApiService._internal();
  factory ApiService() => instance;

  // Auth token storage
  String? _token;

  // Getters
  String? get token => _token;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  // Set token after login
  void setToken(String token) {
    _token = token;
  }

  // Clear token on logout
  void clearToken() {
    _token = null;
  }

  // Headers
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Map<String, String> get _authHeaders => {
        'Authorization': 'Bearer $_token',
      };

  // Generic GET request
  Future<ApiResponse> get(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers)
          .timeout(ApiConfig.connectionTimeout);
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  // Generic POST request
  Future<ApiResponse> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final response = await http.post(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(ApiConfig.connectionTimeout);
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  // Generic DELETE request
  Future<ApiResponse> delete(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final request = http.Request('DELETE', uri);
      request.headers.addAll(_headers);
      if (body != null) {
        request.body = jsonEncode(body);
      }
      final streamedResponse = await request.send().timeout(ApiConfig.connectionTimeout);
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  // Generic PUT request
  Future<ApiResponse> put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final response = await http.put(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(ApiConfig.connectionTimeout);
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  // GET file (for exports)
  Future<FileApiResponse> getFile(String endpoint) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final response = await http.get(uri, headers: _authHeaders)
          .timeout(ApiConfig.receiveTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return FileApiResponse.success(response.bodyBytes);
      } else {
        return FileApiResponse.error('Failed to download file');
      }
    } catch (e) {
      return FileApiResponse.error('Network error: $e');
    }
  }

  // Multipart POST request (for file uploads)
  Future<ApiResponse> postMultipart(
    String endpoint, {
    Map<String, String>? fields,
    Map<String, File>? files,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final request = http.MultipartRequest('POST', uri);

      // Add auth header
      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }

      // Add fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Add files
      if (files != null) {
        for (final entry in files.entries) {
          request.files.add(await http.MultipartFile.fromPath(
            entry.key,
            entry.value.path,
            filename: path.basename(entry.value.path),
          ));
        }
      }

      final streamedResponse = await request.send()
          .timeout(ApiConfig.receiveTimeout);
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  // Handle HTTP response
  ApiResponse _handleResponse(http.Response response) {
    try {
      final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(body);
      } else {
        final message = body['message'] ?? 'Request failed';
        return ApiResponse.error(message, statusCode: response.statusCode, data: body);
      }
    } catch (e) {
      return ApiResponse.error('Failed to parse response: $e');
    }
  }
}

// API Response wrapper
class ApiResponse {
  final bool isSuccess;
  final dynamic data;
  final String? message;
  final int? statusCode;

  ApiResponse._({
    required this.isSuccess,
    this.data,
    this.message,
    this.statusCode,
  });

  factory ApiResponse.success(dynamic data) {
    return ApiResponse._(
      isSuccess: true,
      data: data,
      message: data['message'],
    );
  }

  factory ApiResponse.error(String message, {int? statusCode, dynamic data}) {
    return ApiResponse._(
      isSuccess: false,
      message: message,
      statusCode: statusCode,
      data: data,
    );
  }

  // Helper to get nested data
  T? getData<T>(String key) {
    if (data is Map) {
      return data[key] as T?;
    }
    return null;
  }
}

// File API Response wrapper
class FileApiResponse {
  final bool isSuccess;
  final List<int>? fileBytes;
  final String? message;

  FileApiResponse._({
    required this.isSuccess,
    this.fileBytes,
    this.message,
  });

  factory FileApiResponse.success(List<int> bytes) {
    return FileApiResponse._(isSuccess: true, fileBytes: bytes);
  }

  factory FileApiResponse.error(String message) {
    return FileApiResponse._(isSuccess: false, message: message);
  }
}
