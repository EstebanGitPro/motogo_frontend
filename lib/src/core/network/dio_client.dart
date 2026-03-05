import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:motogo_frontend/src/core/config/config.dart';
import 'package:motogo_frontend/src/core/network/auth_interceptor.dart';

import 'dio_client_stub.dart'
    if (dart.library.html) 'dio_client_web.dart'
    as web_adapter;

/// Centralized Dio HTTP client with authentication interceptor.
///
/// This client should be used for all authenticated API calls.
/// It automatically:
/// - Adds Authorization header to requests (mobile) or sends HttpOnly cookies (web)
/// - Handles 401 errors with token refresh
/// - Retries failed requests after successful refresh
///
/// Usage:
/// ```dart
/// final response = await dioClient.get('/branches');
/// final response = await dioClient.post('/branches', data: {...});
/// ```
class DioClient {
  late final Dio dio;

  DioClient({required AuthInterceptor authInterceptor}) {
    dio = Dio(
      BaseOptions(
        baseUrl: Config.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
        extra: kIsWeb ? {'withCredentials': true} : {},
      ),
    );

    // Configure BrowserHttpClientAdapter for Web cookie support
    if (kIsWeb) {
      web_adapter.configureWebCredentials(dio);
    }

    // Add auth interceptor for token management
    dio.interceptors.add(authInterceptor);
  }

  // ============ CONVENIENCE METHODS ============

  /// Performs a GET request.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.get<T>(path, queryParameters: queryParameters, options: options);
  }

  /// Performs a POST request.
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Performs a PUT request.
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Performs a PATCH request.
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Performs a DELETE request.
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
