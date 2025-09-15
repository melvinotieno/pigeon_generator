import 'dart:io';

import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

import 'config/ast_config.dart';
import 'config/cpp_config.dart';
import 'config/dart_config.dart';
import 'config/gobject_config.dart';
import 'config/java_config.dart';
import 'config/kotlin_config.dart';
import 'config/objc_config.dart';
import 'config/output_config.dart';
import 'config/swift_config.dart';
import 'pigeon_config.dart';

/// Validator for the pigeon configuration.
class PigeonValidator {
  PigeonValidator._();

  /// Validate the pigeon configuration.
  static void validate(PigeonConfig config) {
    validateInputs(config.inputs);
    validateDartConfig(config.dart);
    validateObjcConfig(config.objc);
    validateJavaConfig(config.java);
    validateSwiftConfig(config.swift);
    validateKotlinConfig(config.kotlin);
    validateCppConfig(config.cpp);
    validateGobjectConfig(config.gobject);
    validateAstConfig(config.ast);
    validateCopyrightHeader(config.copyrightHeader);
  }

  /// Validate the inputs configuration.
  @visibleForTesting
  static validateInputs(String inputs) {
    if (!isValidFolder(inputs)) {
      throw ValidatorException('inputs', 'Invalid folder provided.');
    }
  }

  /// Validate the dart configuration.
  @visibleForTesting
  static validateDartConfig(DartConfig config) {
    validateOutput('dart.out', config.out);
    validateOutput('dart.test_out', config.testOut);
  }

  /// Validate the objc configuration.
  @visibleForTesting
  static validateObjcConfig(ObjcConfig config) {
    validateOutput('objc.header_out', config.headerOut);
    validateOutput('objc.source_out', config.sourceOut);
  }

  /// Validate the java configuration.
  @visibleForTesting
  static validateJavaConfig(JavaConfig config) {
    validateOutput('java.out', config.out);
  }

  /// Validate the swift configuration.
  @visibleForTesting
  static validateSwiftConfig(SwiftConfig config) {
    validateOutput('swift.out', config.out);
  }

  /// Validate the kotlin configuration.
  @visibleForTesting
  static validateKotlinConfig(KotlinConfig config) {
    validateOutput('kotlin.out', config.out);
  }

  /// Validate the cpp configuration.
  @visibleForTesting
  static validateCppConfig(CppConfig config) {
    validateOutput('cpp.header_out', config.headerOut);
    validateOutput('cpp.source_out', config.sourceOut);
  }

  /// Validate the gobject configuration.
  @visibleForTesting
  static validateGobjectConfig(GObjectConfig config) {
    validateOutput('gobject.header_out', config.headerOut);
    validateOutput('gobject.source_out', config.sourceOut);
  }

  /// Validate the ast configuration.
  @visibleForTesting
  static validateAstConfig(AstConfig config) {
    validateOutput('ast.out', config.out);
  }

  /// Validate the copyright_header configuration.
  @visibleForTesting
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
  @visibleForTesting
  static validateOutput(String field, OutputConfig? output) {
    if (output == null) return;

    if (!isValidFolder(output.path)) {
      throw ValidatorException(field, 'Invalid folder provided.');
    }
  }

  /// Check if the folder is valid.
  @visibleForTesting
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
