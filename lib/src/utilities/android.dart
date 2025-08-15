import 'dart:io';

import 'package:build/build.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';

const _regex = r'''(?:namespace|applicationId)\s*(?:=)?\s*(['"])([^'"]+)\1''';

/// A utility class for Android-specific operations.
class Android {
  Android._internal();

  /// Singleton instance of [Android].
  static Android? _instance;

  /// The directory where the gradle file is located.
  late String? _srcRoot;

  /// The application ID extracted from the gradle file.
  late String? _applicationId;

  /// Returns the singleton instance of [Android].
  factory Android() {
    return _instance ??= Android._internal().._initialize();
  }

  /// Initializes this [Android] instance.
  void _initialize() {
    _srcRoot = _determineSrcRoot();
    _applicationId = _getApplicationId();
  }

  /// Resets the singleton instance. Used for testing purposes only.
  @visibleForTesting
  static void reset() {
    _instance = null;
  }

  /// Get the outPath and packageName, from given language, path and package.
  ///
  /// If the path is null or empty, it constructs a default path based on the
  /// srcRoot and package. If the package is null or empty, it uses the
  /// applicationId if available.
  Map<String, String?> get(String language, String? path, String? package) {
    String? outPath;
    String? packageName;

    // Determine the package name
    if (package != null && package.isNotEmpty) {
      packageName = package;
    } else if (_applicationId != null && _applicationId!.isNotEmpty) {
      packageName = _applicationId;
    }

    // Determine the output path
    if (path != null && path.isNotEmpty) {
      outPath = path;
    } else if (_srcRoot != null && packageName != null) {
      outPath = join(
        _srcRoot!,
        'src/main',
        language,
        packageName.replaceAll('.', '/'),
      );
    }

    return {'outPath': outPath, 'packageName': packageName};
  }

  /// Determines where the src directory is located based on the project type.
  ///
  /// If the project is an application, it returns 'android/app', but if the
  /// project is a library, it returns 'android'.
  String? _determineSrcRoot() {
    if (Directory('android/app/src').existsSync()) {
      return 'android/app';
    } else if (Directory('android/src').existsSync()) {
      return 'android';
    } else {
      log.warning('Could not determine the project type.');
      return null;
    }
  }

  /// Attempts to retrieves the applicationId from the gradle file at _srcRoot.
  String? _getApplicationId() {
    if (_srcRoot == null) return null;

    final gradleFile = File('$_srcRoot/build.gradle');
    final gradleKtsFile = File('$_srcRoot/build.gradle.kts');

    File? fileToRead;

    if (gradleFile.existsSync()) {
      fileToRead = gradleFile;
    } else if (gradleKtsFile.existsSync()) {
      fileToRead = gradleKtsFile;
    }

    if (fileToRead == null) {
      log.warning('build.gradle file does not exist in $_srcRoot');
      return null;
    }

    final content = fileToRead.readAsStringSync();
    final match = RegExp(_regex).firstMatch(content);

    if (match != null) {
      return match.group(2);
    } else {
      log.warning('applicationId/namespace not found in ${fileToRead.path}');
      return null;
    }
  }
}
