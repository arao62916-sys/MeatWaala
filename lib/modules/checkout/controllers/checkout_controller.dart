import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meatwaala_app/core/network/network_constents.dart';
import 'package:meatwaala_app/core/services/app_snackbar.dart';
import 'package:meatwaala_app/services/storage_service.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:meatwaala_app/modules/profile/model/user_model.dart';
import 'package:meatwaala_app/modules/profile/profile_service.dart';
import 'package:meatwaala_app/modules/checkout/checkout_service.dart';
import 'package:meatwaala_app/data/models/area_model.dart';
import 'package:meatwaala_app/data/services/area_api_service.dart';
import 'package:meatwaala_app/routes/app_routes.dart';

class CheckoutController extends GetxController {
  // Using CustomerProfileModel instead of AddressModel
  final selectedProfile = Rxn<CustomerProfileModel>();
  final selectedPaymentMethod = 'razorpay'.obs;
  final isLoading = false.obs;
  final isProfileLoading = true.obs;
  final remarksController = TextEditingController();

  // Price breakdown (from cart)
  final subtotal = 0.0.obs;
  final deliveryFee = 0.0.obs;
  final discount = 0.0.obs;
  final totalAmount = 0.0.obs;
  final codFromCart = false.obs;

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
  final AreaApiService _areaService = AreaApiService();

  // Area info
  final Rx<AreaModel?> selectedArea = Rx<AreaModel?>(null);
  final RxString areaName = ''.obs;

  // Razorpay
  late Razorpay _razorpay;
  String? _paymentId;
  String? _paymentOrderId;

  @override
  void onInit() {
    super.onInit();
    _initializeRazorpay();
    loadAreaInfo();
    loadUserProfile();
    _loadCartData();
  }

  /// Load area information from storage and fetch area details
  Future<void> loadAreaInfo() async {
    try {
      final areaId = _storage.getSelectedAreaId();
      areaName.value = _storage.getSelectedAreaName() ?? '';

      if (areaId != null && areaId.isNotEmpty) {
        log('🌍 CheckoutController: Loading area info for area ID: $areaId');
        final result = await _areaService.getAreaInfo(areaId);

        if (result.success && result.data != null) {
          selectedArea.value = result.data;
          // Update delivery fee from area charge
          deliveryFee.value = result.data!.deliveryCharge;
          calculateTotal();
          log('✅ CheckoutController: Area loaded - ${result.data!.name}, Delivery: ₹${result.data!.charge}');
        } else {
          log('⚠️ CheckoutController: Failed to load area info: ${result.message}');
        }
      }
    } catch (e) {
      log('❌ CheckoutController: Error loading area info: $e');
    }
  }

  /// Load cart data from navigation arguments
  void _loadCartData() {
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      subtotal.value = args['subtotal'] ?? 0.0;
      deliveryFee.value = args['deliveryFee'] ?? 0.0;
      discount.value = args['discount'] ?? 0.0;
      totalAmount.value = args['total'] ?? 0.0;
      final bool isCod = args['cod'] == true;
      if (isCod) {
        codFromCart.value = true;
        selectedPaymentMethod.value = 'cod';
      }
      log('✅ Cart data loaded: Subtotal=₹${subtotal.value}, Delivery=₹${deliveryFee.value}, Total=₹${totalAmount.value}, COD=$isCod');
    } else {
      log('⚠️ No cart data received, using default values');
      calculateTotal();
    }
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
    log('📦 Razorpay Order ID: ${response.orderId}');
    _paymentId = response.paymentId;
    // Use Razorpay's orderId if available, otherwise use pre-generated order ID
    if (response.orderId != null && response.orderId!.isNotEmpty) {
      _paymentOrderId = response.orderId;
    }
    log('📦 Using Payment Order ID: $_paymentOrderId');
    AppSnackbar.success('Payment successful!');
    // Submit order after payment success
    submitOrder();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    log('❌ Payment Error: ${response.code} - ${response.message}');
    isLoading.value = false;
    AppSnackbar.error(
      response.message ?? 'Payment was unsuccessful',
      title: 'Payment Failed',
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    log('💳 External Wallet: ${response.walletName}');
    AppSnackbar.info('Selected wallet: ${response.walletName}',
        title: 'External Wallet');
  }

  /// Load user profile from API using CustomerProfileModel
  Future<void> loadUserProfile() async {
    try {
      isProfileLoading.value = true;

      final customerId = _storage.getUserId();
      if (customerId == null || customerId.isEmpty) {
        log('❌ No customer ID found');
        isProfileLoading.value = false;
        return;
      }

      final profile = await _profileService.fetchProfile(customerId);
      if (profile != null) {
        selectedProfile.value = profile;
        log('✅ Profile loaded: ${profile.name}');
      }
    } catch (e) {
      log('❌ Error loading user profile: $e');
    } finally {
      isProfileLoading.value = false;
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
    Get.toNamed(AppRoutes.editProfile, arguments: {'returnTo': 'cart'});
    // No need for .then() as profile controller will handle navigation to cart
  }

  /// Navigate to add address (profile edit with focus on address)
  void addAddress() {
    Get.toNamed(AppRoutes.editProfile,
        arguments: {'focus': 'address', 'returnTo': 'cart'});
    // No need for .then() as profile controller will handle navigation to cart
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
      AppSnackbar.error('Please complete your profile information');
      return;
    }

    // Validate all required fields are filled
    if (!isProfileComplete()) {
      final missingFields = getMissingFields();
      AppSnackbar.warning(
        'Please complete: ${missingFields.join(", ")}',
        title: 'Incomplete Profile',
      );
      return;
    }

    isLoading.value = true;

    // Check payment method and proceed accordingly
    if (selectedPaymentMethod.value == 'cod') {
      // For COD, submit order directly with no payment IDs
      _paymentId = null;
      _paymentOrderId = null;
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

    // Generate unique order reference ID
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final customerId = _storage.getUserId() ?? 'GUEST';
    _paymentOrderId = 'ORD_${customerId}_$timestamp';
    log('📦 Generated Order Reference ID: $_paymentOrderId');

    final profile = selectedProfile.value!;
    print('👤 User Profile Loaded');
    print('📱 Mobile: ${profile.mobile}');
    print('📧 Email: ${profile.emailId}');

    final int amountInPaise = (totalAmount.value * 100).toInt();
    print('💰 Total Amount: ₹${totalAmount.value}');
    print('💰 Amount in Paise: $amountInPaise');

    var options = {
      'key': NetworkConstantsUtil.razorpay_key_Id,
      'amount': amountInPaise,
      'name': 'Meat Waala',
      'description': 'Order Payment',
      'prefill': {
        'contact': profile.mobile,
        'email': profile.emailId,
      },
      'notes': {
        'order_ref': _paymentOrderId,
        'customer_id': customerId,
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

      AppSnackbar.error('Failed to open payment gateway');
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
      final bool isCod = selectedPaymentMethod.value == 'cod';

      // For non-COD orders, validate payment IDs are present
      if (!isCod) {
        if (_paymentId == null || _paymentId!.isEmpty) {
          throw Exception('Payment ID not found');
        }
        if (_paymentOrderId == null || _paymentOrderId!.isEmpty) {
          throw Exception('Payment Order ID not found');
        }
      }

      // Prepare order data
      final orderData = <String, String>{
        'name': profile.name,
        'mobile': profile.mobile,
        'email_id': profile.emailId,
        'address_line1': profile.addressLine1,
        'address_line2': profile.addressLine2,
        'area_id': profile.areaId,
        if (!isCod) 'payment_id': _paymentId!,
        if (!isCod) 'payment_order_id': _paymentOrderId!,
        if (remarksController.text.trim().isNotEmpty)
          'remarks': remarksController.text.trim(),
      };

      log('📦 Submitting order with data: $orderData, COD: $isCod');

      final orderId =
          await _orderService.submitOrder(customerId, orderData, cod: isCod);

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
      AppSnackbar.error('Failed to place order: ${e.toString()}');
    }
  }
}
