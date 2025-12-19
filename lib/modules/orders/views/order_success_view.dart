import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meatwaala_app/core/theme/app_colors.dart';
import 'package:meatwaala_app/core/widgets/custom_button.dart';
import 'package:meatwaala_app/modules/orders/controllers/order_success_controller.dart';

class OrderSuccessView extends GetView<OrderSuccessController> {
  const OrderSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 80,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 32),

              // Success Message
              Text(
                'Order Placed Successfully!',
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Order ID
              Obx(() => Text(
                    'Order ID: ${controller.orderId.value}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  )),
              const SizedBox(height: 8),

              Text(
                'Your order will be delivered soon',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Buttons
              CustomButton(
                text: 'View Orders',
                onPressed: controller.viewOrders,
                width: double.infinity,
                icon: Icons.receipt_long,
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Continue Shopping',
                onPressed: controller.continueShopping,
                width: double.infinity,
                isOutlined: true,
                icon: Icons.shopping_bag,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
