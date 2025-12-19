import 'package:get/get.dart';
import 'package:meatwaala_app/modules/products/controllers/product_list_controller.dart';
import 'package:meatwaala_app/modules/products/controllers/product_detail_controller.dart';

class ProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductListController>(() => ProductListController());
    Get.lazyPut<ProductDetailController>(() => ProductDetailController());
  }
}
