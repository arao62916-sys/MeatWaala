import 'package:get/get.dart';
import 'package:meatwaala_app/modules/navigation/controllers/bottom_nav_controller.dart';
import 'package:meatwaala_app/modules/home/bindings/home_binding.dart';
import 'package:meatwaala_app/modules/categories/bindings/categories_binding.dart';
import 'package:meatwaala_app/modules/orders/bindings/orders_binding.dart';
import 'package:meatwaala_app/modules/profile/bindings/profile_binding.dart';

class BottomNavBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize BottomNavController
    Get.lazyPut<BottomNavController>(() => BottomNavController());

    // Lazy load all tab bindings
    HomeBinding().dependencies();
    CategoriesBinding().dependencies();
    OrdersBinding().dependencies();
    ProfileBinding().dependencies();
  }
}
