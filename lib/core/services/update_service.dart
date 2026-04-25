import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:in_app_update/in_app_update.dart';

const String _packageName = 'com.meatwaala.meatwaala_app';

class UpdateResult {
  final bool isUpdateAvailable;
  final bool isImmediateUpdateAllowed;
  final bool isFlexibleUpdateAllowed;
  final int? availableVersionCode;
  final int? updatePriority;
  final int? clientVersionStalenessDays;
  final String? playStoreVersion;

  UpdateResult({
    required this.isUpdateAvailable,
    this.isImmediateUpdateAllowed = false,
    this.isFlexibleUpdateAllowed = false,
    this.availableVersionCode,
    this.updatePriority,
    this.clientVersionStalenessDays,
    this.playStoreVersion,
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
      log('⚠️ in_app_update failed, falling back to Play Store check: $e');
      return UpdateResult(isUpdateAvailable: false);
    }
  }

  Future<String?> fetchPlayStoreVersion() async {
    try {
      final url = Uri.parse(
          'https://play.google.com/store/apps/details?id=$_packageName&hl=en');
      final response = await http.get(url, headers: {
        'User-Agent': 'Mozilla/5.0',
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        log('⚠️ Play Store fetch failed: HTTP ${response.statusCode}');
        return null;
      }

      final body = response.body;

      final versionMatch =
          RegExp(r'\[\[\["(\d+\.\d+\.\d+)"\]\]').firstMatch(body);
      if (versionMatch != null) {
        final version = versionMatch.group(1);
        log('✅ Play Store version found: $version');
        return version;
      }

      final altMatch =
          RegExp(r'Current Version.*?>([\d.]+)<', dotAll: true).firstMatch(body);
      if (altMatch != null) {
        return altMatch.group(1);
      }

      log('⚠️ Could not parse Play Store version from page');
      return null;
    } catch (e) {
      log('⚠️ Play Store version fetch error: $e');
      return null;
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
