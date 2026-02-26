import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meatwaala_app/core/services/app_snackbar.dart';
import 'package:meatwaala_app/core/theme/app_colors.dart';
import 'package:meatwaala_app/modules/support/controllers/support_controller.dart';

class CreateTicketView extends GetView<SupportController> {
  const CreateTicketView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Support Ticket'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Describe your issue clearly.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// Subject
            TextField(
              controller: controller.subjectController,
              decoration: InputDecoration(
                labelText: 'Subject *',
                prefixIcon: const Icon(Icons.subject),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// Message
            TextField(
              controller: controller.createMessageController,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: 'Message *',
                prefixIcon: const Icon(Icons.message),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// Submit Button
            Obx(
              () => ElevatedButton(
                onPressed: controller.isCreating.value
                    ? null
                    : () => _submit(context),
                child: controller.isCreating.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit Ticket'),
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              '* Required fields',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final success = await controller.submitTicket();
    if (success) {
      Get.back();
    }
  }
}