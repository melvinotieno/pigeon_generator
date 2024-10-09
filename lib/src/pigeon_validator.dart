import 'dart:io';

import 'package:path/path.dart' as path;

import 'pigeon_config.dart';

/// Validator for the pigeon configuration.
class PigeonValidator {
  PigeonValidator._();

  /// Validate the pigeon configuration.
  static validate(PigeonConfig config) {
    validateInputs(config.inputs);
    validateDartConfig(config.dart);
    validateCppConfig(config.cpp);
    validateGobjectConfig(config.gobject);
    validateKotlinConfig(config.kotlin);
    validateJavaConfig(config.java);
    validateSwiftConfig(config.swift);
    validateObjcConfig(config.objc);
    validateAstConfig(config.ast);
    validateCopyrightHeader(config.copyrightHeader);
  }

  /// Validate the inputs configuration.
  static validateInputs(String inputs) {
    if (!isValidFolder(inputs)) {
      throw ValidatorException('inputs', 'Invalid folder provided.');
    }
  }

  /// Validate the dart configuration.
  static validateDartConfig(PigeonDartConfig? config) {
    if (config == null) return;

    validateOutput('dart.out', config.out);
    validateOutput('dart.testOut', config.testOut);
  }

  /// Validate the cpp configuration.
  static validateCppConfig(PigeonCppConfig? config) {
    if (config == null) return;

    validateOutput('cpp.headerOut', config.headerOut);
    validateOutput('cpp.sourceOut', config.sourceOut);
  }

  /// Validate the gobject configuration.
  static validateGobjectConfig(PigeonGobjectConfig? config) {
    if (config == null) return;

    validateOutput('gobject.headerOut', config.headerOut);
    validateOutput('gobject.sourceOut', config.sourceOut);
  }

  /// Validate the kotlin configuration.
  static validateKotlinConfig(PigeonKotlinConfig? config) {
    if (config == null) return;

    validateOutput('kotlin.out', config.out);
  }

  /// Validate the java configuration.
  static validateJavaConfig(PigeonJavaConfig? config) {
    if (config == null) return;

    validateOutput('java.out', config.out);
  }

  /// Validate the swift configuration.
  static validateSwiftConfig(PigeonSwiftConfig? config) {
    if (config == null) return;

    validateOutput('swift.out', config.out);
  }

  /// Validate the objc configuration.
  static validateObjcConfig(PigeonObjcConfig? config) {
    if (config == null) return;

    validateOutput('objc.headerOut', config.headerOut);
    validateOutput('objc.sourceOut', config.sourceOut);
  }

  /// Validate the ast configuration.
  static validateAstConfig(PigeonAstConfig? config) {
    if (config == null) return;

    validateOutput('ast.out', config.out);
  }

  /// Validate the copyright_header configuration.
  static validateCopyrightHeader(String? path) {
    if (path == null) return;

    if (isValidFolder(path)) {
      throw ValidatorException('copyright_header', 'Folder provided.');
    }

    final file = File(path);

    if (!file.existsSync()) {
      throw ValidatorException('copyright_header', 'File does not exist.');
    }
  }

  /// Validate the output configuration.
  static validateOutput(String field, PigeonOutput? output) {
    if (output == null) return;

    if (!isValidFolder(output.path)) {
      throw ValidatorException(field, 'Invalid folder provided.');
    }
  }

  /// Check if the folder is valid.
  static bool isValidFolder(String folder) {
    // Empty string provided.
    if (folder.isEmpty) return false;

    // If an extension exists, then this is a file and not a folder.
    if (path.extension(folder).isNotEmpty) return false;

    return true;
  }
}

/// Exception thrown when the pigeon configuration is invalid.
class ValidatorException implements Exception {
  ValidatorException(this.field, this.message);

  /// The field that is invalid.
  final String field;

  /// The message to display.
  final String message;

  @override
  String toString() => 'Invalid field ($field): $message';
}
