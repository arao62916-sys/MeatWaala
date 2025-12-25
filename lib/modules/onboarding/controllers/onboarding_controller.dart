import 'package:get/get.dart';
import 'package:meatwaala_app/core/constants/app_constants.dart';
import 'package:meatwaala_app/routes/app_routes.dart';
import 'package:meatwaala_app/services/storage_service.dart';

class OnboardingController extends GetxController {
  final StorageService _storage = StorageService();
  final currentPage = 0.obs;

  final List<OnboardingPage> pages = [
    OnboardingPage(
      title: 'Fresh & Hygienic Meat',
      description:
          'Get the freshest and most hygienic meat delivered to your doorstep',
      imageAsset: 'assets/images/logo.jpg',
    ),
    OnboardingPage(
      title: 'Fast Delivery',
      description:
          'Quick and reliable delivery service. Your order reaches you fresh and on time',
      lottieAsset: 'assets/data/Delivery Fudis.json',
    ),
    OnboardingPage(
      title: 'Trusted Quality',
      description:
          'Premium quality products from trusted sources. 100% satisfaction guaranteed',
      lottieAsset: 'assets/data/Cooking.json',
    ),
  ];

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void skip() {
    _completeOnboarding();
  }

  void next() {
    if (currentPage.value < pages.length - 1) {
      currentPage.value++;
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    _storage.write(AppConstants.storageKeyIsFirstTime, false);
    Get.offAllNamed(AppRoutes.login);
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String? imageAsset;
  final String? lottieAsset;

  OnboardingPage({
    required this.title,
    required this.description,
    this.imageAsset,
    this.lottieAsset,
  });
}
