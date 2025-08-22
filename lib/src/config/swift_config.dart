import 'dart:io';

import 'package:path/path.dart' show join;
import 'package:pigeon/pigeon.dart';

import 'output_config.dart';

/// Configuration for Swift code generation.
class SwiftConfig {
  SwiftConfig._internal({this.out, Map<String, dynamic>? options})
    : _options = options;

  /// Configuration for the ".swift" file that will be generated.
  final OutputConfig? out;

  /// Options that control how Swift code will be generated.
  final Map<String, dynamic>? _options;

  /// Creates a [SwiftConfig] instance from a map.
  ///
  /// Parameters:
  /// - [map]: The configuration map containing Swift settings. Can be:
  ///   - `false`: Explicitly disables Swift code generation
  ///   - `null`: Disables code generation unless 'ios' directory exists
  ///   - `Map`: Contains configuration options for Swift code generation
  ///   - Any other type: Treated as an empty configuration map
  /// - [outFolder]: Optional folder path for output files. If provided, the
  ///   default Swift output path will be 'ios/Runner/{outFolder}'
  ///
  /// Returns:
  /// - An [SwiftConfig] with null values if [map] is `false`
  /// - An [SwiftConfig] with the default or provided map configuration
  ///
  /// Example:
  /// ```dart
  /// // Disable Swift code generation
  /// final config1 = SwiftConfig.fromMap(null); // If 'ios' does not exist
  /// final config2 = SwiftConfig.fromMap(false);
  ///
  /// // Enable with default settings
  /// final config3 = SwiftConfig.fromMap({}, 'my_project');
  /// final config4 = SwiftConfig.fromMap(true, 'my_project');
  /// final config5 = SwiftConfig.fromMap(null, 'my_project');
  ///
  /// // Custom output path
  /// final config6 = SwiftConfig.fromMap({
  ///   'out': 'custom/path/output.swift'
  /// });
  /// ```
  factory SwiftConfig.fromMap(dynamic map, [String? outFolder]) {
    if (map == false || (map == null && !Directory('ios').existsSync())) {
      return SwiftConfig._internal();
    }

    final config = map is Map ? map : <String, dynamic>{};
    final parts = outFolder?.split('/').map((part) => part.capitalize());
    final defaultPath = join('ios/Runner', parts?.join('/'));

    return SwiftConfig._internal(
      out: OutputConfig.fromOptions(
        config['out'] as String? ?? defaultPath,
        extension: 'swift',
        pascalCase: true,
      ),
      options: config['options'] as Map<String, dynamic>?,
    );
  }

  /// Returns the Swift options for the given input.
  ///
  /// Parameters:
  /// - [input]: The input file name to generate options for
  ///
  /// Returns:
  /// - `null` if no options are configured
  /// - A [SwiftOptions] instance with the provided options
  ///
  /// Having multiple files can lead to class name conflicts, therefore, the
  /// options include an `errorClassName` that is unique to each input file.
  ///
  /// Example:
  /// ```dart
  /// final config = SwiftConfig.fromMap({
  ///   'options': {
  ///     'copyright_header': ['Copyright Header'],
  ///     'include_error_class': true,
  ///   },
  /// });
  ///
  /// final options = config.getOptions('my_api');
  /// ```
  SwiftOptions? getOptions(String input) {
    if (_options == null) return null;

    return SwiftOptions(
      copyrightHeader: _options['copyright_header'] as Iterable<String>?,
      errorClassName: '${input.pascalCase}Error',
      includeErrorClass: _options['include_error_class'] as bool? ?? true,
    );
  }
}
