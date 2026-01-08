import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:meatwaala_app/core/network/network_constents.dart';
import 'package:meatwaala_app/core/state/app_state.dart';
import 'package:meatwaala_app/core/widgets/api_failure_screen.dart';

/// Standardized API Response wrapper
class ApiResult<T> {
  final bool success;
  final int status;
  final String message;
  final T? data;
  final dynamic raw;

  ApiResult({
    required this.success,
    required this.status,
    required this.message,
    this.data,
    this.raw,
  });

  factory ApiResult.success(T data,
      {String message = 'Success', int status = 1, dynamic raw}) {
    return ApiResult(
      success: true,
      status: status,
      message: message,
      data: data,
      raw: raw,
    );
  }

  factory ApiResult.error(String message, {int status = 0, dynamic raw}) {
    return ApiResult(
      success: false,
      status: status,
      message: message,
      raw: raw,
    );
  }
}

/// Base API Service with centralized error handling and response parsing
class BaseApiService {
  static const String _logTag = '🌐 API';
  static const int _timeoutSeconds = 30;
  static const int _maxRetries = 3;

  final String baseUrl;

  BaseApiService({this.baseUrl = NetworkConstantsUtil.baseUrl});

  /// Check internet connectivity before making requests
  Future<bool> _isConnected() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  /// Build headers for API requests
  Map<String, String> _buildHeaders({
    Map<String, String>? additionalHeaders,
  }) {
    print("Building headers for API request✅✅✅");
    final headers = <String, String>{};

    final token = NetworkConstantsUtil.bearerToken;
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  /// GET Request
  Future<ApiResult<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    T Function(dynamic)? parser,
  }) async {
    return _executeWithRetry(() async {
      var uri = Uri.parse('$baseUrl$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      log('$_logTag GET: $uri');

      final response = await http
          .get(uri, headers: _buildHeaders())
          .timeout(const Duration(seconds: _timeoutSeconds));

      return _handleResponse(response, parser);
    });
  }

  /// POST Request (JSON body)
  Future<ApiResult<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? parser,
  }) async {
    return _executeWithRetry(() async {
      final uri = Uri.parse('$baseUrl$endpoint');

      log('$_logTag POST: $uri');
      log('$_logTag Body: $body');

      final response = await http
          .post(
            uri,
            // Only Authorization token is sent in headers.
            // Content-Type is intentionally NOT added here
            // (useful when backend handles it automatically or for multipart/form-data APIs)
            headers: _buildHeaders(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: _timeoutSeconds));

      return _handleResponse(response, parser);
    });
  }

  /// POST Request (Form URL Encoded - No JSON)
  /// Used for cart operations and review submissions
  /// Sends form-urlencoded data with Authorization token (NOT JSON)
  Future<ApiResult<T>> postWithTokenOnly<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? parser,
  }) async {
    return _executeWithRetry(() async {
      final uri = Uri.parse('$baseUrl$endpoint');

      log('$_logTag POST (Token Only): $uri');
      log('$_logTag Body: $body');

      // Convert request body to Map<String, String>
      // This allows the http package to automatically decide
      // the appropriate encoding without forcing a Content-Type
      Map<String, String>? formFields;
      if (body != null) {
        formFields = body.map(
          (key, value) => MapEntry(key, value.toString()),
        );
      }

      // Send request with:
      // - ONLY Authorization token (from _buildHeaders)
      // - NO Content-Type header
      //
      // This is intentional for APIs that:
      // - Reject explicit Content-Type headers
      // - Infer content type on the server side
      // - Expect raw or flexible request formats
      final response = await http
          .post(
            uri,
            headers: _buildHeaders(), // token-only headers
            body: formFields,
          )
          .timeout(const Duration(seconds: _timeoutSeconds));

      return _handleResponse(response, parser);
    });
  }

  /// POST Request (Form Data - URL Encoded)
  Future<ApiResult<T>> postFormData<T>(
    String endpoint, {
    required Map<String, String> fields,
    T Function(dynamic)? parser,
  }) async {
    return _executeWithRetry(() async {
      final uri = Uri.parse('$baseUrl$endpoint');

      log('$_logTag POST Form Data: $uri');
      log('$_logTag Fields: $fields');

      final response = await http
          .post(
            uri,
            headers: _buildHeaders(additionalHeaders: {
              // 'Content-Type': 'application/x-www-form-urlencoded'
            }),
            body: fields,
          )
          .timeout(const Duration(seconds: _timeoutSeconds));

      return _handleResponse(response, parser);
    });
  }

  /// POST Multipart Request (for form data with files)
  Future<ApiResult<T>> postMultipart<T>(
    String endpoint, {
    required Map<String, String> fields,
    Map<String, File>? files,
    T Function(dynamic)? parser,
  }) async {
    return _executeWithRetry(() async {
      final uri = Uri.parse('$baseUrl$endpoint');
      final request = http.MultipartRequest('POST', uri);

      // Add headers (without Content-Type, MultipartRequest sets it automatically)
      final headers = _buildHeaders();
      headers.remove('Content-Type');
      request.headers.addAll(headers);

      // Add fields
      request.fields.addAll(fields);

      // Add files if any
      if (files != null) {
        for (var entry in files.entries) {
          final file = entry.value;
          if (await file.exists()) {
            request.files.add(await http.MultipartFile.fromPath(
              entry.key,
              file.path,
            ));
          }
        }
      }

      log('$_logTag POST Multipart: $uri');
      log('$_logTag Fields: ${request.fields}');

      final streamedResponse = await request.send().timeout(
            const Duration(seconds: _timeoutSeconds),
          );
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response, parser);
    });
  }

  /// Handle API response and parse it
  ApiResult<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? parser,
  ) {
    final statusCode = response.statusCode;
    final emoji = statusCode >= 200 && statusCode < 300 ? '✅' : '❌';
    log('$_logTag $emoji Response [$statusCode]: ${response.body}');

    try {
      if (response.body.isEmpty) {
        return ApiResult.error(
          'Empty response from server',
          status: statusCode,
        );
      }

      final dynamic decoded = jsonDecode(response.body);

      // ✅ HANDLE RAW & WRAPPED RESPONSES
      final bool hasStatus =
          decoded is Map<String, dynamic> && decoded.containsKey('status');

      final int apiStatus = hasStatus ? decoded['status'] : 1;
      final String message =
          hasStatus ? (decoded['message'] ?? decoded['msg'] ?? '') : '';

      if (apiStatus == 1) {
        // If response has 'data' field, use it; otherwise use full decoded response
        final dynamic rawData = hasStatus
            ? (decoded.containsKey('data') ? decoded['data'] : decoded)
            : decoded;

        final parsedData = parser != null ? parser(rawData) : rawData as T;

        return ApiResult.success(
          parsedData,
          message: message,
          status: apiStatus,
          raw: decoded,
        );
      } else {
        return ApiResult.error(
          message.isNotEmpty ? message : 'Request failed',
          status: apiStatus,
          raw: decoded,
        );
      }
    } catch (e) {
      log('$_logTag ❌ JSON parsing error: $e');
      return ApiResult.error('Failed to parse response');
    }
  }

  /// Centralized error handler - navigates to ApiFailureScreen on critical errors
  static void _handleCriticalError(String message,
      {String errorType = 'error'}) {
    // Use global AppState to prevent duplicate error handling
    final isFirstError = AppState.instance.setCriticalError();

    if (!isFirstError) {
      log('$_logTag ⚠️ Critical error already handled, skipping duplicate');
      return;
    }

    log('$_logTag 🚨 Critical Error: $message (Type: $errorType)');

    // Use GetX navigation - safe without context
    Get.to(
      () => ApiFailureScreen(
        message: message,
        errorType: errorType,
      ),
      preventDuplicates: true,
    );
  }

  /// Global key for showing snackbar (must be set in your app)
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// Execute request with retry logic and centralized error handling
  Future<ApiResult<T>> _executeWithRetry<T>(
    Future<ApiResult<T>> Function() request,
  ) async {
    // CRITICAL: Stop all API calls if critical error already occurred
    if (AppState.instance.hasCriticalError) {
      log('$_logTag ⛔ Critical error state - preventing API call');
      return ApiResult.error(
        'App is in error state. Please retry.',
        status: -1,
      );
    }

    // Check connectivity before making request
    final isConnected = await _isConnected();
    if (!isConnected) {
      const errorMsg =
          'No internet connection. Please check your network and try again.';
      _handleCriticalError(errorMsg, errorType: 'offline');
      return ApiResult.error(errorMsg, status: -1);
    }

    int attempts = 0;

    while (attempts < _maxRetries) {
      try {
        attempts++;
        final result = await request();

        // Handle API-level failures (status != 1)
        if (!result.success && attempts >= _maxRetries) {
          _handleCriticalError(
            result.message.isNotEmpty
                ? result.message
                : 'Request failed. Please try again.',
            errorType: 'server',
          );
        }

        return result;
      } on SocketException {
        if (attempts >= _maxRetries) {
          const errorMsg = 'No internet connection. Please check your network.';
          _handleCriticalError(errorMsg, errorType: 'offline');
          return ApiResult.error(errorMsg, status: -1);
        }
        await Future.delayed(Duration(seconds: attempts * 2));
      } on TimeoutException {
        if (attempts >= _maxRetries) {
          const errorMsg =
              'Request timed out. Please check your connection and try again.';
          _handleCriticalError(errorMsg, errorType: 'timeout');
          return ApiResult.error(errorMsg, status: -1);
        }
        await Future.delayed(Duration(seconds: attempts * 2));
      } on FormatException catch (e) {
        log('$_logTag ❌ Format error: $e');
        const errorMsg = 'Invalid server response. Please try again later.';
        _handleCriticalError(errorMsg, errorType: 'server');
        return ApiResult.error(errorMsg, status: -1);
      } catch (e) {
        log('$_logTag ❌ Error: $e');
        if (attempts >= _maxRetries) {
          const errorMsg = 'Something went wrong. Please try again.';
          _handleCriticalError(errorMsg, errorType: 'error');
          return ApiResult.error(errorMsg, status: -1);
        }
        await Future.delayed(Duration(seconds: attempts * 2));
      }
    }

    const errorMsg = 'Max retry attempts exceeded. Please try again later.';
    _handleCriticalError(errorMsg, errorType: 'error');
    return ApiResult.error(errorMsg, status: -1);
  }
}
