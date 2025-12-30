import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:meatwaala_app/core/network/network_constents.dart';

/// Standardized API Response wrapper
class ApiResult<T> {
  final bool success;
  final int status;
  final String message;
  final T? data;

  ApiResult({
    required this.success,
    required this.status,
    required this.message,
    this.data,
  });

  factory ApiResult.success(T data,
      {String message = 'Success', int status = 1}) {
    return ApiResult(
      success: true,
      status: status,
      message: message,
      data: data,
    );
  }

  factory ApiResult.error(String message, {int status = 0}) {
    return ApiResult(
      success: false,
      status: status,
      message: message,
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

  /// Build headers for API requests
  Map<String, String> _buildHeaders({Map<String, String>? additionalHeaders}) {
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer ${NetworkConstantsUtil.bearerToken}',
    };
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
            headers: _buildHeaders(
                additionalHeaders: {'Content-Type': 'application/json'}),
            body: body != null ? jsonEncode(body) : null,
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
              'Content-Type': 'application/x-www-form-urlencoded'
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
        );
      } else {
        return ApiResult.error(
          message.isNotEmpty ? message : 'Request failed',
          status: apiStatus,
        );
      }
    } catch (e) {
      log('$_logTag ❌ JSON parsing error: $e');
      return ApiResult.error('Failed to parse response');
    }
  }

  /// Execute request with retry logic
  Future<ApiResult<T>> _executeWithRetry<T>(
    Future<ApiResult<T>> Function() request,
  ) async {
    int attempts = 0;

    while (attempts < _maxRetries) {
      try {
        attempts++;
        return await request();
      } on SocketException {
        if (attempts >= _maxRetries) {
          return ApiResult.error(
              'No internet connection. Please check your network.');
        }
        await Future.delayed(Duration(seconds: attempts * 2));
      } on TimeoutException {
        if (attempts >= _maxRetries) {
          return ApiResult.error('Request timed out. Please try again.');
        }
        await Future.delayed(Duration(seconds: attempts * 2));
      } on FormatException catch (e) {
        log('$_logTag ❌ Format error: $e');
        return ApiResult.error('Invalid response format');
      } catch (e) {
        log('$_logTag ❌ Error: $e');
        if (attempts >= _maxRetries) {
          return ApiResult.error('Something went wrong. Please try again.');
        }
        await Future.delayed(Duration(seconds: attempts * 2));
      }
    }

    return ApiResult.error('Max retry attempts exceeded');
  }
}
