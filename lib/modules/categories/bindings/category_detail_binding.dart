import 'package:get/get.dart';
import 'package:meatwaala_app/modules/categories/controllers/category_detail_controller.dart';

class CategoryDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoryDetailController>(
      () => CategoryDetailController(),
    );
  }
}
