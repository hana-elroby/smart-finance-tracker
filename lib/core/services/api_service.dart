import 'dart:io';
import 'package:dio/dio.dart';
import '../config/api_config.dart';

class ApiService {
  late Dio _dio;
  String? _token;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectionTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
      },
    ));
  }

  bool get isAuthenticated => _token != null;

  void setToken(String token) {
    _token = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearToken() {
    _token = null;
    _dio.options.headers.remove('Authorization');
  }

  Future<ApiResponse> get(String path, {Map<String, String>? queryParams}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParams);
      return ApiResponse.success(response.data, response.statusMessage);
    } on DioException catch (e) {
      return ApiResponse.error(e.response?.data?['message'] ?? 'Network error');
    }
  }

  Future<ApiResponse> post(String path, {Map<String, dynamic>? body}) async {
    try {
      final response = await _dio.post(path, data: body);
      return ApiResponse.success(response.data, response.statusMessage);
    } on DioException catch (e) {
      return ApiResponse.error(e.response?.data?['message'] ?? 'Network error');
    }
  }

  Future<ApiResponse> postMultipart(
    String path, {
    Map<String, File>? files,
    Map<String, String>? fields,
  }) async {
    try {
      final formData = FormData();

      // Add files
      if (files != null) {
        for (var entry in files.entries) {
          formData.files.add(MapEntry(
            entry.key,
            await MultipartFile.fromFile(
              entry.value.path,
              filename: entry.value.path.split('/').last,
            ),
          ));
        }
      }

      // Add fields
      if (fields != null) {
        for (var entry in fields.entries) {
          formData.fields.add(MapEntry(entry.key, entry.value));
        }
      }

      final response = await _dio.post(path, data: formData);
      return ApiResponse.success(response.data, response.statusMessage);
    } on DioException catch (e) {
      return ApiResponse.error(e.response?.data?['message'] ?? 'Network error');
    }
  }

  Future<ApiResponse> put(String path, {Map<String, dynamic>? body}) async {
    try {
      final response = await _dio.put(path, data: body);
      return ApiResponse.success(response.data, response.statusMessage);
    } on DioException catch (e) {
      return ApiResponse.error(e.response?.data?['message'] ?? 'Network error');
    }
  }

  Future<ApiResponse> delete(String path, {Map<String, dynamic>? body}) async {
    try {
      final response = await _dio.delete(path, data: body);
      return ApiResponse.success(response.data, response.statusMessage);
    } on DioException catch (e) {
      return ApiResponse.error(e.response?.data?['message'] ?? 'Network error');
    }
  }

  Future<FileApiResponse> getFile(String path, {Map<String, String>? queryParams}) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParams,
        options: Options(responseType: ResponseType.bytes),
      );
      return FileApiResponse.success(response.data, response.statusMessage);
    } on DioException catch (e) {
      return FileApiResponse.error(e.response?.data?['message'] ?? 'Network error');
    }
  }
}

class ApiResponse {
  final bool isSuccess;
  final dynamic data;
  final String? message;

  ApiResponse._(this.isSuccess, this.data, this.message);

  factory ApiResponse.success(dynamic data, String? message) {
    return ApiResponse._(true, data, message);
  }

  factory ApiResponse.error(String message) {
    return ApiResponse._(false, null, message);
  }

  T? getData<T>(String key) {
    if (data is Map<String, dynamic>) {
      return data[key] as T?;
    }
    return null;
  }
}

class FileApiResponse {
  final bool isSuccess;
  final List<int>? fileBytes;
  final String? message;

  FileApiResponse._(this.isSuccess, this.fileBytes, this.message);

  factory FileApiResponse.success(List<int> fileBytes, String? message) {
    return FileApiResponse._(true, fileBytes, message);
  }

  factory FileApiResponse.error(String message) {
    return FileApiResponse._(false, null, message);
  }
}