import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meatwaala_app/core/services/app_snackbar.dart';
import 'package:meatwaala_app/data/models/support_ticket_model.dart';
import 'package:meatwaala_app/data/models/ticket_message_model.dart';
import 'package:meatwaala_app/data/services/support_api_service.dart';

class SupportController extends GetxController {
  final SupportApiService _supportService = SupportApiService();

  // Observable state
  final tickets = <SupportTicketModel>[].obs;
  final Rxn<SupportTicketModel> selectedTicket = Rxn<SupportTicketModel>();
  final RxBool isLoading = false.obs;
  final RxBool isCreating = false.obs;
  final RxBool isReplying = false.obs;
  final RxBool isClosing = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasLoadedTicket = false.obs;

  // ✅ ALL TextEditingControllers managed by controller - NOT in widget build()
  // This prevents "used after being disposed" errors

  // For Create Ticket Form
  late final TextEditingController subjectController;
  late final TextEditingController createMessageController;

  // For Chat Reply
  late final TextEditingController replyMessageController;

  // Scroll controller for chat
  late final ScrollController chatScrollController;

  @override
  void onInit() {
    super.onInit();

    // ✅ Initialize all controllers in onInit() - called once per controller lifecycle
    subjectController = TextEditingController();
    createMessageController = TextEditingController();
    replyMessageController = TextEditingController();
    chatScrollController = ScrollController();

    // Check if we're in chat view by looking at arguments
    final args = Get.arguments as Map<String, dynamic>?;
    final ticketId = args?['ticketId']?.toString();

    // Only load tickets list if we're NOT in a chat view (no ticketId provided)
    if (ticketId == null || ticketId.isEmpty) {
      loadTickets();
    }
  }

  @override
  void onClose() {
    // ✅ Dispose all controllers in onClose() - called when controller is removed from memory
    // This is the ONLY place we should dispose controllers
    subjectController.dispose();
    createMessageController.dispose();
    replyMessageController.dispose();
    chatScrollController.dispose();
    super.onClose();
  }

  /// Load support ticket list
  Future<void> loadTickets() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _supportService.getSupportTickets();

      if (result.success && result.data != null) {
        tickets.value = result.data!;
      } else {
        errorMessage.value = result.message;
        if (!result.message.toLowerCase().contains('empty')) {
          AppSnackbar.error(result.message);
        }
      }
    } catch (e) {
      errorMessage.value = 'Failed to load support tickets';
      AppSnackbar.error('Failed to load support tickets: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load support ticket details with conversation
  Future<void> loadTicketDetails(String ticketId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _supportService.getSupportTicketDetails(ticketId);

      if (result.success && result.data != null) {
        selectedTicket.value = result.data;

        // Scroll to bottom after loading messages
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      } else {
        errorMessage.value = result.message;
        AppSnackbar.error(result.message);
      }
    } catch (e) {
      errorMessage.value = 'Failed to load ticket details';
      AppSnackbar.error('Failed to load ticket details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Submit new support ticket
  Future<bool> submitTicket({
    String? subject,
    String? message,
  }) async {
    try {
      // ✅ Read from controller-owned TextEditingControllers if not provided
      final ticketSubject = subject ?? subjectController.text.trim();
      final ticketMessage = message ?? createMessageController.text.trim();

      if (ticketSubject.isEmpty || ticketMessage.isEmpty) {
        AppSnackbar.warning('Please fill in both subject and message',
            title: 'Incomplete');
        return false;
      }

      isCreating.value = true;

      final result = await _supportService.submitSupportTicket(
        subject: ticketSubject,
        message: ticketMessage,
      );

      if (result.success) {
        AppSnackbar.success('Support ticket submitted successfully!');

        // ✅ Clear form - safe because controllers are owned by GetX controller
        clearCreateForm();

        // Refresh ticket list
        await loadTickets();

        return true;
      } else {
        AppSnackbar.error(result.message, title: 'Failed');
        return false;
      }
    } catch (e) {
      AppSnackbar.error('Failed to submit ticket: $e');
      return false;
    } finally {
      isCreating.value = false;
    }
  }

  /// Reply to ticket
  Future<bool> replyToTicket({
    required String ticketId,
    String? messageText,
  }) async {
    try {
      // ✅ Get message from controller-owned TextEditingController
      final message = messageText ?? replyMessageController.text.trim();

      if (message.isEmpty) {
        AppSnackbar.warning('Please enter a message', title: 'Empty Message');
        return false;
      }

      // Check if ticket is closed
      if (selectedTicket.value != null && !selectedTicket.value!.isOpen) {
        AppSnackbar.warning('Cannot reply to a closed ticket',
            title: 'Ticket Closed');
        return false;
      }

      isReplying.value = true;

      final result = await _supportService.replyToTicket(
        ticketId: ticketId,
        message: message,
      );

      if (result.success) {
        // ✅ Clear reply form - safe because controller is owned by GetX controller
        replyMessageController.clear();

        AppSnackbar.success('Reply sent successfully!');

        // Reload ticket details to get updated conversation
        await loadTicketDetails(ticketId);

        return true;
      } else {
        AppSnackbar.error(result.message, title: 'Failed');
        return false;
      }
    } catch (e) {
      AppSnackbar.error('Failed to send reply: $e');
      return false;
    } finally {
      isReplying.value = false;
    }
  }

  /// Close support ticket
  Future<bool> closeTicket(String ticketId) async {
    try {
      isClosing.value = true;

      final result = await _supportService.closeTicket(ticketId);

      if (result.success) {
        AppSnackbar.success('Ticket closed successfully');

        // Update selected ticket status
        if (selectedTicket.value != null) {
          selectedTicket.value = selectedTicket.value!.copyWith(
            isOpen: false,
            status: 'Closed',
          );
        }

        // Refresh ticket list
        await loadTickets();

        return true;
      } else {
        AppSnackbar.error(result.message, title: 'Failed');
        return false;
      }
    } catch (e) {
      AppSnackbar.error('Failed to close ticket: $e');
      return false;
    } finally {
      isClosing.value = false;
    }
  }

  /// ✅ Clear create ticket form
  void clearCreateForm() {
    subjectController.clear();
    createMessageController.clear();
  }

  /// Scroll chat to bottom
  void _scrollToBottom() {
    if (chatScrollController.hasClients) {
      chatScrollController.animateTo(
        chatScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// Refresh tickets
  Future<void> refreshTickets() async {
    await loadTickets();
  }

  /// Refresh current ticket details
  Future<void> refreshCurrentTicket() async {
    if (selectedTicket.value != null) {
      await loadTicketDetails(selectedTicket.value!.ticketId);
    }
  }

  /// Get open tickets count
  int get openTicketsCount {
    return tickets.where((ticket) => ticket.isOpen).length;
  }

  /// Get closed tickets count
  int get closedTicketsCount {
    return tickets.where((ticket) => !ticket.isOpen).length;
  }

  /// Check if can reply (ticket is open)
  bool get canReply {
    return selectedTicket.value != null && selectedTicket.value!.isOpen;
  }
}