import 'dart:developer';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:meatwaala_app/core/services/update_service.dart';
import 'package:meatwaala_app/modules/update/views/update_dialog.dart';

const String _playStoreUrl =
    'https://play.google.com/store/apps/details?id=com.meatwaala.meatwaala_app';

class UpdateController extends GetxController {
  final UpdateService _updateService = UpdateService();

  final isUpdateAvailable = false.obs;
  final isUpdating = false.obs;

  // true when in_app_update detected the update (Play Store install)
  bool _canUseInAppUpdate = false;
  UpdateResult? _updateResult;

  // Version info
  final currentVersion = ''.obs;
  final currentBuildNumber = ''.obs;
  final playStoreVersion = ''.obs;
  final isChecking = false.obs;
  final checkError = ''.obs;

  bool get isUpToDate =>
      !isUpdateAvailable.value && checkError.value.isEmpty;

  Future<void> checkForUpdate() async {
    try {
      _updateResult = await _updateService.checkForUpdate();

      if (_updateResult!.isUpdateAvailable) {
        _canUseInAppUpdate = true;
        isUpdateAvailable.value = true;
        log('🔄 Update available via in_app_update');
        _showUpdateDialog();
        return;
      }

      // Fallback: check Play Store directly by package name
      _canUseInAppUpdate = false;
      final storeVersion = await _updateService.fetchPlayStoreVersion();
      if (storeVersion != null) {
        final packageInfo = await PackageInfo.fromPlatform();
        playStoreVersion.value = storeVersion;
        if (_isNewerVersion(storeVersion, packageInfo.version)) {
          isUpdateAvailable.value = true;
          log('🔄 Update available via Play Store: $storeVersion > ${packageInfo.version}');
          _showUpdateDialog();
          return;
        }
      }

      log('✅ App is up to date');
      isUpdateAvailable.value = false;
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

      // Try in_app_update first
      _updateResult = await _updateService.checkForUpdate();

      if (_updateResult!.isUpdateAvailable) {
        _canUseInAppUpdate = true;
        isUpdateAvailable.value = true;
        playStoreVersion.value = _updateResult!.playStoreVersion ?? '';
        return;
      }

      // Fallback: fetch version from Play Store page
      _canUseInAppUpdate = false;
      final storeVersion = await _updateService.fetchPlayStoreVersion();
      if (storeVersion != null) {
        playStoreVersion.value = storeVersion;
        isUpdateAvailable.value =
            _isNewerVersion(storeVersion, packageInfo.version);
      } else {
        playStoreVersion.value = '';
        checkError.value = 'Could not fetch Play Store version';
      }
    } catch (e) {
      log('⚠️ Version check error: $e');
      checkError.value = 'Could not check Play Store';
    } finally {
      isChecking.value = false;
    }
  }

  bool _isNewerVersion(String storeVersion, String localVersion) {
    final storeParts = storeVersion.split('.').map(int.tryParse).toList();
    final localParts = localVersion.split('.').map(int.tryParse).toList();

    for (var i = 0; i < storeParts.length; i++) {
      final s = storeParts[i] ?? 0;
      final l = (i < localParts.length) ? (localParts[i] ?? 0) : 0;
      if (s > l) return true;
      if (s < l) return false;
    }
    return false;
  }

  void _showUpdateDialog() {
    final isCritical = _updateResult?.isCriticalUpdate ?? false;

    Get.dialog(
      UpdateDialog(isCritical: isCritical),
      barrierDismissible: !isCritical,
    );
  }

  Future<void> openPlayStore() async {
    final uri = Uri.parse(_playStoreUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      log('❌ Could not open Play Store');
    }
  }

  Future<void> startImmediateUpdate() async {
    if (!_canUseInAppUpdate) {
      await openPlayStore();
      return;
    }
    isUpdating.value = true;
    final success = await _updateService.startImmediateUpdate();
    isUpdating.value = false;

    if (!success) {
      log('❌ Immediate update failed, opening Play Store');
      await openPlayStore();
    }
  }

  Future<void> startFlexibleUpdate() async {
    if (!_canUseInAppUpdate) {
      await openPlayStore();
      return;
    }
    isUpdating.value = true;
    final success = await _updateService.startFlexibleUpdate();
    isUpdating.value = false;

    if (success) {
      Get.back();
      await _updateService.completeFlexibleUpdate();
    } else {
      log('❌ Flexible update failed, opening Play Store');
      await openPlayStore();
    }
  }
}
