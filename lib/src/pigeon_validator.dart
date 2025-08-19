import 'dart:io';

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
    _validateInputs(config.inputs);
    _validateDartConfig(config.dart);
    _validateObjcConfig(config.objc);
    _validateJavaConfig(config.java);
    _validateSwiftConfig(config.swift);
    _validateKotlinConfig(config.kotlin);
    _validateCppConfig(config.cpp);
    _validateGobjectConfig(config.gobject);
    _validateAstConfig(config.ast);
    _validateCopyrightHeader(config.copyrightHeader);
  }

  /// Validate the inputs configuration.
  static _validateInputs(String inputs) {
    if (!_isValidFolder(inputs)) {
      throw ValidatorException('inputs', 'Invalid folder provided.');
    }
  }

  /// Validate the dart configuration.
  static _validateDartConfig(DartConfig config) {
    _validateOutput('dart.out', config.out);
    _validateOutput('dart.test_out', config.testOut);
  }

  /// Validate the objc configuration.
  static _validateObjcConfig(ObjcConfig config) {
    _validateOutput('objc.header_out', config.headerOut);
    _validateOutput('objc.source_out', config.sourceOut);
  }

  /// Validate the java configuration.
  static _validateJavaConfig(JavaConfig config) {
    _validateOutput('java.out', config.out);
  }

  /// Validate the swift configuration.
  static _validateSwiftConfig(SwiftConfig config) {
    _validateOutput('swift.out', config.out);
  }

  /// Validate the kotlin configuration.
  static _validateKotlinConfig(KotlinConfig config) {
    _validateOutput('kotlin.out', config.out);
  }

  /// Validate the cpp configuration.
  static _validateCppConfig(CppConfig config) {
    _validateOutput('cpp.header_out', config.headerOut);
    _validateOutput('cpp.source_out', config.sourceOut);
  }

  /// Validate the gobject configuration.
  static _validateGobjectConfig(GObjectConfig config) {
    _validateOutput('gobject.header_out', config.headerOut);
    _validateOutput('gobject.source_out', config.sourceOut);
  }

  /// Validate the ast configuration.
  static _validateAstConfig(AstConfig config) {
    _validateOutput('ast.out', config.out);
  }

  /// Validate the copyright_header configuration.
  static _validateCopyrightHeader(String? path) {
    if (path == null) return;

    if (_isValidFolder(path)) {
      throw ValidatorException('copyright_header', 'Folder provided.');
    }

    final file = File(path);

    if (!file.existsSync()) {
      throw ValidatorException('copyright_header', 'File does not exist.');
    }
  }

  /// Validate the output configuration.
  static _validateOutput(String field, OutputConfig? output) {
    if (output == null) return;

    if (!_isValidFolder(output.path)) {
      throw ValidatorException(field, 'Invalid folder provided.');
    }
  }

  /// Check if the folder is valid.
  static bool _isValidFolder(String folder) {
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
