import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:meatwaala_app/core/theme/app_colors.dart';
import 'package:meatwaala_app/modules/orders/controllers/order_controller.dart';
import 'package:meatwaala_app/data/models/order_detail_model.dart';

class OrderDetailsView extends GetView<OrderController> {
  const OrderDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get orderId from arguments
    final orderId = Get.arguments?['orderId'] as String?;

    if (orderId != null) {
      controller.loadOrderDetails(orderId);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final order = controller.selectedOrder.value;
        if (order == null) {
          return const Center(child: Text('Order not found'));
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _OrderHeader(order: order),
              const Divider(height: 1),
              _OrderItems(order: order),
              const Divider(height: 1),
              _DeliveryInfo(order: order),
              const Divider(height: 1),
              _PriceSummary(order: order),
              // if (order.statusTimeline.isNotEmpty) ...[
              //   const Divider(height: 1),
              //   _StatusTimeline(order: order),
              // ],
              // const SizedBox(height: 16),
            ],
          ),
        );
      }),
    );
  }
}

class _OrderHeader extends StatelessWidget {
  final OrderDetailModel order;

  const _OrderHeader({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.primary.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order No. ${order.orderNumber}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatusChip(
                label: order.orderStatus,
                color: _getStatusColor(order.orderStatus),
              ),
              const SizedBox(width: 8),
              _StatusChip(
                label: order.paymentStatus,
                color: _getPaymentStatusColor(order.paymentStatus),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'processing':
      case 'confirmed':
        return Colors.blue;
      case 'shipped':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'success':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return AppColors.textSecondary;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _OrderItems extends StatelessWidget {
  final OrderDetailModel order;

  const _OrderItems({required this.order});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Items',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...order.items.map((item) => _OrderItemCard(item: item)),
        ],
      ),
    );
  }
}

class _OrderItemCard extends StatelessWidget {
  final OrderItemModel item;

  const _OrderItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrderController>();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: item.productImage,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.border,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.border,
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.weight,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '₹${item.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Qty: ${item.quantity}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${item.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            // Review Section (if order is delivered and not reviewed)
            if (controller.canReviewItem(item)) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              _ReviewSection(item: item),
            ] else if (item.isReviewed) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.check_circle, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  const Text(
                    'Reviewed',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReviewSection extends StatefulWidget {
  final OrderItemModel item;

  const _ReviewSection({required this.item});

  @override
  State<_ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<_ReviewSection> {
  int rating = 5;
  final titleController = TextEditingController();
  final reviewController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrderController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Write a Review',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (index) {
            return IconButton(
              onPressed: () => setState(() => rating = index + 1),
              icon: Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 28,
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Review Title',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: reviewController,
          decoration: const InputDecoration(
            labelText: 'Your Review',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 12),
        Obx(() => ElevatedButton(
              onPressed: controller.isReviewSubmitting.value
                  ? null
                  : () async {
                      final success = await controller.submitReview(
                        orderItemId: widget.item.orderItemId,
                        rating: rating,
                        reviewTitle: titleController.text,
                        review: reviewController.text,
                      );
                      if (success) {
                        titleController.clear();
                        reviewController.clear();
                      }
                    },
              child: controller.isReviewSubmitting.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit Review'),
            )),
      ],
    );
  }
}

class _DeliveryInfo extends StatelessWidget {
  final OrderDetailModel order;

  const _DeliveryInfo({required this.order});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _InfoRow(label: 'Name', value: order.customerName),
          _InfoRow(label: 'Mobile', value: order.customerMobile),
          _InfoRow(label: 'Email', value: order.customerEmail),
          _InfoRow(
            label: 'Address',
            value:
                '${order.addressLine1}\n${order.addressLine2}${order.addressLine3 != null ? '\n${order.addressLine3}' : ''}',
          ),
          _InfoRow(label: 'Area', value: order.areaName),
          if (order.pincode != null)
            _InfoRow(label: 'Pincode', value: order.pincode!),
          if (order.remarks != null && order.remarks!.isNotEmpty)
            _InfoRow(label: 'Remarks', value: order.remarks!),
        ],
      ),
    );
  }
}

class _PriceSummary extends StatelessWidget {
  final OrderDetailModel order;

  const _PriceSummary({required this.order});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Price Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _PriceRow(label: 'Subtotal', value: order.subtotal),
          _PriceRow(label: 'Shipping Charge', value: order.shippingCharge),
          if (order.discount > 0)
            _PriceRow(label: 'Discount', value: -order.discount),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₹${order.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final OrderDetailModel order;

  const _StatusTimeline({required this.order});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Timeline',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...order.statusTimeline
              .map((status) => _TimelineItem(status: status)),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final OrderStatusModel status;

  const _TimelineItem({required this.status});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: status.isActive ? AppColors.primary : AppColors.border,
                ),
              ),
              if (status != status)
                Container(
                  width: 2,
                  height: 30,
                  color: AppColors.border,
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.statusLabel,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        status.isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status.timestamp,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (status.remarks != null && status.remarks!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    status.remarks!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double value;

  const _PriceRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            '₹${value.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: value < 0 ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }
}
