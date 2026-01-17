import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:meatwaala_app/core/services/app_snackbar.dart';
import 'package:meatwaala_app/core/theme/app_colors.dart';
import 'package:meatwaala_app/data/models/ticket_message_model.dart';
import 'package:meatwaala_app/data/models/support_ticket_model.dart';
import 'package:meatwaala_app/modules/support/controllers/support_controller.dart';

class TicketChatView extends GetView<SupportController> {
  const TicketChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final ticketId = args?['ticketId']?.toString() ?? '';

    if (ticketId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.loadTicketDetails(ticketId);
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 2,
        shadowColor: AppColors.primary.withOpacity(0.1),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  controller.selectedTicket.value?.subject ?? 'Support Chat',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (controller.selectedTicket.value != null)
                  Text(
                    '#${controller.selectedTicket.value!.ticketId}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.white70,
                    ),
                  ),
              ],
            )),
        actions: [
          Obx(() {
            final ticket = controller.selectedTicket.value;
            if (ticket != null && ticket.isOpen) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
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
                        Icon(Icons.refresh, size: 20),
                        SizedBox(width: 12),
                        Text('Refresh'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'close',
                    child: Row(
                      children: [
                        Icon(Icons.close, color: Colors.red, size: 20),
                        SizedBox(width: 12),
                        Text('Close Ticket',
                            style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              );
            }
            return IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load ticket details',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Modern Status Banner
            _ModernStatusBanner(ticket: ticket),

            // Chat Messages
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshCurrentTicket,
                child: ListView.builder(
                  controller: controller.chatScrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: 1 + ticket.conversation.length,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _ModernInitialMessageCard(ticket: ticket);
                    }
                    final message = ticket.conversation[index - 1];
                    return _ModernMessageBubble(message: message);
                  },
                ),
              ),
            ),

            // Reply Input
            if (ticket.isOpen)
              _ModernReplyInput(
                ticketId: ticketId,
                controller: controller,
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline, color: Colors.grey[600], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'This ticket is closed',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Close Ticket',
            style: TextStyle(fontWeight: FontWeight.w600)),
        content: const Text(
          'Are you sure you want to close this ticket? You won\'t be able to reply after closing.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[700])),
          ),
          Obx(() => ElevatedButton(
                onPressed: controller.isClosing.value
                    ? null
                    : () async {
                        final success = await controller.closeTicket(ticketId);
                        if (success) {
                          Get.back();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
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

// Modern Status Banner
class _ModernStatusBanner extends StatelessWidget {
  final SupportTicketModel ticket;

  const _ModernStatusBanner({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: ticket.isOpen
                  ? const Color(0xFFFFF4E6)
                  : const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: ticket.isOpen
                        ? const Color(0xFFFFA726)
                        : const Color(0xFF66BB6A),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  ticket.statusDisplay,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: ticket.isOpen
                        ? const Color(0xFFE65100)
                        : const Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            DateFormat('MMM dd, yyyy').format(ticket.createdAt),
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

// Modern Initial Message Card
class _ModernInitialMessageCard extends StatelessWidget {
  final SupportTicketModel ticket;

  const _ModernInitialMessageCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Divider
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                DateFormat('MMMM dd, yyyy').format(ticket.createdAt),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Initial Message - Customer message (LEFT side)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Customer avatar on left
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF64B5F6), Color(0xFF42A5F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF64B5F6).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.person, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 8),

              // Message content
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sender name
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6, left: 12),
                        child: Text(
                          'You',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),

                      // Message bubble
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(18),
                            topRight: Radius.circular(18),
                            bottomLeft: Radius.circular(4),
                            bottomRight: Radius.circular(18),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Subject
                            Row(
                              children: [
                                Icon(Icons.topic, 
                                    size: 16, 
                                    color: AppColors.primary),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    ticket.subject,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Message
                            Text(
                              ticket.message,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                                height: 1.5,
                              ),
                            ),

                            // Attachment if exists
                            if (ticket.fileUrl != null && 
                                ticket.fileUrl!.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              InkWell(
                                onTap: () => _openAttachment(ticket.fileUrl!),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Colors.grey[300]!),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.attach_file,
                                          size: 16,
                                          color: AppColors.primary),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          ticket.file ?? 'Attachment',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.primary,
                                            decoration:
                                                TextDecoration.underline,
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
                            const SizedBox(height: 8),
                            Text(
                              DateFormat('hh:mm a').format(ticket.createdAt),
                              style: TextStyle(
                                  fontSize: 10, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (ticket.conversation.isNotEmpty) const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _openAttachment(String url) {
    AppSnackbar.info(
      'Opening: $url',
      title: 'Attachment',
    );
  }
}

// Modern Message Bubble - CORRECTED for Left-Right alignment
class _ModernMessageBubble extends StatelessWidget {
  final TicketMessageModel message;

  const _ModernMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    // Customer messages on LEFT, Support messages on RIGHT
    final isCustomer = message.isCustomerMessage;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxBubbleWidth = screenWidth * 0.75;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isCustomer ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Left avatar (Customer)
          if (isCustomer) ...[
            _buildAvatar(isCustomer: true),
            const SizedBox(width: 8),
          ],

          // Message Content
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: maxBubbleWidth),
              child: Column(
                crossAxisAlignment: isCustomer
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: [
                  // Sender name
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: 6, left: 12, right: 12),
                    child: Text(
                      message.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),

                  // Message bubble
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isCustomer 
                          ? Colors.grey[100] 
                          : AppColors.primary,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isCustomer ? 4 : 18),
                        bottomRight: Radius.circular(isCustomer ? 18 : 4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.message,
                          style: TextStyle(
                            color: isCustomer 
                                ? AppColors.textPrimary 
                                : Colors.white,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),

                        // Attachment
                        if (message.hasAttachment) ...[
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: () =>
                                _openAttachment(message.attachmentUrl ?? ''),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isCustomer 
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                                border: isCustomer 
                                    ? Border.all(color: Colors.grey[300]!)
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.attach_file,
                                    size: 16,
                                    color: isCustomer 
                                        ? AppColors.primary 
                                        : Colors.white,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      message.attachment ?? 'Attachment',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isCustomer 
                                            ? AppColors.primary 
                                            : Colors.white,
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
                            color: isCustomer 
                                ? Colors.grey[600] 
                                : Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right avatar (Support Executive)
          if (!isCustomer) ...[
            const SizedBox(width: 8),
            _buildAvatar(isCustomer: false),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar({required bool isCustomer}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCustomer
              ? [const Color(0xFF64B5F6), const Color(0xFF42A5F5)]
              : [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (isCustomer ? const Color(0xFF64B5F6) : AppColors.primary)
                .withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        isCustomer ? Icons.person : Icons.support_agent,
        size: 18,
        color: Colors.white,
      ),
    );
  }

  Future<void> _openAttachment(String url) async {
    if (url.isNotEmpty) {
      AppSnackbar.info(
        'Opening attachment: $url',
        title: 'Attachment',
      );
      // TODO: Implement url_launcher
      // await launchUrl(Uri.parse(url));
    }
  }
}

// Modern Reply Input
class _ModernReplyInput extends StatelessWidget {
  final String ticketId;
  final SupportController controller;

  const _ModernReplyInput({
    required this.ticketId,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Selected File Display
            Obx(() {
              final hasFile = controller.selectedFile.value != null;
              if (!hasFile) return const SizedBox.shrink();

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF66BB6A)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.attach_file,
                          color: Color(0xFF66BB6A), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        controller.selectedFileName.value,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: controller.clearSelectedFile,
                      color: Colors.grey[700],
                    ),
                  ],
                ),
              );
            }),

            // Input Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Attachment Button
                Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.attach_file, color: AppColors.primary),
                    onPressed: () => _pickFile(context),
                  ),
                ),

                const SizedBox(width: 8),

                // Text Input
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: controller.replyMessageController,
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Send Button
                Obx(() => Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.8)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: controller.isReplying.value
                              ? null
                              : () => _sendReply(ticketId),
                          child: Container(
                            width: 48,
                            height: 48,
                            alignment: Alignment.center,
                            child: controller.isReplying.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.send,
                                    color: Colors.white, size: 22),
                          ),
                        ),
                      ),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Wrap(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.camera_alt, color: AppColors.primary),
                ),
                title: const Text('Take Photo'),
                onTap: () async {
                  Get.back();
                  await controller.pickImageFromCamera();
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.photo_library, color: AppColors.primary),
                ),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Get.back();
                  await controller.pickImageFromGallery();
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.grey),
                ),
                title: const Text('Cancel'),
                onTap: () => Get.back(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendReply(String ticketId) async {
    await controller.replyToTicket(ticketId: ticketId);
  }
}