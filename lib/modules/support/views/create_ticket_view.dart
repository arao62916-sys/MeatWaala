import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meatwaala_app/core/theme/app_colors.dart';
import 'package:meatwaala_app/modules/support/controllers/support_controller.dart';

class CreateTicketView extends GetView<SupportController> {
  const CreateTicketView({super.key});

  @override
  Widget build(BuildContext context) {
    final subjectController = TextEditingController();
    final messageController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Support Ticket'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Describe your issue in detail. You can attach an image or file.',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Subject Field
            TextField(
              controller: subjectController,
              decoration: InputDecoration(
                labelText: 'Subject *',
                hintText: 'Brief description of your issue',
                prefixIcon: const Icon(Icons.subject),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 16),

            // Message Field
            TextField(
              controller: messageController,
              decoration: InputDecoration(
                labelText: 'Message *',
                hintText: 'Explain your issue in detail',
                prefixIcon: const Icon(Icons.message),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 16),

            // File Attachment Section
            Obx(() {
              final hasFile = controller.selectedFile.value != null;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // File Picker Button
                  OutlinedButton.icon(
                    onPressed: () => _pickFile(context),
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Attach File (Optional)'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  // Selected File Display
                  if (hasFile) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              controller.selectedFileName.value,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: controller.clearSelectedFile,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            }),

            const SizedBox(height: 24),

            // Submit Button
            Obx(() => ElevatedButton(
                  onPressed: controller.isCreating.value
                      ? null
                      : () => _submitTicket(
                            context,
                            subjectController,
                            messageController,
                          ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: controller.isCreating.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Submit Ticket',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                )),

            const SizedBox(height: 16),

            // Help Text
            Text(
              '* Required fields',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile(BuildContext context) async {
    // TODO: Install file_picker package
    // Add to pubspec.yaml: file_picker: ^6.0.0
    Get.snackbar(
      'Feature Unavailable',
      'File picker package not installed. Add file_picker to pubspec.yaml',
      snackPosition: SnackPosition.BOTTOM,
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
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    */
  }

  Future<void> _submitTicket(
    BuildContext context,
    TextEditingController subjectController,
    TextEditingController messageController,
  ) async {
    final subject = subjectController.text.trim();
    final message = messageController.text.trim();

    if (subject.isEmpty || message.isEmpty) {
      Get.snackbar(
        'Incomplete',
        'Please fill in all required fields',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final success = await controller.submitTicket(
      subject: subject,
      message: message,
      file: controller.selectedFile.value,
    );

    if (success) {
      // Clean up and navigate back
      subjectController.dispose();
      messageController.dispose();
      Get.back();
    }
  }
}
