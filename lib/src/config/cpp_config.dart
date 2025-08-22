import 'dart:io';

import 'package:path/path.dart' show join;
import 'package:pigeon/pigeon.dart';

import 'output_config.dart';

/// Configuration for C++ code generation.
class CppConfig {
  CppConfig._internal({
    this.headerOut,
    this.sourceOut,
    Map<String, dynamic>? options,
  }) : _options = options;

  /// Configuration for the ".h" C++ file that will be generated.
  final OutputConfig? headerOut;

  /// Configuration for the ".cpp" C++ file that will be generated.
  final OutputConfig? sourceOut;

  /// Options that control how C++ code will be generated.
  final Map<String, dynamic>? _options;

  /// Creates a [CppConfig] instance from a map.
  ///
  /// Parameters:
  /// - [map]: The configuration map containing C++ settings. Can be:
  ///   - `false`: Explicitly disables C++ code generation
  ///   - `null`: Disables code generation unless 'windows' directory exists
  ///   - `Map`: Contains configuration options for C++ code generation
  ///   - Any other type: Treated as an empty configuration map
  /// - [outFolder]: Optional base folder path for output files. If provided,
  ///   the default C++ output path will be 'windows/runner/{outFolder}'
  ///
  /// Returns:
  /// - A [CppConfig] with null values if [map] is `false`
  /// - A [CppConfig] with the default or provided map configuration
  ///
  /// Example:
  /// ```dart
  /// // Disable C++ code generation
  /// final config1 = CppConfig.fromMap(null); // If 'windows' does not exist
  /// final config2 = CppConfig.fromMap(false);
  ///
  /// // Enable with default settings
  /// final config3 = CppConfig.fromMap({}, 'my_project');
  /// final config4 = CppConfig.fromMap(true, 'my_project');
  /// final config5 = CppConfig.fromMap(null, 'my_project');
  ///
  /// // Custom output path
  /// final config6 = CppConfig.fromMap({
  ///   'header_out': 'custom/path',
  ///   'source_out': 'custom/path',
  /// });
  /// ```
  factory CppConfig.fromMap(dynamic map, [String? outFolder]) {
    if (map == false || (map == null && !Directory('windows').existsSync())) {
      return CppConfig._internal();
    }

    final configMap = map is Map ? map : <String, dynamic>{};
    final defaultPath = join('windows/runner', outFolder);

    return CppConfig._internal(
      headerOut: OutputConfig.fromOptions(
        configMap['header_out'] as String? ?? defaultPath,
        extension: 'h',
      ),
      sourceOut: OutputConfig.fromOptions(
        configMap['source_out'] as String? ?? defaultPath,
        extension: 'cpp',
      ),
      options: configMap['options'] as Map<String, dynamic>?,
    );
  }

  /// Returns the Cpp options for the given input.
  ///
  /// Parameters:
  /// - [input]: The input file name to generate options for
  ///
  /// Returns:
  /// - `null` if no options are configured
  /// - A [CppOptions] instance with the configured options
  ///
  /// Example:
  /// ```dart
  /// final config = CppConfig.fromMap({
  ///   'header_out': 'custom/path',
  ///   'source_out': 'custom/path',
  ///   'options': {
  ///     'header_include': 'custom/include',
  ///     'namespace': 'CustomNamespace',
  ///     'copyright_header': ['Copyright Header'],
  ///     'header_out': 'custom/out',
  ///   }
  /// });
  ///
  /// final options = config.getOptions('my_api');
  /// ```
  CppOptions? getOptions(String input) {
    if (_options == null) return null;

    final headerInclude = _options['header_include'] as String?;
    final headerOut = _options['header_out'] as String?;

    return CppOptions(
      headerIncludePath: headerInclude?.let((path) => join(path, '$input.h')),
      namespace: _options['namespace'] as String?,
      copyrightHeader: _options['copyright_header'] as Iterable<String>?,
      headerOutPath: headerOut?.let((path) => join(path, '$input.h')),
    );
  }
}
