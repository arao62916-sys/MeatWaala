import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

            // ✅ Subject Field - Uses controller-owned TextEditingController
            // NO controller created in build() - prevents "used after disposed" error
            TextField(
              controller: controller.subjectController,
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

            // ✅ Message Field - Uses controller-owned TextEditingController
            // NO controller created in build() - prevents "used after disposed" error
            TextField(
              controller: controller.createMessageController,
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
                      : () => _submitTicket(context),
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
  }

  /// ✅ Submit ticket - NO manual disposal of controllers
  /// Controllers are managed by GetX controller lifecycle
  /// This prevents "used after being disposed" errors
  Future<void> _submitTicket(BuildContext context) async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    // ✅ Controller reads text from its own TextEditingControllers
    // and handles validation internally
    final success = await controller.submitTicket();

    if (success) {
      // ✅ SAFE: Controllers are cleared (not disposed) by the controller
      // Navigation doesn't cause disposal errors
      Get.back();
    }
    // ❌ DO NOT: subjectController.dispose() - causes crashes
    // ❌ DO NOT: messageController.dispose() - causes crashes
  }
}

// ============================================================================
// 📝 EXPLANATION OF THE FIX
// ============================================================================
/*

❌ ORIGINAL CODE (BROKEN):
--------------------------
Widget build(BuildContext context) {
  final subjectController = TextEditingController();  // ❌ Created in build()
  final messageController = TextEditingController();  // ❌ Created in build()
  
  // Problems:
  // 1. New controllers created on every rebuild
  // 2. Old controllers not disposed (memory leak)
  // 3. Manual disposal after submit causes "used after disposed" error
  
  return TextField(controller: subjectController);  // ❌ Uses local variable
}

void _submitTicket(...) {
  await controller.submitTicket(...);
  subjectController.dispose();  // ❌ Disposes immediately
  messageController.dispose();  // ❌ Disposes immediately
  Get.back();  // ❌ Navigation after disposal - CRASH if widget rebuilds
}


✅ FIXED CODE (WORKING):
------------------------
Widget build(BuildContext context) {
  // ✅ NO controllers created here
  
  return TextField(
    controller: controller.subjectController,  // ✅ Uses controller-owned instance
  );
}

void _submitTicket(...) {
  await controller.submitTicket();  // ✅ Controller handles text reading
  Get.back();  // ✅ Safe - controllers still alive, just cleared
  // ✅ NO manual disposal - handled by GetX controller's onClose()
}


WHY THIS WORKS:
--------------
1. Controllers live in SupportController (GetX managed)
2. Created once in onInit()
3. Survive screen navigation and rebuilds
4. Only disposed in onClose() when controller is truly done
5. Navigation with Get.back() is completely safe

LIFECYCLE:
----------
App Start → onInit() → Controllers Created
  ↓
User Opens Create Screen → Uses existing controllers
  ↓
User Submits → Controllers cleared (NOT disposed)
  ↓
Navigate Back → Controllers still alive
  ↓
User Opens Again → Same controllers, empty text
  ↓
App Closes / Controller Removed → onClose() → Dispose controllers

*/