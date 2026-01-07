import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meatwaala_app/services/storage_service.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:meatwaala_app/modules/profile/model/user_model.dart';
import 'package:meatwaala_app/modules/profile/profile_service.dart';
import 'package:meatwaala_app/modules/checkout/checkout_service.dart';
import 'package:meatwaala_app/routes/app_routes.dart';

class CheckoutController extends GetxController {
  // Using CustomerProfileModel instead of AddressModel
  final selectedProfile = Rxn<CustomerProfileModel>();
  final selectedPaymentMethod = 'razorpay'.obs;
  final isLoading = false.obs;
  final remarksController = TextEditingController();

  // Price breakdown (Replace with actual cart data)
  final subtotal = 780.0.obs;
  final deliveryFee = 40.0.obs;
  final discount = 50.0.obs;
  final totalAmount = 770.0.obs;

  final paymentMethods = [
    {'title': 'Credit/Debit Card', 'icon': 'credit_card', 'value': 'razorpay'},
    {
      'title': 'UPI (Google Pay, PhonePe, Paytm)',
      'icon': 'account_balance_wallet',
      'value': 'upi'
    },
    {'title': 'Cash on Delivery', 'icon': 'money', 'value': 'cod'},
  ];

  // Services
  final ProfileService _profileService = ProfileService();
  final OrderService _orderService = OrderService();
  final StorageService _storage = StorageService();

  // Razorpay
  late Razorpay _razorpay;
  String? _paymentId;

  @override
  void onInit() {
    super.onInit();
    _initializeRazorpay();
    loadUserProfile();
    calculateTotal();
  }

  @override
  void onClose() {
    _razorpay.clear();
    remarksController.dispose();
    super.onClose();
  }

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    log('✅ Payment Success: ${response.paymentId}');
    _paymentId = response.paymentId;
    Get.snackbar(
      'Success',
      'Payment successful!',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
    // Submit order after payment success
    submitOrder();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    log('❌ Payment Error: ${response.code} - ${response.message}');
    isLoading.value = false;
    Get.snackbar(
      'Payment Failed',
      response.message ?? 'Payment was unsuccessful',
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    log('💳 External Wallet: ${response.walletName}');
    Get.snackbar(
      'External Wallet',
      'Selected wallet: ${response.walletName}',
      snackPosition: SnackPosition.TOP,
    );
  }

  /// Load user profile from API using CustomerProfileModel
  Future<void> loadUserProfile() async {
    try {
      final customerId = _storage.getUserId();
      if (customerId == null || customerId.isEmpty) {
        log('❌ No customer ID found');
        return;
      }

      final profile = await _profileService.fetchProfile(customerId);
      if (profile != null) {
        selectedProfile.value = profile;
        log('✅ Profile loaded: ${profile.name}');
      }
    } catch (e) {
      log('❌ Error loading user profile: $e');
    }
  }

  void calculateTotal() {
    totalAmount.value = subtotal.value + deliveryFee.value - discount.value;
  }

  void selectPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  /// Navigate to edit profile screen
  void editProfile() {
    Get.toNamed(AppRoutes.editProfile)?.then((value) {
      if (value != null) {
        // Reload profile after edit
        loadUserProfile();
      }
    });
  }

  /// Navigate to add address (profile edit with focus on address)
  void addAddress() {
    Get.toNamed(AppRoutes.editProfile, arguments: {'focus': 'address'})
        ?.then((value) {
      if (value != null) {
        loadUserProfile();
      }
    });
  }

  /// Check if profile has all mandatory fields for order
  bool isProfileComplete() {
    final profile = selectedProfile.value;
    if (profile == null) return false;

    return profile.name.isNotEmpty &&
        profile.mobile.isNotEmpty &&
        profile.emailId.isNotEmpty &&
        profile.addressLine1.isNotEmpty &&
        profile.addressLine2.isNotEmpty &&
        profile.areaId.isNotEmpty;
  }

  /// Get list of missing mandatory fields
  List<String> getMissingFields() {
    final profile = selectedProfile.value;
    if (profile == null) return ['Profile data'];

    final missing = <String>[];
    if (profile.name.isEmpty) missing.add('Name');
    if (profile.mobile.isEmpty) missing.add('Mobile');
    if (profile.emailId.isEmpty) missing.add('Email');
    if (profile.addressLine1.isEmpty) missing.add('Address Line 1');
    if (profile.addressLine2.isEmpty) missing.add('Address Line 2');
    if (profile.areaId.isEmpty) missing.add('Area');

    return missing;
  }

  Future<void> placeOrder() async {
    // Validate profile exists
    if (selectedProfile.value == null) {
      Get.snackbar(
        'Error',
        'Please complete your profile information',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    // Validate all required fields are filled
    if (!isProfileComplete()) {
      final missingFields = getMissingFields();
      Get.snackbar(
        'Incomplete Profile',
        'Please complete: ${missingFields.join(", ")}',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    isLoading.value = true;

    // Check payment method and proceed accordingly
    if (selectedPaymentMethod.value == 'cod') {
      // For COD, submit order directly
      _paymentId = 'COD_${DateTime.now().millisecondsSinceEpoch}';
      await submitOrder();
    } else if (selectedPaymentMethod.value == 'upi') {
      // For UPI, open Razorpay with UPI method
      _openRazorpayCheckout(method: 'upi');
    } else {
      // For online payment (card/razorpay), open Razorpay
      _openRazorpayCheckout();
    }
  }

  void _openRazorpayCheckout({String? method}) {
    print('🚀 Starting Razorpay Checkout');

    final profile = selectedProfile.value!;
    print('👤 User Profile Loaded');
    print('📱 Mobile: ${profile.mobile}');
    print('📧 Email: ${profile.emailId}');

    final int amountInPaise = (totalAmount.value * 100).toInt();
    print('💰 Total Amount: ₹${totalAmount.value}');
    print('💰 Amount in Paise: $amountInPaise');

    var options = {
      'key': 'rzp_test_qa2h4SJvzwEbhw', // Replace with your actual Razorpay key
      'amount': amountInPaise,
      'name': 'Meat Waala',
      'description': 'Order Payment',
      'prefill': {
        'contact': profile.mobile,
        'email': profile.emailId,
      },
      'theme': {
        'color': '#D32F2F',
      },
    };

    print('⚙️ Razorpay Base Options Initialized');

    // Add method preference for UPI
    if (method == 'upi') {
      options['method'] = 'upi';
      print('📲 Payment Method Selected: UPI');
    } else {
      print('💳 Payment Method Selected: Default');
    }

    print('🧾 Final Razorpay Options: $options');

    try {
      print('🟢 Opening Razorpay Payment Gateway...');
      _razorpay.open(options);
      print('✅ Razorpay Opened Successfully');
    } catch (e) {
      log('❌ Razorpay Error: $e');
      print('🔥 Exception While Opening Razorpay');

      isLoading.value = false;

      Get.snackbar(
        'Error',
        'Failed to open payment gateway',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  /// Submit order to API using CustomerProfileModel data
  Future<void> submitOrder() async {
    try {
      final customerId = _storage.getUserId();
      if (customerId == null || customerId.isEmpty) {
        throw Exception('Customer ID not found');
      }

      final profile = selectedProfile.value!;

      // Prepare order data with all mandatory fields from CustomerProfileModel
      final orderData = {
        // Mandatory fields
        'name': profile.name,
        'mobile': profile.mobile,
        'email_id': profile.emailId,
        'address_line1': profile.addressLine1,
        'address_line2': profile.addressLine2,
        'area_id': profile.areaId,
        'payment_id': _paymentId ?? '',
        'remarks': remarksController.text.trim(),

        // Additional fields from profile
        'landmark': profile.landmark,
        'city': profile.city,
        'state': profile.state,
        'pincode': profile.pincode,
        'country': profile.country,

        // Order details
        'payment_method': selectedPaymentMethod.value,
        'subtotal': subtotal.value.toString(),
        'delivery_fee': deliveryFee.value.toString(),
        'discount': discount.value.toString(),
        'total_amount': totalAmount.value.toString(),
      };

      log('📦 Submitting order with data: $orderData');

      final orderId = await _orderService.submitOrder(customerId, orderData);

      isLoading.value = false;

      // Navigate to order success
      Get.offAllNamed(AppRoutes.orderSuccess, arguments: {
        'orderId': orderId,
        'amount': totalAmount.value,
      });

      // Clear remarks after successful order
      remarksController.clear();

      log('✅ Order placed successfully: $orderId');
    } catch (e) {
      log('❌ Error submitting order: $e');
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Failed to place order: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
    }
  }
}
