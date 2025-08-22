import 'dart:io';

import 'package:path/path.dart' show join;
import 'package:pigeon/pigeon.dart';

import 'output_config.dart';

/// Configuration for the GObject code generation.
class GObjectConfig {
  GObjectConfig._internal({
    this.headerOut,
    this.sourceOut,
    Map<String, dynamic>? options,
  }) : _options = options;

  /// Configuration for the ".h" GObject file that will be generated.
  final OutputConfig? headerOut;

  /// Configuration for the ".cc" GObject file that will be generated.
  final OutputConfig? sourceOut;

  /// Options that control how GObject code will be generated.
  final Map<String, dynamic>? _options;

  /// Creates a [GObjectConfig] instance from a map.
  ///
  /// Parameters:
  /// - [map]: The configuration map containing GObject settings. Can be:
  ///   - `false`: Explicitly disables GObject code generation
  ///   - `null`: Disables code generation unless 'linux' directory exists
  ///   - `Map`: Contains configuration options for GObject code generation
  ///   - Any other type: Treated as an empty configuration map
  /// - [outFolder]: Optional base folder path for output files. If provided,
  ///   the default GObject output path will be 'linux/{outFolder}'
  ///
  /// Returns:
  /// - A [GObjectConfig] with null values if [map] is `false`
  /// - A [GObjectConfig] with the default or provided map configuration
  ///
  /// Example:
  /// ```dart
  /// // Disable GObject code generation
  /// final config1 = GObjectConfig.fromMap(null); // If 'linux' does not exist
  /// final config2 = GObjectConfig.fromMap(false);
  ///
  /// // Enable with default settings
  /// final config3 = GObjectConfig.fromMap({}, 'my_project');
  /// final config4 = GObjectConfig.fromMap(true, 'my_project');
  /// final config5 = GObjectConfig.fromMap(null, 'my_project');
  ///
  /// // Custom output path
  /// final config6 = GObjectConfig.fromMap({
  ///   'header_out': 'custom/path',
  ///   'source_out': 'custom/path',
  /// });
  /// ```
  factory GObjectConfig.fromMap(dynamic map, [String? outFolder]) {
    if (map == false || (map == null && !Directory('linux').existsSync())) {
      return GObjectConfig._internal();
    }

    final config = map is Map ? map : <String, dynamic>{};
    final defaultPath = join('linux', outFolder);

    return GObjectConfig._internal(
      headerOut: OutputConfig.fromOptions(
        config['header_out'] as String? ?? defaultPath,
        extension: 'h',
      ),
      sourceOut: OutputConfig.fromOptions(
        config['source_out'] as String? ?? defaultPath,
        extension: 'cc',
      ),
      options: config['options'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Returns the GObject options for the given input.
  ///
  /// Parameters:
  /// - [input]: The input file name to generate options for
  ///
  /// Returns:
  /// - `null` if no options are configured
  /// - A [GObjectOptions] instance with the configured options
  ///
  /// Example:
  /// ```dart
  /// final config = GObjectConfig.fromMap({
  ///   'header_out': 'custom/path',
  ///   'source_out': 'custom/path',
  ///   'options': {
  ///     'header_include': 'custom/include',
  ///     'module': 'CustomModule',
  ///     'copyright_header': ['Copyright Header'],
  ///     'header_out': 'custom/out',
  ///   }
  /// });
  ///
  /// final options = config.getOptions('my_api');
  /// ```
  GObjectOptions? getOptions(String input) {
    if (_options == null) return null;

    final headerInclude = _options['header_include'] as String?;
    final headerOut = _options['header_out'] as String?;

    return GObjectOptions(
      headerIncludePath: headerInclude?.let((path) => join(path, '$input.h')),
      module: _options['module'] as String?,
      copyrightHeader: _options['copyright_header'] as Iterable<String>?,
      headerOutPath: headerOut?.let((path) => join(path, '$input.h')),
    );
  }
}
