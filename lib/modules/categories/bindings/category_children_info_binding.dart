import 'package:get/get.dart';
import 'package:meatwaala_app/modules/categories/controllers/category_children_info_controller.dart';

class CategoryChildrenInfoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoryChildrenInfoController>(
      () => CategoryChildrenInfoController(),
    );
  }
}
