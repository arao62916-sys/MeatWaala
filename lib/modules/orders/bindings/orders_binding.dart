import 'package:get/get.dart';
import 'package:meatwaala_app/modules/orders/controllers/order_success_controller.dart';
import 'package:meatwaala_app/modules/orders/controllers/order_history_controller.dart';

class OrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderSuccessController>(() => OrderSuccessController());
    Get.lazyPut<OrderHistoryController>(() => OrderHistoryController());
  }
}
