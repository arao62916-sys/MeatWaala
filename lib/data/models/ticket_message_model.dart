// Ticket Message Model (Conversation Item)
/// Represents a single message in the ticket conversation (aItem)
class TicketMessageModel {
  final String messageId;
  final String message;
  final String? attachment;
  final String? attachmentUrl;
  final DateTime createdAt;
  final bool isCustomerMessage; // true = customer (left), false = support (right)
  final String sender; // 'Customer' or 'User'
  final String? senderName;
  final String align; // 'left' or 'right' from API

  TicketMessageModel({
    required this.messageId,
    required this.message,
    this.attachment,
    this.attachmentUrl,
    required this.createdAt,
    required this.isCustomerMessage,
    required this.sender,
    this.senderName,
    required this.align,
  });

  factory TicketMessageModel.fromJson(Map<String, dynamic> json) {
    // Use the align field from API to determine message side
    // align: "left" = Customer message (left side)
    // align: "right" = Support Executive message (right side)
    final align = json['align']?.toString().toLowerCase() ?? 'left';
    final isCustomer = align == 'left';
    
    // Parse the date field
    DateTime parsedDate = DateTime.now();
    if (json['date'] != null) {
      try {
        parsedDate = DateTime.parse(json['date']);
      } catch (e) {
        parsedDate = DateTime.now();
      }
    }

    return TicketMessageModel(
      messageId: (json['id'] ?? json['message_id'] ?? '').toString(),
      message: json['message'] ?? json['msg'] ?? '',
      attachment: json['file'],
      attachmentUrl: json['file_url'],
      createdAt: parsedDate,
      isCustomerMessage: isCustomer,
      sender: json['sender'] ?? 'Customer',
      senderName: json['name'],
      align: align,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'message': message,
      'file': attachment,
      'file_url': attachmentUrl,
      'date': createdAt.toIso8601String(),
      'sender': sender,
      'name': senderName,
      'align': align,
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