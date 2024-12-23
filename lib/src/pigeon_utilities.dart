import 'dart:io';

import 'package:build/build.dart';

/// A utility class for Android-specific operations.
class AndroidUtilities {
  static final AndroidUtilities _instance = AndroidUtilities._internal();

  String? _applicationId;

  bool _applicationIdFetched = false;

  AndroidUtilities._internal();

  /// Returns the singleton instance of [AndroidUtilities].
  factory AndroidUtilities() {
    return _instance;
  }

  /// Retrieves the applicationId from the `android/app/build.gradle` file.
  ///
  /// Returns null if the file does not exist or the applicationId is not found.
  String? getApplicationId() {
    if (_applicationId == null && !_applicationIdFetched) {
      final appGradleFile = File('android/app/build.gradle');
      final libGradleFile = File('android/build.gradle');

      if (appGradleFile.existsSync()) {
        final content = appGradleFile.readAsStringSync();
        final regex = RegExp(r'applicationId\s*=\s*"([^"]+)"');
        final match = regex.firstMatch(content);

        if (match != null) {
          _applicationId = match.group(1)!;
        } else {
          log.warning('android/app/build.gradle has no applicationId defined.');
        }
      } else if (libGradleFile.existsSync()) {
        final content = libGradleFile.readAsStringSync();
        final regex = RegExp(r'namespace\s*=\s*"([^"]+)"');
        final match = regex.firstMatch(content);

        if (match != null) {
          _applicationId = match.group(1)!;
        } else {
          log.warning('android/build.gradle has no applicationId defined.');
        }
      } else {
        log.warning('build.gradle file does not exist.');
      }

      // Because applicationId can be null, we use this to check if the
      // build.gradle file has already been read.
      _applicationIdFetched = true;
    }

    return _applicationId;
  }

  /// Returns the output path for the specified language.
  String? getOutPath(String language) {
    final applicationId = getApplicationId();

    if (applicationId == null) return null;

    return 'android/app/src/main/$language/${applicationId.replaceAll('.', '/')}/pigeons';
  }

  /// Returns the package name for the location of the generated pigeon files.
  String? getPackage() {
    final applicationId = getApplicationId();

    if (applicationId == null) return null;

    return '$applicationId.pigeons';
  }
}

/// Provides access to the singleton instance of [AndroidUtilities].
AndroidUtilities get android => AndroidUtilities();
