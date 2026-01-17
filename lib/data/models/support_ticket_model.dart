import 'package:meatwaala_app/data/models/ticket_message_model.dart';

/// Support Ticket Model
class SupportTicketModel {
  final String ticketId;
  final String customerId;
  final String subject;
  final String message;
  final String status;
  final String? response;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final DateTime? updatedAt;
  final String? file;
  final String? fileUrl;
  final bool isOpen;
  final List<TicketMessageModel> conversation;

  SupportTicketModel({
    required this.ticketId,
    required this.customerId,
    required this.subject,
    required this.message,
    required this.status,
    this.response,
    this.file,
    this.fileUrl,
    required this.createdAt,
    this.respondedAt,
    this.updatedAt,
    this.isOpen = true,
    this.conversation = const [],
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) {
    // 🔹 Handle wrapped response
    final Map<String, dynamic> data =
        json.containsKey('aTicket') ? json['aTicket'] : json;

    final status = data['status'] ?? '';
    final isOpen = status.toString().toLowerCase() == 'open' ||
        status == '1' ||
        status == 1;

    // 🔹 Parse conversation (aItem)
    List<TicketMessageModel> messages = [];
    if (data['aItem'] is List) {
      messages = (data['aItem'] as List)
          .map((e) => TicketMessageModel.fromJson(e))
          .toList();
    }

    return SupportTicketModel(
      ticketId: (data['ticket_id'] ?? data['id'] ?? '').toString(),
      customerId: (data['customer_id'] ?? '').toString(),
      subject: data['subject'] ?? '',
      message: data['message'] ?? data['description'] ?? '',
      status: status.toString(),
      response: data['response'] ?? data['reply'],
      file:
          (data['file'] ?? data['attachment'] ?? data['file_name'])?.toString(),
      fileUrl: (data['file_url'] ?? data['attachment_url'] ?? data['fileUrl'])
          ?.toString(),
      createdAt: DateTime.tryParse(data['created_at'] ?? data['date'] ?? '') ??
          DateTime.now(),
      respondedAt: data['responded_at'] != null
          ? DateTime.tryParse(data['responded_at'])
          : null,
      updatedAt: data['updated_at'] != null
          ? DateTime.tryParse(data['updated_at'])
          : null,
      isOpen: isOpen,
      conversation: messages,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticket_id': ticketId,
      'customer_id': customerId,
      'subject': subject,
      'message': message,
      'status': status,
      'response': response,
      'file': file,
      'file_url': fileUrl,
      'created_at': createdAt.toIso8601String(),
      'responded_at': respondedAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'aItem': conversation.map((e) => e.toJson()).toList(),
    };
  }

  String get statusDisplay => isOpen ? 'Open' : 'Closed';

  bool get hasResponse => response != null && response!.isNotEmpty;

  bool get hasConversation => conversation.isNotEmpty;

  int get messageCount => conversation.length;

  String? get lastMessage =>
      conversation.isEmpty ? null : conversation.last.message;

  DateTime? get lastMessageTime =>
      conversation.isEmpty ? null : conversation.last.createdAt;

  SupportTicketModel copyWith({
    String? ticketId,
    String? customerId,
    String? subject,
    String? message,
    String? status,
    String? response,
    String? file,
    String? fileUrl,
    DateTime? createdAt,
    DateTime? respondedAt,
    DateTime? updatedAt,
    bool? isOpen,
    List<TicketMessageModel>? conversation,
  }) {
    return SupportTicketModel(
      ticketId: ticketId ?? this.ticketId,
      customerId: customerId ?? this.customerId,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      status: status ?? this.status,
      response: response ?? this.response,
      file: file ?? this.file,
      fileUrl: fileUrl ?? this.fileUrl,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isOpen: isOpen ?? this.isOpen,
      conversation: conversation ?? this.conversation,
    );
  }
}
