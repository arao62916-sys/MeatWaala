import 'package:get/get.dart';
import 'package:meatwaala_app/core/services/app_snackbar.dart';
import 'package:meatwaala_app/modules/location/controllers/area_controller.dart';
import 'package:meatwaala_app/routes/app_routes.dart';

/// Location Controller - wrapper for navigation logic
/// Uses AreaController for actual area data management
class LocationController extends GetxController {
  // Get AreaController instance
  AreaController get areaController => Get.find<AreaController>();

  /// Confirm location selection and navigate
  void confirmLocation() async {
    final success = await areaController.confirmSelection();

    if (success) {
      AppSnackbar.success('Location set to ${areaController.selectedAreaName}');

      // Navigate to signup for new users
      Get.offAllNamed(AppRoutes.signup);
    }
  }
}
