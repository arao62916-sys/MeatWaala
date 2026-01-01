/// Ticket Message Model (Conversation Item)
/// Represents a single message in the ticket conversation (aItem)
class TicketMessageModel {
  final String messageId;
  final String message;
  final String? attachment;
  final String? attachmentUrl;
  final DateTime createdAt;
  final bool isCustomerMessage; // true = customer, false = support
  final String sender; // 'customer' or 'support'
  final String? senderName;

  TicketMessageModel({
    required this.messageId,
    required this.message,
    this.attachment,
    this.attachmentUrl,
    required this.createdAt,
    required this.isCustomerMessage,
    required this.sender,
    this.senderName,
  });

  factory TicketMessageModel.fromJson(Map<String, dynamic> json) {
    final sender = json['sender']?.toString().toLowerCase() ?? 'customer';
    final isCustomer = sender == 'customer' || sender == 'user';

    return TicketMessageModel(
      messageId: (json['id'] ?? json['message_id'] ?? '').toString(),
      message: json['message'] ?? json['msg'] ?? '',
      attachment: json['attachment'] ?? json['file'],
      attachmentUrl: json['attachment_url'] ?? json['file_url'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      isCustomerMessage: isCustomer,
      sender: sender,
      senderName: json['sender_name'] ?? json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'message': message,
      'attachment': attachment,
      'attachment_url': attachmentUrl,
      'created_at': createdAt.toIso8601String(),
      'sender': sender,
      'sender_name': senderName,
    };
  }

  bool get hasAttachment =>
      (attachment != null && attachment!.isNotEmpty) ||
      (attachmentUrl != null && attachmentUrl!.isNotEmpty);

  String get displayName {
    if (senderName != null && senderName!.isNotEmpty) {
      return senderName!;
    }
    return isCustomerMessage ? 'You' : 'Support Team';
  }
}
