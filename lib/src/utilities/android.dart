import 'dart:io';

import 'package:build/build.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' show join;

@visibleForTesting
const regex = r'''(?:namespace|applicationId)\s*(?:=)?\s*(['"])([^'"]+)\1''';

/// A utility class for Android-specific operations.
class Android {
  Android._internal();

  /// Singleton instance of [Android].
  static Android? _instance;

  /// Optional folder path for output files.
  late String? _folder;

  /// The directory where the gradle file is located.
  late String? _srcRoot;

  /// The application ID extracted from the gradle file.
  late String? _applicationId;

  /// Creates a singleton instance of [Android].
  ///
  /// Parameters:
  /// - [outFolder]: Optional folder path for output files. This is also used
  ///   to determine the package name for the generated code
  ///
  /// Returns:
  /// - An instance of [Android]
  factory Android(String? outFolder) {
    return _instance ??= Android._internal().._initialize(outFolder);
  }

  /// Initializes this [Android] instance.
  void _initialize(String? outFolder) {
    _folder = outFolder;
    _srcRoot = determineSrcRoot();
    _applicationId = getApplicationId();
  }

  /// Resets the singleton instance. Used for testing purposes only.
  @visibleForTesting
  static void reset() {
    _instance = null;
  }

  /// Get the output path and package name for Android code generation.
  ///
  /// Parameters:
  /// - [language]: This is either 'java' or 'kotlin'
  /// - [path]: The output path for the generated code. If null or empty, a
  ///   default path is generated
  /// - [package]: The package name for the generated code. If null or empty,
  ///   uses the applicationId if available.
  ///
  /// Returns:
  /// A map containing:
  /// - `'outPath'`: The resolved output path for generated files
  /// - `'packageName'`: The resolved package name for the generated code
  Map<String, String?> get(String language, String? path, String? package) {
    String? outPath;
    String? packageName;

    // Determine the package name
    if (package?.isNotEmpty == true) {
      packageName = package;
    } else if (_applicationId?.isNotEmpty == true) {
      if (_folder?.isNotEmpty == true) {
        packageName = '$_applicationId.${_folder!.replaceAll('/', '.')}';
      } else {
        packageName = _applicationId;
      }
    }

    // Determine the output path
    if (path?.isNotEmpty == true) {
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
  /// Detection logic:
  /// 1. If 'android/app/src' exists → Android application
  /// 2. If 'android/src' exists → Android library
  ///
  /// Returns:
  /// - `'android/app'` for Android applications
  /// - `'android'` for Android libraries
  /// - `null` if no valid Android project structure is detected
  @visibleForTesting
  String? determineSrcRoot() {
    if (Directory('android/app/src').existsSync()) {
      return 'android/app';
    } else if (Directory('android/src').existsSync()) {
      return 'android';
    } else {
      log.warning('Could not determine the project type.');
      return null;
    }
  }

  /// Attempts to retrieve the applicationId from the gradle file at [_srcRoot].
  ///
  /// Search order:
  /// 1. `{_srcRoot}/build.gradle` (Groovy DSL)
  /// 2. `{_srcRoot}/build.gradle.kts` (Kotlin DSL)
  ///
  /// Returns:
  /// - The extracted `applicationId` or `namespace` string if found
  /// - `null` if no gradle file exits, no valid applicationId/namespace found
  @visibleForTesting
  String? getApplicationId() {
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
    final match = RegExp(regex).firstMatch(content);

    if (match != null) {
      return match.group(2);
    } else {
      log.warning('applicationId/namespace not found in ${fileToRead.path}');
      return null;
    }
  }
}
