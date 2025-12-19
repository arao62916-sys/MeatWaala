import 'package:get/get.dart';
import 'package:meatwaala_app/routes/app_routes.dart';

class OrderSuccessController extends GetxController {
  final orderId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    orderId.value = args?['orderId'] ?? '';
  }

  void continueShopping() {
    Get.offAllNamed(AppRoutes.home);
  }

  void viewOrders() {
    Get.offAllNamed(AppRoutes.orderHistory);
  }
}
