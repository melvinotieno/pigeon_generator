import 'dart:io';

import 'package:path/path.dart';
import 'package:pigeon/pigeon.dart';

import 'output_config.dart';

/// Configuration for Dart code generation.
class DartConfig {
  DartConfig._internal({
    this.out,
    this.testOut,
    this.packageName,
    Map<String, dynamic>? options,
  }) : _options = options;

  /// Configuration for the Dart file that will be generated.
  final OutputConfig? out;

  /// Configuration for the Dart file that will be generated for test support.
  final OutputConfig? testOut;

  /// The name of the package the pigeon files will be used in.
  final String? packageName;

  /// Options that control how Dart code will be generated.
  final Map<String, dynamic>? _options;

  /// Creates a [DartConfig] instance from a map.
  ///
  /// If the map is `false`, it returns a [DartConfig] with null values.
  ///
  /// If the map is `null`, it returns a [DartConfig] with default values.
  factory DartConfig.fromMap(dynamic map) {
    if (map == false) return DartConfig._internal();

    return DartConfig._internal(
      out: OutputConfig.fromOptions(
        map?['out'] as String? ?? 'lib',
        extension: 'dart',
      ),
      testOut: _getTestOut(map?['test_out']),
      packageName: map?['package_name'] as String?,
      options: map?['options'] as Map<String, dynamic>?,
    );
  }

  /// Returns the Dart options for the given file name.
  DartOptions? getOptions(String fileName) {
    if (_options == null) return null;

    final sourceOut = _options['source_out'] as String?;
    final testOut = _options['test_out'] as String?;

    return DartOptions(
      copyrightHeader: _options['copyright_header'] as Iterable<String>?,
      sourceOutPath: sourceOut?.let((path) => join(path, '$fileName.dart')),
      testOutPath: testOut?.let((path) => join(path, '${fileName}_test.dart')),
    );
  }

  /// Returns the output configuration for the test file.
  static OutputConfig? _getTestOut(dynamic test) {
    // If false or null and test directory does not exist, return null.
    if (test == false || (test == null && !Directory('test').existsSync())) {
      return null;
    }

    return OutputConfig.fromOptions(
      test as String? ?? 'test',
      extension: 'dart',
      append: '_test',
    );
  }
}
