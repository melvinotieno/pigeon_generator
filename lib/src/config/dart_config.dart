import 'dart:io';

import 'package:meta/meta.dart';
import 'package:path/path.dart' show join;
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
  /// Parameters:
  /// - [map]: The configuration map containing Dart settings. Can be:
  ///   - `false`: Disables Dart code generation
  ///   - `Map`: Contains configuration options for Dart code generation
  ///   - Any other type: Treated as an empty configuration map
  /// - [outFolder]: Optional folder path for output files. If provided, the
  ///   default Dart output path will be 'lib/{outFolder}'
  ///
  /// Returns:
  /// - A [DartConfig] with null values if [map] is `false`
  /// - A [DartConfig] with the provided or default map configuration
  ///
  /// Example:
  /// ```dart
  /// // Disable Dart code generation
  /// final config1 = DartConfig.fromMap(false);
  ///
  /// // Enable with default settings
  /// final config2 = DartConfig.fromMap({}, 'my_project');
  /// final config3 = DartConfig.fromMap(true, 'my_project');
  /// final config4 = DartConfig.fromMap(null, 'my_project');
  ///
  /// // Enable with provided configuration
  /// final config5 = DartConfig.fromMap({
  ///  'out': 'custom/path',
  ///  'test_out': 'custom/test/path',
  ///  'package_name': 'custom_package',
  ///  'options': {
  ///    'copyright_header': ['Copyright Header'],
  ///    'source_out': 'custom/source/path',
  ///    'test_out': 'custom/test/path',
  ///  }
  /// });
  /// ```
  factory DartConfig.fromMap(dynamic map, [String? outFolder]) {
    if (map == false) return DartConfig._internal();

    final config = map is Map ? map : <String, dynamic>{};
    final defaultPath = join('lib', outFolder);

    return DartConfig._internal(
      out: OutputConfig.fromOptions(
        config['out'] as String? ?? defaultPath,
        extension: 'dart',
      ),
      testOut: getTestOut(config['test_out'], outFolder),
      packageName: config['package_name'] as String?,
      options: config['options'] as Map<String, dynamic>?,
    );
  }

  /// Returns the Dart options for the given input.
  ///
  /// Parameters:
  /// - [input]: The input file name to generate options for
  ///
  /// Returns:
  /// - `null` if no options are configured
  /// - A [DartOptions] instance with the provided options
  ///
  /// Example:
  /// ```dart
  /// final config = DartConfig.fromMap({
  ///   'options': {
  ///     'source_out': 'lib/generated',
  ///     'test_out': 'test/generated',
  ///     'copyright_header': ['Copyright Header'],
  ///   }
  /// });
  ///
  /// final options = config.getOptions('my_api');
  /// // options.sourceOutPath will be 'lib/generated/my_api.dart'
  /// // options.testOutPath will be 'test/generated/my_api_test.dart'
  /// ```
  DartOptions? getOptions(String input) {
    if (_options == null) return null;

    final sourceOut = _options['source_out'] as String?;
    final testOut = _options['test_out'] as String?;

    return DartOptions(
      copyrightHeader: _options['copyright_header'] as Iterable<String>?,
      sourceOutPath: sourceOut?.let((path) => join(path, '$input.dart')),
      testOutPath: testOut?.let((path) => join(path, '${input}_test.dart')),
    );
  }

  /// Returns the output configuration for the test file.
  ///
  /// Parameters:
  /// - [test]: The test configuration value. Can be:
  ///   - `false`: Explicitly disables test file generation
  ///   - `null`: Disables test file generation unless 'test' directory exists
  ///   - `String`: Specifies the output path for the test file
  ///   - Any other type: Uses the default test output path
  /// - [outFolder]: Optional folder path for output files. If provided, the
  ///   default Dart test output path will be 'test/{outFolder}'
  ///
  /// Returns:
  /// - `null` if test file generation is disabled
  /// - An [OutputConfig] instance for the Dart test files
  ///
  /// Example:
  /// ```dart
  /// // Disable test file generation
  /// final testOut1 = DartConfig.getTestOut(false);
  /// final testOut2 = DartConfig.getTestOut(null); // 'test' does not exist
  ///
  /// // Enable with default settings
  /// final testOut3 = DartConfig.getTestOut(true, 'my_project');
  ///
  /// // Custom output path
  /// final testOut4 = DartConfig.getTestOut('custom/test/path', 'my_project');
  /// ```
  @visibleForTesting
  static OutputConfig? getTestOut(dynamic test, [String? outFolder]) {
    if (test == false || (test == null && !Directory('test').existsSync())) {
      return null;
    }

    final testOutPath = test is String ? test : join('test', outFolder);

    return OutputConfig.fromOptions(
      testOutPath,
      extension: 'dart',
      append: '_test',
    );
  }
}
