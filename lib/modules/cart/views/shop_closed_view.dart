import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meatwaala_app/core/theme/app_colors.dart';
import 'package:meatwaala_app/core/widgets/custom_button.dart';

class ShopClosedView extends StatelessWidget {
  const ShopClosedView({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments as Map<String, dynamic>? ?? {};
    final message = arguments['message'] as String? ??
        'Sorry, we are currently closed. Please check back later.';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Status'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Shop Closed Image
              Image.asset(
                'assets/images/meat_wala_store_closed.png',
                height: 350,
                fit: BoxFit.fill,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.store_mall_directory_outlined,
                    size: 150,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  );
                },
              ),

              const SizedBox(height: 10),

              // Title
              Text(
                'We\'re Currently Closed',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Message from API
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 40),

              // Back to Home Button
              CustomButton(
                text: 'Back to Home',
                onPressed: () {
                  // Go back to home, clearing the navigation stack
                  Get.until((route) => route.isFirst);
                },
                width: double.infinity,
              ),

              const SizedBox(height: 12),

              // Back Button
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  'Go Back',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
