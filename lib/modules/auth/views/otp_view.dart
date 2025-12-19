import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meatwaala_app/core/constants/app_constants.dart';
import 'package:meatwaala_app/core/theme/app_colors.dart';
import 'package:meatwaala_app/core/widgets/custom_button.dart';
import 'package:meatwaala_app/modules/auth/controllers/auth_controller.dart';

class OtpView extends GetView<AuthController> {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Title
              Text(
                'Enter OTP',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 8),
              Obx(() => Text(
                    'We have sent a ${AppConstants.otpLength}-digit code to ${controller.isPhoneLogin.value ? controller.phoneController.text : controller.emailController.text}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  )),

              const SizedBox(height: 48),

              // OTP Input
              TextField(
                controller: controller.otpController,
                keyboardType: TextInputType.number,
                maxLength: AppConstants.otpLength,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall,
                decoration: InputDecoration(
                  hintText: '000000',
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Resend OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive code? ",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      Get.snackbar(
                        'OTP Sent',
                        'A new OTP has been sent',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    child: const Text('Resend'),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Verify Button
              Obx(() => CustomButton(
                    text: 'Verify',
                    onPressed: controller.verifyOtp,
                    isLoading: controller.isLoading.value,
                    width: double.infinity,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
