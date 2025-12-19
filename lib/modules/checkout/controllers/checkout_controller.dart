import 'package:get/get.dart';
import 'package:meatwaala_app/core/constants/app_constants.dart';
import 'package:meatwaala_app/data/models/address_model.dart';
import 'package:meatwaala_app/routes/app_routes.dart';

class CheckoutController extends GetxController {
  final selectedAddress = Rxn<AddressModel>();
  final selectedTimeSlot = ''.obs;
  final selectedPaymentMethod = 'Cash on Delivery'.obs;
  final isLoading = false.obs;

  final addresses = <AddressModel>[].obs;
  final timeSlots = AppConstants.deliveryTimeSlots;
  final paymentMethods = AppConstants.paymentMethods;

  @override
  void onInit() {
    super.onInit();
    loadMockAddresses();
    selectedTimeSlot.value = timeSlots.first;
  }

  void loadMockAddresses() {
    addresses.value = [
      AddressModel(
        id: '1',
        title: 'Home',
        fullName: 'John Doe',
        phone: '+91 9876543210',
        addressLine1: '123 Main Street',
        addressLine2: 'Apartment 4B',
        city: 'Mumbai',
        state: 'Maharashtra',
        pincode: '400001',
        isDefault: true,
      ),
      AddressModel(
        id: '2',
        title: 'Office',
        fullName: 'John Doe',
        phone: '+91 9876543210',
        addressLine1: '456 Business Park',
        city: 'Mumbai',
        state: 'Maharashtra',
        pincode: '400002',
      ),
    ];
    selectedAddress.value = addresses.first;
  }

  void selectAddress(AddressModel address) {
    selectedAddress.value = address;
  }

  void selectTimeSlot(String slot) {
    selectedTimeSlot.value = slot;
  }

  void selectPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  Future<void> placeOrder() async {
    if (selectedAddress.value == null) {
      Get.snackbar(
        'Error',
        'Please select a delivery address',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    isLoading.value = false;

    // Navigate to order success
    Get.offAllNamed(AppRoutes.orderSuccess, arguments: {
      'orderId': 'ORD${DateTime.now().millisecondsSinceEpoch}',
    });
  }
}
