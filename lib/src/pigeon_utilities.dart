import 'dart:io';

import 'package:build/build.dart';

/// A utility class for Android-specific operations.
class AndroidUtilities {
  static final AndroidUtilities _instance = AndroidUtilities._internal();

  String? _srcRoot;

  String? _applicationId;

  bool _applicationIdFetched = false;

  AndroidUtilities._internal() {
    if (_srcRoot != null) return;

    if (Directory('android/src').existsSync()) {
      _srcRoot = "android";
    } else {
      _srcRoot = "android/app";
    }
  }

  /// Returns the singleton instance of [AndroidUtilities].
  factory AndroidUtilities() {
    return _instance;
  }

  /// Retrieves the applicationId from the `android/app/build.gradle` file.
  ///
  /// Returns null if the file does not exist or the applicationId is not found.
  String? getApplicationId() {
    if (_applicationId == null && !_applicationIdFetched) {
      final gradleFile = File('$_srcRoot/build.gradle');

      if (gradleFile.existsSync()) {
        final content = gradleFile.readAsStringSync();
        final regex = RegExp(r'applicationId|namespace\s*=\s*"([^"]+)"');
        final match = regex.firstMatch(content);

        if (match != null) {
          _applicationId = match.group(1)!;
        } else {
          log.warning('applicationId/namespace not found (${gradleFile.path})');
        }
      } else {
        log.warning('build.gradle file does not exist (${gradleFile.path})');
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

    return '$_srcRoot/src/main/$language/${applicationId.replaceAll('.', '/')}/pigeons';
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
