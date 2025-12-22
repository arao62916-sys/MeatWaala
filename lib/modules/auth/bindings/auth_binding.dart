import 'package:get/get.dart';
import 'package:meatwaala_app/modules/auth/controllers/auth_controller.dart';
import 'package:meatwaala_app/modules/location/controllers/area_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // AreaController is needed for signup (area selection)
    // Use fenix: true to keep it alive or reuse existing instance
    if (!Get.isRegistered<AreaController>()) {
      Get.put<AreaController>(AreaController(), permanent: true);
    }
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
