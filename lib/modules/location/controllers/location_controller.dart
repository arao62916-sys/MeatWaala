import 'package:get/get.dart';
import 'package:meatwaala_app/core/constants/app_constants.dart';
import 'package:meatwaala_app/routes/app_routes.dart';
import 'package:meatwaala_app/services/storage_service.dart';

class LocationController extends GetxController {
  final StorageService _storage = StorageService();

  final selectedCity = ''.obs;
  final cities = AppConstants.availableCities;
  final searchQuery = ''.obs;

  List<String> get filteredCities {
    if (searchQuery.value.isEmpty) {
      return cities;
    }
    return cities
        .where((city) =>
            city.toLowerCase().contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  void selectCity(String city) {
    selectedCity.value = city;
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  void confirmLocation() {
    if (selectedCity.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a city',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    _storage.write(AppConstants.storageKeySelectedCity, selectedCity.value);
    Get.offAllNamed(AppRoutes.home);

    Get.snackbar(
      'Success',
      'Location set to ${selectedCity.value}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
