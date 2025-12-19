import 'package:get/get.dart';
import 'package:meatwaala_app/core/constants/app_constants.dart';
import 'package:meatwaala_app/routes/app_routes.dart';
import 'package:meatwaala_app/services/storage_service.dart';

class SplashController extends GetxController {
  final StorageService _storage = StorageService();

  @override
  void onReady() {
    super.onReady();
    print("✅ SplashController onReady called");
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(
      Duration(seconds: AppConstants.splashDuration),
    );

    final isFirstTime =
        _storage.read<bool>(AppConstants.storageKeyIsFirstTime) ?? true;

    if (isFirstTime) {
      Get.offAllNamed(AppRoutes.onboarding);
    } else {
      final token = _storage.read<String>(AppConstants.storageKeyToken);

      if (token != null && token.isNotEmpty) {
        Get.offAllNamed(AppRoutes.main);
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    }
  }
}
