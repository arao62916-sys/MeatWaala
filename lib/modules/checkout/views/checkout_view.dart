import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meatwaala_app/core/theme/app_colors.dart';
import 'package:meatwaala_app/core/widgets/custom_button.dart';
import 'package:meatwaala_app/data/models/address_model.dart';
import 'package:meatwaala_app/modules/checkout/controllers/checkout_controller.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Delivery Address Section
                  Text(
                    'Delivery Address',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Obx(() => Column(
                        children: controller.addresses.map((address) {
                          return RadioListTile<AddressModel>(
                            value: address,
                            groupValue: controller.selectedAddress.value,
                            onChanged: (value) {
                              if (value != null) {
                                controller.selectAddress(value);
                              }
                            },
                            title: Text(address.title),
                            subtitle: Text(address.fullAddress),
                            activeColor: AppColors.primary,
                          );
                        }).toList(),
                      )),
                  const SizedBox(height: 24),

                  // Delivery Time Slot
                  Text(
                    'Delivery Time Slot',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Obx(() => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: controller.timeSlots.map((slot) {
                          return ChoiceChip(
                            label: Text(slot),
                            selected: controller.selectedTimeSlot.value == slot,
                            onSelected: (selected) {
                              if (selected) {
                                controller.selectTimeSlot(slot);
                              }
                            },
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: controller.selectedTimeSlot.value == slot
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontSize: 12,
                            ),
                          );
                        }).toList(),
                      )),
                  const SizedBox(height: 24),

                  // Payment Method
                  Text(
                    'Payment Method',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Obx(() => Column(
                        children: controller.paymentMethods.map((method) {
                          return RadioListTile<String>(
                            value: method,
                            groupValue: controller.selectedPaymentMethod.value,
                            onChanged: (value) {
                              if (value != null) {
                                controller.selectPaymentMethod(value);
                              }
                            },
                            title: Text(method),
                            activeColor: AppColors.primary,
                          );
                        }).toList(),
                      )),
                ],
              ),
            ),
          ),

          // Place Order Button
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Obx(() => CustomButton(
                  text: 'Place Order',
                  onPressed: controller.placeOrder,
                  isLoading: controller.isLoading.value,
                  width: double.infinity,
                  icon: Icons.check_circle,
                )),
          ),
        ],
      ),
    );
  }
}
