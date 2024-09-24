import 'dart:io';

import 'package:path/path.dart' as path;

import 'pigeon_config.dart';

/// Validator for the pigeon configuration.
class PigeonValidator {
  PigeonValidator._();

  /// The message to display when an invalid folder is provided.
  static const invalidFolder = 'Invalid folder provided.';

  /// Validate the pigeon configuration.
  static validate(PigeonConfig config) {
    validateInputs(config.inputs);

    if (config.dart != null) validateDartConfig(config.dart!);
    if (config.cpp != null) validateCppConfig(config.cpp!);
    if (config.gobject != null) validateGobjectConfig(config.gobject!);
    if (config.kotlin != null) validateKotlinConfig(config.kotlin!);
    if (config.java != null) validateJavaConfig(config.java!);
    if (config.swift != null) validateSwiftConfig(config.swift!);
    if (config.objc != null) validateObjcConfig(config.objc!);
    if (config.ast != null) validateAstConfig(config.ast!);

    validateCopyrightHeader(config.copyrightHeader);
    validateBasePath(config.basePath);
  }

  /// Validate the inputs configuration.
  static validateInputs(String inputs) {
    if (!_isValidFolder(inputs)) {
      throw ValidatorException('inputs', invalidFolder);
    }
  }

  /// Validate the dart configuration.
  static validateDartConfig(PigeonDartConfig config) {
    if (config.out != null && !_isValidFolder(config.out!)) {
      throw ValidatorException('dart.out', invalidFolder);
    }

    if (config.testOut != null && !_isValidFolder(config.testOut!)) {
      throw ValidatorException('dart.testOut', invalidFolder);
    }
  }

  /// Validate the cpp configuration.
  static validateCppConfig(PigeonCppConfig config) {
    if (config.headerOut != null && !_isValidFolder(config.headerOut!)) {
      throw ValidatorException('cpp.headerOut', invalidFolder);
    }

    if (config.sourceOut != null && !_isValidFolder(config.sourceOut!)) {
      throw ValidatorException('cpp.sourceOut', invalidFolder);
    }
  }

  /// Validate the gobject configuration.
  static validateGobjectConfig(PigeonGobjectConfig config) {
    if (config.headerOut != null && !_isValidFolder(config.headerOut!)) {
      throw ValidatorException('gobject.headerOut', invalidFolder);
    }

    if (config.sourceOut != null && !_isValidFolder(config.sourceOut!)) {
      throw ValidatorException('gobject.sourceOut', invalidFolder);
    }
  }

  /// Validate the kotlin configuration.
  static validateKotlinConfig(PigeonKotlinConfig config) {
    if (config.out != null && !_isValidFolder(config.out!)) {
      throw ValidatorException('kotlin.out', invalidFolder);
    }
  }

  /// Validate the java configuration.
  static validateJavaConfig(PigeonJavaConfig config) {
    if (config.out != null && !_isValidFolder(config.out!)) {
      throw ValidatorException('java.out', invalidFolder);
    }
  }

  /// Validate the swift configuration.
  static validateSwiftConfig(PigeonSwiftConfig config) {
    if (config.out != null && !_isValidFolder(config.out!)) {
      throw ValidatorException('swift.out', invalidFolder);
    }
  }

  /// Validate the objc configuration.
  static validateObjcConfig(PigeonObjcConfig config) {
    if (config.headerOut != null && !_isValidFolder(config.headerOut!)) {
      throw ValidatorException('objc.headerOut', invalidFolder);
    }

    if (config.sourceOut != null && !_isValidFolder(config.sourceOut!)) {
      throw ValidatorException('objc.sourceOut', invalidFolder);
    }
  }

  /// Validate the ast configuration.
  static validateAstConfig(PigeonAstConfig config) {
    if (config.out != null && !_isValidFolder(config.out!)) {
      throw ValidatorException('ast.out', invalidFolder);
    }
  }

  /// Validate the copyright_header configuration.
  static validateCopyrightHeader(String? path) {
    if (path == null) return;

    if (_isValidFolder(path)) {
      throw ValidatorException('copyright_header', 'Folder provided.');
    }

    final file = File(path);

    if (!file.existsSync()) {
      throw ValidatorException('copyright_header', 'File does not exist.');
    }
  }

  /// Validate base_path configuration.
  static validateBasePath(String? path) {
    if (path == null) return;

    if (!_isValidFolder(path)) {
      throw ValidatorException('basePath', invalidFolder);
    }
  }

  /// Check if the folder is valid.
  static _isValidFolder(String folder) {
    return folder.isNotEmpty && folder != '.' && path.extension(folder).isEmpty;
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
