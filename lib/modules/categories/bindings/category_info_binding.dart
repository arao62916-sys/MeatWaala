import 'package:get/get.dart';
import 'package:meatwaala_app/modules/categories/controllers/category_info_controller.dart';

class CategoryInfoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoryInfoController>(
      () => CategoryInfoController(),
    );
  }
}
