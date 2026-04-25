import 'dart:developer';
import 'package:in_app_update/in_app_update.dart';

class UpdateResult {
  final bool isUpdateAvailable;
  final bool isImmediateUpdateAllowed;
  final bool isFlexibleUpdateAllowed;
  final int? availableVersionCode;
  final int? updatePriority;
  final int? clientVersionStalenessDays;

  UpdateResult({
    required this.isUpdateAvailable,
    this.isImmediateUpdateAllowed = false,
    this.isFlexibleUpdateAllowed = false,
    this.availableVersionCode,
    this.updatePriority,
    this.clientVersionStalenessDays,
  });

  bool get isCriticalUpdate =>
      (clientVersionStalenessDays ?? 0) > 7 || (updatePriority ?? 0) >= 4;
}

class UpdateService {
  Future<UpdateResult> checkForUpdate() async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      log('🔄 Update check: available=${info.updateAvailability == UpdateAvailability.updateAvailable}, '
          'stalenessDays=${info.clientVersionStalenessDays}, '
          'priority=${info.updatePriority}');

      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        return UpdateResult(
          isUpdateAvailable: true,
          isImmediateUpdateAllowed: info.immediateUpdateAllowed,
          isFlexibleUpdateAllowed: info.flexibleUpdateAllowed,
          availableVersionCode: info.availableVersionCode,
          updatePriority: info.updatePriority,
          clientVersionStalenessDays: info.clientVersionStalenessDays,
        );
      }

      return UpdateResult(isUpdateAvailable: false);
    } catch (e) {
      log('⚠️ Update check failed (expected on non-Play Store installs): $e');
      return UpdateResult(isUpdateAvailable: false);
    }
  }

  Future<bool> startImmediateUpdate() async {
    try {
      final result = await InAppUpdate.performImmediateUpdate();
      return result == AppUpdateResult.success;
    } catch (e) {
      log('❌ Immediate update failed: $e');
      return false;
    }
  }

  Future<bool> startFlexibleUpdate() async {
    try {
      final result = await InAppUpdate.startFlexibleUpdate();
      return result == AppUpdateResult.success;
    } catch (e) {
      log('❌ Flexible update failed: $e');
      return false;
    }
  }

  Future<void> completeFlexibleUpdate() async {
    try {
      await InAppUpdate.completeFlexibleUpdate();
    } catch (e) {
      log('❌ Complete flexible update failed: $e');
    }
  }
}
