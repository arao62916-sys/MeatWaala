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
  final bool isOpen;
  final List<TicketMessageModel> conversation; // aItem - chat messages

  SupportTicketModel({
    required this.ticketId,
    required this.customerId,
    required this.subject,
    required this.message,
    required this.status,
    this.response,
    required this.createdAt,
    this.respondedAt,
    this.updatedAt,
    this.isOpen = true,
    this.conversation = const [],
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) {
    final status = json['status'] ?? '';
    final isOpen =
        status.toLowerCase() == 'open' || status == '1' || status == 1;

    // Parse conversation (aItem)
    List<TicketMessageModel> messages = [];
    if (json.containsKey('aItem')) {
      final aItem = json['aItem'];
      if (aItem is List) {
        messages = aItem.map((e) => TicketMessageModel.fromJson(e)).toList();
      } else if (aItem is Map) {
        messages =
            aItem.values.map((e) => TicketMessageModel.fromJson(e)).toList();
      }
    }

    return SupportTicketModel(
      ticketId: (json['ticket_id'] ?? json['id'] ?? '').toString(),
      customerId: (json['customer_id'] ?? '').toString(),
      subject: json['subject'] ?? '',
      message: json['message'] ?? json['description'] ?? '',
      status: status.toString(),
      response: json['response'] ?? json['reply'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      respondedAt: json['responded_at'] != null
          ? DateTime.tryParse(json['responded_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
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
      'created_at': createdAt.toIso8601String(),
      'responded_at': respondedAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'aItem': conversation.map((e) => e.toJson()).toList(),
    };
  }

  String get statusDisplay {
    return isOpen ? 'Open' : 'Closed';
  }

  bool get hasResponse => response != null && response!.isNotEmpty;

  bool get hasConversation => conversation.isNotEmpty;

  int get messageCount => conversation.length;

  String? get lastMessage {
    if (conversation.isEmpty) return null;
    return conversation.last.message;
  }

  DateTime? get lastMessageTime {
    if (conversation.isEmpty) return null;
    return conversation.last.createdAt;
  }

  // Copy with method for updates
  SupportTicketModel copyWith({
    String? ticketId,
    String? customerId,
    String? subject,
    String? message,
    String? status,
    String? response,
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
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isOpen: isOpen ?? this.isOpen,
      conversation: conversation ?? this.conversation,
    );
  }
}
