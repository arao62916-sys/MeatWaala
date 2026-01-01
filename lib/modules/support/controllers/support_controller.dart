import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  // Chat-related state
  final messages = <TicketMessageModel>[].obs;
  final Rxn<File> selectedFile = Rxn<File>();
  final RxString selectedFileName = ''.obs;

  // Text controllers for forms
  final TextEditingController messageController = TextEditingController();
  final ScrollController chatScrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    loadTickets();
  }

  @override
  void onClose() {
    messageController.dispose();
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
          Get.snackbar(
            'Error',
            result.message,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      errorMessage.value = 'Failed to load support tickets';
      Get.snackbar(
        'Error',
        'Failed to load support tickets: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
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
        messages.value = result.data!.conversation;

        // Scroll to bottom after loading messages
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      } else {
        errorMessage.value = result.message;
        Get.snackbar(
          'Error',
          result.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      errorMessage.value = 'Failed to load ticket details';
      Get.snackbar(
        'Error',
        'Failed to load ticket details: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Submit new support ticket with optional file
  Future<bool> submitTicket({
    required String subject,
    required String message,
    File? file,
  }) async {
    try {
      if (subject.trim().isEmpty || message.trim().isEmpty) {
        Get.snackbar(
          'Incomplete',
          'Please fill in both subject and message',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      isCreating.value = true;

      final result = await _supportService.submitSupportTicket(
        subject: subject,
        message: message,
        file: file,
      );

      if (result.success) {
        Get.snackbar(
          'Success',
          'Support ticket submitted successfully!',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );

        // Clear selected file
        clearSelectedFile();

        // Refresh ticket list
        await loadTickets();

        return true;
      } else {
        Get.snackbar(
          'Failed',
          result.message,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit ticket: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isCreating.value = false;
    }
  }

  /// Reply to ticket with optional file
  Future<bool> replyToTicket({
    required String ticketId,
    String? messageText,
    File? file,
  }) async {
    try {
      // Get message from controller if not provided
      final message = messageText ?? messageController.text.trim();

      if (message.isEmpty) {
        Get.snackbar(
          'Empty Message',
          'Please enter a message',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      // Check if ticket is closed
      if (selectedTicket.value != null && !selectedTicket.value!.isOpen) {
        Get.snackbar(
          'Ticket Closed',
          'Cannot reply to a closed ticket',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      isReplying.value = true;

      final result = await _supportService.replyToTicket(
        ticketId: ticketId,
        message: message,
        file: file ?? selectedFile.value,
      );

      if (result.success) {
        // Clear message and file
        messageController.clear();
        clearSelectedFile();

        Get.snackbar(
          'Success',
          'Reply sent successfully!',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 1),
        );

        // Reload ticket details to get updated conversation
        await loadTicketDetails(ticketId);

        return true;
      } else {
        Get.snackbar(
          'Failed',
          result.message,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send reply: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
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
        Get.snackbar(
          'Success',
          'Ticket closed successfully',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );

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
        Get.snackbar(
          'Failed',
          result.message,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to close ticket: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isClosing.value = false;
    }
  }

  /// Select file for upload
  void selectFile(File file) {
    selectedFile.value = file;
    selectedFileName.value = file.path.split('/').last;
  }

  /// Clear selected file
  void clearSelectedFile() {
    selectedFile.value = null;
    selectedFileName.value = '';
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

  /// Create new support ticket (legacy - without file)
  @Deprecated('Use submitTicket instead')
  Future<bool> createTicket({
    required String subject,
    required String message,
  }) async {
    return submitTicket(subject: subject, message: message);
  }
}
