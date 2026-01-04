import 'dart:io';

import 'package:meatwaala_app/core/network/base_api_service.dart';
import 'package:meatwaala_app/core/network/network_constents.dart';
import 'package:meatwaala_app/data/models/support_ticket_model.dart';
import 'package:meatwaala_app/services/storage_service.dart';

class SupportApiService {
  final BaseApiService _apiService = BaseApiService();
  final StorageService _storage = StorageService();

  /// Get customer_id from storage
  String? get customerId => _storage.getUserId();

  /// Validate customer ID
  bool _validateCustomerId() {
    return customerId != null && customerId!.isNotEmpty;
  }

  /// Get Support Ticket List
  /// GET: support/list/{customer_id}
  Future<ApiResult<List<SupportTicketModel>>> getSupportTickets() async {
    if (!_validateCustomerId()) {
      return ApiResult.error('Customer ID not found. Please login.');
    }

    final endpoint = '${NetworkConstantsUtil.supportList}/$customerId';

    return await _apiService.get(
      endpoint,
      parser: (data) {
        if (data is List) {
          return data.map((e) => SupportTicketModel.fromJson(e)).toList();
        } else if (data is Map && data.containsKey('aTicket')) {
          // Handle wrapped response
          final tickets = data['aTicket'];
          if (tickets is List) {
            return tickets.map((e) => SupportTicketModel.fromJson(e)).toList();
          } else if (tickets is Map) {
            return tickets.values
                .map((e) => SupportTicketModel.fromJson(e))
                .toList();
          }
        }
        return <SupportTicketModel>[];
      },
    );
  }

  /// Get Support Ticket Details (with conversation)
  /// GET: support/info/{customer_id}/{ticket_id}
  Future<ApiResult<SupportTicketModel>> getSupportTicketDetails(
    String ticketId,
  ) async {
    if (!_validateCustomerId()) {
      return ApiResult.error('Customer ID not found. Please login.');
    }

    final endpoint =
        '${NetworkConstantsUtil.supportInfo}/$customerId/$ticketId';

    return await _apiService.get(
      endpoint,
      parser: (data) {
        if (data is Map<String, dynamic>) {
          return SupportTicketModel.fromJson(data);
        }
        throw Exception('Invalid support ticket data');
      },
    );
  }

  /// Submit Support Ticket (with optional file attachment)
  /// POST: support/submit/{customer_id}
  /// multipart/form-data
Future<ApiResult<Map<String, dynamic>>> submitSupportTicket({
  required String subject,
  required String message,
  File? file, // will be ignored in this version
}) async {
  if (!_validateCustomerId()) {
    return ApiResult.error('Customer ID not found. Please login.');
  }

  final endpoint = '${NetworkConstantsUtil.supportSubmit}/$customerId';

  // Prepare body
  final body = {
    'subject': subject,
    'message': message,
  };

  return await _apiService.postWithTokenOnly(
    endpoint,
    body: body,
    parser: (data) {
      if (data is Map<String, dynamic>) {
        return data;
      }
      return <String, dynamic>{};
    },
  );
}

  /// Reply to Support Ticket (with optional file attachment)
  /// POST: support/reply/{customer_id}/{ticket_id}
  /// multipart/form-data
  Future<ApiResult<Map<String, dynamic>>> replyToTicket({
    required String ticketId,
    required String message,
    File? file,
  }) async {
    if (!_validateCustomerId()) {
      return ApiResult.error('Customer ID not found. Please login.');
    }

    final endpoint =
        '${NetworkConstantsUtil.supportReply}/$customerId/$ticketId';

    // Prepare fields
    final fields = {
      'message': message,
    };

    // Prepare files
    Map<String, File>? files;
    if (file != null && await file.exists()) {
      files = {'file': file};
    }

    return await _apiService.postMultipart(
      endpoint,
      fields: fields,
      files: files,
      parser: (data) {
        if (data is Map<String, dynamic>) {
          return data;
        }
        return <String, dynamic>{};
      },
    );
  }

  /// Close Support Ticket
  /// GET: support/close/{customer_id}/{ticket_id}
  Future<ApiResult<Map<String, dynamic>>> closeTicket(
    String ticketId,
  ) async {
    if (!_validateCustomerId()) {
      return ApiResult.error('Customer ID not found. Please login.');
    }

    final endpoint =
        '${NetworkConstantsUtil.supportClose}/$customerId/$ticketId';

    return await _apiService.get(
      endpoint,
      parser: (data) {
        if (data is Map<String, dynamic>) {
          return data;
        }
        return <String, dynamic>{};
      },
    );
  }

  /// Create Support Ticket (Legacy - without file)
  /// POST: support/create/{customer_id}
  /// Kept for backward compatibility
  @Deprecated('Use submitSupportTicket instead')
  Future<ApiResult<Map<String, dynamic>>> createSupportTicket({
    required String subject,
    required String message,
  }) async {
    if (!_validateCustomerId()) {
      return ApiResult.error('Customer ID not found. Please login.');
    }

    final endpoint = '${NetworkConstantsUtil.supportCreate}/$customerId';

    return await _apiService.post(
      endpoint,
      body: {
        'subject': subject,
        'message': message,
      },
      parser: (data) {
        if (data is Map<String, dynamic>) {
          return data;
        }
        return <String, dynamic>{};
      },
    );
  }
}
