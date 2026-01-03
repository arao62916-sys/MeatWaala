import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meatwaala_app/core/theme/app_colors.dart';
import 'package:meatwaala_app/core/widgets/custom_button.dart';
import 'package:meatwaala_app/modules/checkout/controllers/checkout_controller.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
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
                  _buildSectionTitle(context, 'Delivery Address'),
                  const SizedBox(height: 12),
                  Obx(() => controller.selectedProfile.value != null
                      ? _buildProfileCard(context)
                      : _buildNoProfileCard(context)),
                  const SizedBox(height: 12),
                  
                  // Add/Edit Address Button
                  Obx(() {
                    final hasAddress = controller.selectedProfile.value?.addressLine1.isNotEmpty ?? false;
                    return OutlinedButton(
                      onPressed: hasAddress ? controller.editProfile : controller.addAddress,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primary),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: Text(
                        hasAddress ? 'Edit Profile & Address' : 'Add Address',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),

                  // Payment Method Section
                  _buildSectionTitle(context, 'Payment Method'),
                  const SizedBox(height: 12),
                  Column(
                        children: controller.paymentMethods.map((method) {
                          return _buildPaymentOption(
                            context,
                            method['title']!,
                            method['icon']!,
                            method['value']!,
                          );
                        }).toList(),
                      ),
                  const SizedBox(height: 24),

                  // Order Notes Section
                  _buildSectionTitle(context, 'Order Notes'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller.remarksController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Add any special instructions or delivery preferences here...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Price Breakdown Section
                  _buildSectionTitle(context, 'Price Breakdown'),
                  const SizedBox(height: 12),
                  Obx(() => _buildPriceBreakdown(context)),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // Place Order Button at Bottom
          _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final profile = controller.selectedProfile.value!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  profile.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                profile.mobile,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (profile.fullAddress.isNotEmpty)
                  Text(
                    profile.fullAddress,
                    style: TextStyle(color: Colors.grey[700], height: 1.4),
                  ),
                if (profile.fullAddress.isEmpty)
                  Text(
                    'No address provided',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                if (profile.emailId.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    profile.emailId,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // Show missing fields warning if any
          Obx(() {
            final missingFields = controller.getMissingFields();
            if (missingFields.isNotEmpty) {
              return Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, 
                      color: Colors.orange[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Missing: ${missingFields.join(", ")}',
                        style: TextStyle(
                          color: Colors.orange[900],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: controller.editProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoProfileCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.person_outline, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'No profile information found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Please complete your profile to continue',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
    BuildContext context,
    String title,
    String iconName,
    String value,
  ) {
    IconData icon;
    switch (iconName) {
      case 'credit_card':
        icon = Icons.credit_card;
        break;
      case 'account_balance_wallet':
        icon = Icons.account_balance_wallet;
        break;
      case 'money':
        icon = Icons.money;
        break;
      default:
        icon = Icons.payment;
    }

    return Obx(() => Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: controller.selectedPaymentMethod.value == value
                  ? AppColors.primary
                  : Colors.grey[300]!,
              width: controller.selectedPaymentMethod.value == value ? 2 : 1,
            ),
          ),
          child: RadioListTile<String>(
            value: value,
            groupValue: controller.selectedPaymentMethod.value,
            onChanged: (val) {
              if (val != null) {
                controller.selectPaymentMethod(val);
              }
            },
            title: Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 12),
                Text(title),
              ],
            ),
            activeColor: AppColors.primary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          ),
        ));
  }

  Widget _buildPriceBreakdown(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildPriceRow('Subtotal', '₹${controller.subtotal.value.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildPriceRow('Delivery Fee', '₹${controller.deliveryFee.value.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildPriceRow(
            'Discount',
            '-₹${controller.discount.value.toStringAsFixed(2)}',
            valueColor: Colors.green,
          ),
          const Divider(height: 24),
          _buildPriceRow(
            'Total Amount',
            '₹${controller.totalAmount.value.toStringAsFixed(2)}',
            isBold: true,
            valueColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value,
      {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
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
            onPressed: controller.isLoading.value ? null : controller.placeOrder,
            isLoading: controller.isLoading.value,
            width: double.infinity,
            icon: Icons.check_circle,
          )),
    );
  }
}