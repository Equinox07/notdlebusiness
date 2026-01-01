import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:notdle/services/api_service.dart';
import 'package:notdle/models/app_version.dart';

class VersionHelper {
  static Future<Map<String, dynamic>> checkUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;
      final packageName = packageInfo.packageName;

      final platform =
          Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'other');

      final AppVersionDto? latestVersionDto = await ApiService()
          .getLatestAppVersion(platform, packageName);

      if (latestVersionDto == null) {
        return {'shouldUpdate': false, 'forceUpdate': false};
      }

      final isHigher = latestVersionDto.buildNumber > currentBuildNumber;
      final isForce = latestVersionDto.forceUpdate ?? false;

      return {
        'shouldUpdate': isHigher,
        'forceUpdate': isForce,
        'latestVersion': latestVersionDto,
      };
    } catch (e) {
      return {'shouldUpdate': false, 'forceUpdate': false};
    }
  }
}
