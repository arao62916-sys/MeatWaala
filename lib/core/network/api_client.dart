import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:meatwaala_app/core/network/network_constents.dart';
import 'package:meatwaala_app/core/services/storage_service.dart';

/// Generic API Response wrapper
class ApiResponse<T> {
  final bool success;
  final int statusCode;
  final String? message;
  final T? data;

  ApiResponse({
    required this.success,
    required this.statusCode,
    this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    final statusCode = json['status'] ?? 200;
    final success = json['success'] == true;
    final rawData = json['data'] ?? json;

    // Attempt to extract a detailed message if success is false
    String? message = json['msg']?.toString();

    if (!success) {
      // If message is generic, look into 'data' or 'errors' for specifics
      if (message == null ||
          message.toLowerCase().contains('validation error') ||
          message.isEmpty) {
        final errorData = json['data'] ?? json['errors'];
        if (errorData is Map<String, dynamic>) {
          final errorStrings = <String>[];
          errorData.forEach((key, value) {
            if (value is List) {
              errorStrings.add(value.join(", "));
            } else if (value is Map) {
              value.forEach((k, v) => errorStrings.add(v.toString()));
            } else {
              errorStrings.add(value.toString());
            }
          });
          if (errorStrings.isNotEmpty) {
            message = errorStrings.join('\n');
          }
        } else if (errorData is String && errorData.isNotEmpty) {
          message = errorData;
        } else if (errorData is List && errorData.isNotEmpty) {
          message = errorData.join('\n');
        }
      }
    }

    return ApiResponse(
      success: success,
      statusCode: statusCode,
      message: message ?? '',
      data: fromJsonT != null ? fromJsonT(rawData) : rawData as T?,
    );
  }

  factory ApiResponse.error(int statusCode, String message) {
    return ApiResponse(
      success: false,
      statusCode: statusCode,
      message: message,
    );
  }
}

/// Main API Client
class ApiClient {
  final String baseUrl;
  final int timeoutSeconds;
  final int maxRetries;

  ApiClient({
    this.baseUrl = NetworkConstantsUtil.baseUrl,
    this.timeoutSeconds = 30,
    this.maxRetries = 3,
  });

  static const String _logTag = '🛜 API_CLIENT';
  static bool _isRefreshing = false;
  static final List<Completer<bool>> _refreshQueue = [];

  /// GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    T Function(dynamic)? fromJsonT,
    bool isRetryAfterRefresh = false,
  }) async {
    return _executeWithRetry(() async {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .get(url, headers: await _buildHeaders(headers))
          .timeout(Duration(seconds: timeoutSeconds));

      // Check for 401 and attempt token refresh
      if (response.statusCode == 401 && !isRetryAfterRefresh) {
        final refreshed = await _handleTokenRefresh();
        if (refreshed) {
          return get<T>(
            endpoint,
            headers: headers,
            fromJsonT: fromJsonT,
            isRetryAfterRefresh: true,
          );
        }
      }

      return _mapResponse(response, fromJsonT);
    });
  }

  /// POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
    T Function(dynamic)? fromJsonT,
    bool isRetryAfterRefresh = false,
  }) async {
    return _executeWithRetry(() async {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .post(
            url,
            headers: await _buildHeaders(headers),
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: timeoutSeconds));

      // Check for 401 and attempt token refresh
      if (response.statusCode == 401 && !isRetryAfterRefresh) {
        final refreshed = await _handleTokenRefresh();
        if (refreshed) {
          return post<T>(
            endpoint,
            body,
            headers: headers,
            fromJsonT: fromJsonT,
            isRetryAfterRefresh: true,
          );
        }
      }

      return _mapResponse(response, fromJsonT);
    });
  }

  /// POST Multipart request (for file uploads)
  Future<ApiResponse<T>> postMultipart<T>(
    String endpoint, {
    Map<String, String>? fields,
    Map<String, File>? files,
    Map<String, String>? headers,
    T Function(dynamic)? fromJsonT,
    bool isRetryAfterRefresh = false,
  }) async {
    return _executeWithRetry(() async {
      final url = Uri.parse('$baseUrl$endpoint');
      final request = http.MultipartRequest('POST', url);

      // Add headers
      final builtHeaders = await _buildHeaders(headers);
      // Remove Content-Type because MultipartRequest sets it automatically
      builtHeaders.remove('Content-Type');
      request.headers.addAll(builtHeaders);

      // Add text fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Add files
      if (files != null) {
        for (var entry in files.entries) {
          final file = entry.value;
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            final length = bytes.length;
            final fileName = file.path.split('/').last;

            print(
              '$_logTag Attaching file: $fileName (size: $length bytes) to field: ${entry.key}',
            );

            final extension = fileName.split('.').last.toLowerCase();
            String mimeType = 'image/jpeg';
            if (extension == 'png') mimeType = 'image/png';
            if (extension == 'gif') mimeType = 'image/gif';

            final multipartFile = http.MultipartFile.fromBytes(
              entry.key,
              bytes,
              filename: fileName,
              contentType: MediaType.parse(mimeType),
            );
            request.files.add(multipartFile);
          } else {
            print('$_logTag ⚠️ File does not exist: ${file.path}');
          }
        }
      }

      print('$_logTag Sending Multipart Request to ${request.url}');
      print('$_logTag Headers: ${request.headers}');
      print('$_logTag Fields: ${request.fields}');

      final streamedResponse = await request.send().timeout(
        Duration(seconds: timeoutSeconds),
      );
      final response = await http.Response.fromStream(streamedResponse);

      // Detailed logging for debugging multipart issues
      print('$_logTag Multipart Response Body: ${response.body}');

      // Check for 401 and attempt token refresh
      if (response.statusCode == 401 && !isRetryAfterRefresh) {
        final refreshed = await _handleTokenRefresh();
        if (refreshed) {
          return postMultipart<T>(
            endpoint,
            fields: fields,
            files: files,
            headers: headers,
            fromJsonT: fromJsonT,
            isRetryAfterRefresh: true,
          );
        }
      }

      return _mapResponse(response, fromJsonT);
    });
  }

  /// Execute PDF request with retry logic
  Future<Uint8List?> _executePdfWithRetry(
    Future<Uint8List?> Function() request,
  ) async {
    int retryCount = 0;
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);

    while (retryCount < maxRetries) {
      try {
        final result = await request();
        if (result != null) {
          return result;
        }

        // If result is null, retry
        retryCount++;
        if (retryCount < maxRetries) {
          print('⚠️ PDF request failed, retrying ($retryCount/$maxRetries)...');
          await Future.delayed(retryDelay * retryCount);
        }
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          print('❌ Max retries reached for PDF request: $e');
          return null;
        }
        print('⚠️ PDF request error, retrying ($retryCount/$maxRetries): $e');
        await Future.delayed(retryDelay * retryCount);
      }
    }

    return null;
  }

  /// POST request for PDF blob response with retry
  Future<Uint8List?> postForPdf(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
    bool isRetryAfterRefresh = false,
  }) async {
    return _executePdfWithRetry(() async {
      try {
        final url = Uri.parse('$baseUrl$endpoint');

        print('PDF API Call: POST $endpoint');
        print('Request body keys: ${body.keys.join(", ")}');

        final response = await http
            .post(
              url,
              headers: await _buildHeaders(headers),
              body: jsonEncode(body),
            )
            .timeout(Duration(seconds: timeoutSeconds));

        print('📥 Response status: ${response.statusCode}');
        print('📦 Response content type: ${response.headers['content-type']}');

        // Check for 401 and attempt token refresh
        if (response.statusCode == 401 && !isRetryAfterRefresh) {
          print('🔄 Token expired, attempting refresh...');
          final refreshed = await _handleTokenRefresh();
          if (refreshed) {
            return postForPdf(
              endpoint,
              body,
              headers: headers,
              isRetryAfterRefresh: true,
            );
          }
        }

        // Check if response is successful
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response.bodyBytes;
        } else {
          print('❌ PDF request failed: ${response.statusCode}');
          print('❌ Response body: ${response.body}');
          return null;
        }
      } catch (e) {
        print('❌ Error in postForPdf request: $e');
        rethrow; // Let _executePdfWithRetry handle the retry
      }
    });
  }

  /// PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
    T Function(dynamic)? fromJsonT,
    bool isRetryAfterRefresh = false,
  }) async {
    return _executeWithRetry(() async {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .put(
            url,
            headers: await _buildHeaders(headers),
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: timeoutSeconds));

      // Check for 401 and attempt token refresh
      if (response.statusCode == 401 && !isRetryAfterRefresh) {
        final refreshed = await _handleTokenRefresh();
        if (refreshed) {
          return put<T>(
            endpoint,
            body,
            headers: headers,
            fromJsonT: fromJsonT,
            isRetryAfterRefresh: true,
          );
        }
      }

      return _mapResponse(response, fromJsonT);
    });
  }

  /// DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? headers,
    T Function(dynamic)? fromJsonT,
    bool isRetryAfterRefresh = false,
  }) async {
    return _executeWithRetry(() async {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .delete(url, headers: await _buildHeaders(headers))
          .timeout(Duration(seconds: timeoutSeconds));

      // Check for 401 and attempt token refresh
      if (response.statusCode == 401 && !isRetryAfterRefresh) {
        final refreshed = await _handleTokenRefresh();
        if (refreshed) {
          return delete<T>(
            endpoint,
            headers: headers,
            fromJsonT: fromJsonT,
            isRetryAfterRefresh: true,
          );
        }
      }

      return _mapResponse(response, fromJsonT);
    });
  }

  /// ---- TOKEN REFRESH LOGIC ----
  Future<bool> _handleTokenRefresh() async {
    // If already refreshing, wait for that refresh to complete
    if (_isRefreshing) {
      final completer = Completer<bool>();
      _refreshQueue.add(completer);
      return completer.future;
    }

    _isRefreshing = true;
    log('$_logTag 🔄 Token expired, attempting refresh...');

    try {
      final refreshToken = await StorageService.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        log('$_logTag ❌ No refresh token available');
        await _handleLogout();
        return false;
      }

      final uri = Uri.parse(
        '${baseUrl}Auth/refreshToken',
      ).replace(queryParameters: {'refreshToken': refreshToken});
      final currentToken = await StorageService.getToken();

      log('$_logTag 🔄 Refreshing token... The url is $uri');
      log('$_logTag 🔄 Refreshing token... The current token is $currentToken');
      log('$_logTag 🔄 Refreshing token... The refresh token is $refreshToken');

      final response = await http
          .get(
            uri,
            headers: {
              'accept': 'text/plain',
              'Authorization': 'Bearer ${currentToken ?? ''}',
            },
          )
          .timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);

        if (json['success'] == true && json['data'] != null) {
          final data = json['data'];

          // Update token and refresh token in storage
          await StorageService.saveLoginData(
            token: data['token'] ?? '',
            userId: data['userId'] ?? await StorageService.getUserId() ?? '',
            userName:
                data['userName'] ?? await StorageService.getUserName() ?? '',

            refreshToken: data['refreshToken'] ?? refreshToken,
          );

          log('$_logTag ✅ Token refreshed successfully');
          _notifyRefreshQueue(true);
          return true;
        }
      }

      log(
        '$_logTag ❌ Token refresh failed with status: ${response.statusCode}',
      );
      await _handleLogout();
      return false;
    } catch (e) {
      log('$_logTag ❌ Token refresh error: $e');
      await _handleLogout();
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  void _notifyRefreshQueue(bool success) {
    for (var completer in _refreshQueue) {
      if (!completer.isCompleted) {
        completer.complete(success);
      }
    }
    _refreshQueue.clear();
  }

  Future<void> _handleLogout() async {
    await StorageService.clearLoginData();

    // Navigate to login screen and remove all previous routes
    Get.offAllNamed('/login');
    // You can add navigation to login screen here or emit an event
    _notifyRefreshQueue(false);
  }

  /// ---- PRIVATE HELPERS ----
  Future<ApiResponse<T>> _executeWithRetry<T>(
    Future<ApiResponse<T>> Function() request,
  ) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        attempts++;
        return await request();
      } on SocketException {
        if (attempts >= maxRetries) {
          return ApiResponse.error(0, "No internet connection");
        }
        await Future.delayed(Duration(seconds: attempts * 2));
      } on TimeoutException {
        if (attempts >= maxRetries) {
          return ApiResponse.error(408, "Request timed out");
        }
        await Future.delayed(Duration(seconds: attempts * 2));
      } catch (e) {
        if (attempts >= maxRetries) return ApiResponse.error(500, e.toString());
        await Future.delayed(Duration(seconds: attempts * 2));
      }
    }

    return ApiResponse.error(500, "Max retry attempts exceeded");
  }

  ApiResponse<T> _mapResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJsonT,
  ) {
    final statusCode = response.statusCode;
    final emoji = statusCode >= 200 && statusCode < 300 ? '✅' : '❌';
    log('$_logTag $emoji Response [$statusCode] for ${response.request?.url}');

    try {
      if (response.body.isEmpty) {
        return ApiResponse.error(statusCode, "Empty response");
      }

      final Map<String, dynamic> json = jsonDecode(response.body);
      return ApiResponse.fromJson(json, fromJsonT);
    } catch (e) {
      log('$_logTag JSON parsing error: $e');
      return ApiResponse.error(statusCode, "Invalid JSON response");
    }
  }

  Future<Map<String, String>> _buildHeaders(
    Map<String, String>? headers,
  ) async {
    final authKey = await StorageService.getToken();
    final defaultHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (authKey != null) 'Authorization': 'Bearer $authKey',
    };
    return {...defaultHeaders, ...?headers};
  }
}
