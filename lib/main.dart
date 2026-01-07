import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meatwaala_app/core/theme/app_theme.dart';
import 'package:meatwaala_app/modules/auth/controllers/auth_controller.dart';
import 'package:meatwaala_app/modules/location/controllers/area_controller.dart';
import 'package:meatwaala_app/modules/orders/controllers/order_controller.dart';
import 'package:meatwaala_app/modules/profile/controllers/profile_controller.dart';
import 'package:meatwaala_app/routes/app_routes.dart';
import 'package:meatwaala_app/routes/app_pages.dart';
import 'package:meatwaala_app/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  await StorageService.init();
  // Register AuthController globally before any other controller
  Get.put(AuthController());
  Get.put(AreaController());
  Get.put(ProfileController());
  Get.put(OrderController());
  runApp(const MeatWaalaApp());
}

class MeatWaalaApp extends StatelessWidget {
  const MeatWaalaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MeatWaala',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
    );
  }
}
