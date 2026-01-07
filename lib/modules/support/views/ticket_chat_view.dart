import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:meatwaala_app/core/theme/app_colors.dart';
import 'package:meatwaala_app/data/models/ticket_message_model.dart';
import 'package:meatwaala_app/data/models/support_ticket_model.dart';
import 'package:meatwaala_app/modules/support/controllers/support_controller.dart';

class TicketChatView extends GetView<SupportController> {
  const TicketChatView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get ticket ID from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    final ticketId = args?['ticketId']?.toString() ?? '';

    // Load ticket details AFTER build completes
    if (ticketId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.loadTicketDetails(ticketId);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.selectedTicket.value?.subject ?? 'Ticket Details',
                  style: const TextStyle(fontSize: 16),
                ),
                if (controller.selectedTicket.value != null)
                  Text(
                    'Ticket ID: ${controller.selectedTicket.value!.ticketId}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
              ],
            )),
        actions: [
          Obx(() {
            final ticket = controller.selectedTicket.value;
            if (ticket != null && ticket.isOpen) {
              return PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'close') {
                    _showCloseConfirmation(context, ticketId);
                  } else if (value == 'refresh') {
                    controller.refreshCurrentTicket();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'refresh',
                    child: Row(
                      children: [
                        Icon(Icons.refresh),
                        SizedBox(width: 8),
                        Text('Refresh'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'close',
                    child: Row(
                      children: [
                        Icon(Icons.close, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Close Ticket',
                            style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              );
            }
            return IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: controller.refreshCurrentTicket,
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.selectedTicket.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final ticket = controller.selectedTicket.value;
        if (ticket == null) {
          return const Center(
            child: Text('Failed to load ticket details'),
          );
        }

        return Column(
          children: [
            // Status Banner
            _StatusBanner(ticket: ticket),

            // Chat Messages
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshCurrentTicket,
                child: ListView.builder(
                  controller: controller.chatScrollController,
                  padding: const EdgeInsets.all(16),
                  // ✅ Show initial message + conversation messages
                  itemCount: 1 + ticket.conversation.length,
                  itemBuilder: (context, index) {
                    // First item is the initial ticket message
                    if (index == 0) {
                      return _InitialMessageCard(ticket: ticket);
                    }

                    // Subsequent items are conversation messages
                    final message = ticket.conversation[index - 1];
                    return _MessageBubble(message: message);
                  },
                ),
              ),
            ),

            // Reply Input
            if (ticket.isOpen)
              _ReplyInput(
                ticketId: ticketId,
                controller: controller,
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[200],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock, color: AppColors.textSecondary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'This ticket is closed',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      }),
    );
  }

  void _showCloseConfirmation(BuildContext context, String ticketId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close Ticket'),
        content: const Text(
          'Are you sure you want to close this ticket? You won\'t be able to reply after closing.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          Obx(() => ElevatedButton(
                onPressed: controller.isClosing.value
                    ? null
                    : () async {
                        final success = await controller.closeTicket(ticketId);
                        if (success) {
                          Get.back(); // Close dialog
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: controller.isClosing.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text('Close Ticket'),
              )),
        ],
      ),
    );
  }
}

// Status Banner Widget
class _StatusBanner extends StatelessWidget {
  final SupportTicketModel ticket;

  const _StatusBanner({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ticket.isOpen
            ? Colors.orange.withOpacity(0.1)
            : Colors.green.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: ticket.isOpen
                ? Colors.orange.withOpacity(0.3)
                : Colors.green.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                ticket.isOpen ? Icons.pending : Icons.check_circle,
                color: ticket.isOpen ? Colors.orange : Colors.green,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Status: ${ticket.statusDisplay}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: ticket.isOpen ? Colors.orange[800] : Colors.green[800],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('dd MMM yyyy').format(ticket.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              if (ticket.messageCount > 0)
                Text(
                  '${ticket.messageCount} repl${ticket.messageCount > 1 ? 'ies' : 'y'}',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// Initial Ticket Message Card (Customer's first message)
class _InitialMessageCard extends StatelessWidget {
  final SupportTicketModel ticket;

  const _InitialMessageCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: "Original Request"
          Row(
            children: [
              Icon(
                Icons.local_post_office_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Original Request',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('MMM dd, yyyy • hh:mm a').format(ticket.createdAt),
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Message Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subject
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.subject,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ticket.subject,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Divider
                Divider(
                  color: AppColors.primary.withOpacity(0.2),
                  height: 1,
                ),

                const SizedBox(height: 12),

                // Message
                Text(
                  ticket.message,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Conversation divider (if there are replies)
          if (ticket.conversation.isNotEmpty)
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: AppColors.textSecondary.withOpacity(0.3),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'CONVERSATION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: AppColors.textSecondary.withOpacity(0.3),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// Message Bubble Widget (for conversation replies)
class _MessageBubble extends StatelessWidget {
  final TicketMessageModel message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isCustomer = message.isCustomerMessage;
    final alignment =
        isCustomer ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor =
        isCustomer ? AppColors.primary.withOpacity(0.1) : Colors.grey[200];
    final textColor = isCustomer ? AppColors.primary : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          // Sender Name
          Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 12, right: 12),
            child: Text(
              message.displayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          // Message Bubble
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCustomer
                    ? AppColors.primary.withOpacity(0.3)
                    : Colors.grey[300]!,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Message Text
                Text(
                  message.message,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                  ),
                ),

                // Attachment
                if (message.hasAttachment) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _openAttachment(message.attachmentUrl ?? ''),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.attach_file,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              message.attachment ?? 'Attachment',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                decoration: TextDecoration.underline,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Timestamp
                const SizedBox(height: 4),
                Text(
                  DateFormat('hh:mm a').format(message.createdAt),
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAttachment(String url) async {
    // TODO: Install url_launcher package
    // Add to pubspec.yaml: url_launcher: ^6.2.0
    Get.snackbar(
      'Feature Unavailable',
      'URL launcher not installed. Add url_launcher to pubspec.yaml',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );

    // Uncomment below after installing url_launcher package:
    /*
    if (url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Cannot open attachment',
          snackPosition: SnackPosition.TOP,
        );
      }
    }
    */
  }
}

// Reply Input Widget
class _ReplyInput extends StatelessWidget {
  final String ticketId;
  final SupportController controller;

  const _ReplyInput({
    required this.ticketId,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Selected File Display
          Obx(() {
            final hasFile = controller.selectedFile.value != null;
            if (!hasFile) return const SizedBox.shrink();

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.attach_file, color: Colors.green[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      controller.selectedFileName.value,
                      style: const TextStyle(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: controller.clearSelectedFile,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            );
          }),

          // Input Row
          Row(
            children: [
              // Attachment Button
              IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: () => _pickFile(context),
                color: AppColors.primary,
              ),

              // Text Input
              Expanded(
                child: TextField(
                  controller: controller.replyMessageController,
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),

              const SizedBox(width: 8),

              // Send Button
              Obx(() => CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: controller.isReplying.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.send, color: Colors.white),
                            onPressed: () => _sendReply(ticketId),
                            padding: EdgeInsets.zero,
                          ),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile(BuildContext context) async {
    // TODO: Install file_picker package
    // Add to pubspec.yaml: file_picker: ^6.0.0
    Get.snackbar(
      'Feature Unavailable',
      'File picker not installed. Add file_picker to pubspec.yaml',
      snackPosition: SnackPosition.TOP,
    );

    // Uncomment below after installing file_picker package:
    /*
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        controller.selectFile(file);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick file: $e',
        snackPosition: SnackPosition.TOP,
      );
    }
    */
  }

  Future<void> _sendReply(String ticketId) async {
    await controller.replyToTicket(ticketId: ticketId);
  }
}
