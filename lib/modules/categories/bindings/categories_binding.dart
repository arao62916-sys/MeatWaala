import 'package:get/get.dart';
import 'package:meatwaala_app/modules/categories/controllers/categories_controller.dart';

class CategoriesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoriesController>(() => CategoriesController());
  }
}
