import 'package:get/get.dart';
import 'package:meatwaala_app/modules/location/controllers/area_controller.dart';
import 'package:meatwaala_app/modules/location/controllers/location_controller.dart';

class LocationBinding extends Bindings {
  @override
  void dependencies() {
    // AreaController manages the API data and state
    Get.lazyPut<AreaController>(() => AreaController());
    // LocationController handles navigation logic
    Get.lazyPut<LocationController>(() => LocationController());
  }
}
