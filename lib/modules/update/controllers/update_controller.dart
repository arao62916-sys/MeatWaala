import 'dart:developer';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:meatwaala_app/core/services/update_service.dart';
import 'package:meatwaala_app/modules/update/views/update_dialog.dart';

class UpdateController extends GetxController {
  final UpdateService _updateService = UpdateService();

  final isUpdateAvailable = false.obs;
  final isUpdating = false.obs;
  UpdateResult? _updateResult;

  // Version info
  final currentVersion = ''.obs;
  final currentBuildNumber = ''.obs;
  final availableVersionCode = RxnInt();
  final isChecking = false.obs;
  final checkError = ''.obs;

  bool get isUpToDate => !isUpdateAvailable.value && checkError.value.isEmpty;

  Future<void> checkForUpdate() async {
    try {
      _updateResult = await _updateService.checkForUpdate();

      if (!_updateResult!.isUpdateAvailable) {
        log('✅ App is up to date');
        isUpdateAvailable.value = false;
        return;
      }

      isUpdateAvailable.value = true;
      availableVersionCode.value = _updateResult!.availableVersionCode;
      log('🔄 Update available — critical: ${_updateResult!.isCriticalUpdate}');

      _showUpdateDialog();
    } catch (e) {
      log('⚠️ Update check error: $e');
    }
  }

  Future<void> loadVersionInfo() async {
    isChecking.value = true;
    checkError.value = '';

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      currentVersion.value = packageInfo.version;
      currentBuildNumber.value = packageInfo.buildNumber;

      _updateResult = await _updateService.checkForUpdate();

      if (_updateResult!.isUpdateAvailable) {
        isUpdateAvailable.value = true;
        availableVersionCode.value = _updateResult!.availableVersionCode;
      } else {
        isUpdateAvailable.value = false;
        availableVersionCode.value = null;
      }
    } catch (e) {
      log('⚠️ Version check error: $e');
      checkError.value = 'Could not check Play Store';
    } finally {
      isChecking.value = false;
    }
  }

  void _showUpdateDialog() {
    final isCritical = _updateResult?.isCriticalUpdate ?? false;

    Get.dialog(
      UpdateDialog(isCritical: isCritical),
      barrierDismissible: !isCritical,
    );
  }

  Future<void> startImmediateUpdate() async {
    isUpdating.value = true;
    final success = await _updateService.startImmediateUpdate();
    isUpdating.value = false;

    if (!success) {
      log('❌ Immediate update was cancelled or failed');
    }
  }

  Future<void> startFlexibleUpdate() async {
    isUpdating.value = true;
    final success = await _updateService.startFlexibleUpdate();
    isUpdating.value = false;

    if (success) {
      Get.back();
      await _updateService.completeFlexibleUpdate();
    } else {
      log('❌ Flexible update was cancelled or failed');
    }
  }
}
