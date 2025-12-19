import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meatwaala_app/core/theme/app_theme.dart';
import 'package:meatwaala_app/routes/app_routes.dart';
import 'package:meatwaala_app/routes/app_pages.dart';
import 'package:meatwaala_app/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  await StorageService.init();

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
