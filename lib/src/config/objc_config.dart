import 'package:path/path.dart' show join;
import 'package:pigeon/pigeon.dart';

import 'output_config.dart';

/// Configuration for Objective-C code generation.
final class ObjcConfig {
  ObjcConfig._internal({
    this.headerOut,
    this.sourceOut,
    Map<String, dynamic>? options,
  }) : _options = options;

  /// Configuration for the ".h" Objective-C file that will be generated.
  final OutputConfig? headerOut;

  /// Configuration for the ".m" Objective-C file that will be generated.
  final OutputConfig? sourceOut;

  /// Options that control how Objective-C code is generated.
  final Map<String, dynamic>? _options;

  /// Creates a [ObjcConfig] instance from a map.
  ///
  /// Parameters:
  /// - [map]: The configuration map containing Objective-C settings. Can be:
  ///   - `false` or `null`: Disables Objective-C code generation
  ///   - `Map`: Contains configuration options for Objective-C code generation
  ///   - Any other type: Treated as an empty configuration map
  /// - [outFolder]: Optional folder path for output files. If provided, the
  ///   default Objective-C output path will be 'macos/Runner/{outFolder}'
  ///
  /// Returns:
  /// - An [ObjcConfig] with null values if [map] is `null` or `false`
  /// - An [ObjcConfig] with the default or provided map configuration
  ///
  /// Example:
  /// ```dart
  /// // Disable Objective-C code generation
  /// final config1 = ObjcConfig.fromMap(null);
  /// final config2 = ObjcConfig.fromMap(false);
  ///
  /// // Enable with default settings
  /// final config3 = ObjcConfig.fromMap({}, 'my_project');
  /// final config4 = ObjcConfig.fromMap(true, 'my_project');
  ///
  /// // Custom output path
  /// final config5 = ObjcConfig.fromMap({
  ///   'header_out': 'custom/path/header.h',
  ///   'source_out': 'custom/path/source.m'
  /// });
  /// ```
  factory ObjcConfig.fromMap(dynamic map, [String? outFolder]) {
    if (map == false || map == null) return ObjcConfig._internal();

    final config = map is Map ? map : <String, dynamic>{};
    final parts = outFolder?.split('/').map((part) => part.capitalize());
    final defaultPath = join('macos/Runner', parts?.join('/'));

    return ObjcConfig._internal(
      headerOut: OutputConfig.fromOptions(
        config['header_out'] as String? ?? defaultPath,
        extension: 'h',
      ),
      sourceOut: OutputConfig.fromOptions(
        config['source_out'] as String? ?? defaultPath,
        extension: 'm',
      ),
      options: config['options'] as Map<String, dynamic>?,
    );
  }

  /// Returns the Objective-C options for the given input.
  ///
  /// Parameters:
  /// - [input]: The input file name to generate options for
  ///
  /// Returns:
  /// - `null` if no options are configured
  /// - A [ObjcOptions] instance with the provided options
  ///
  /// Example:
  /// ```dart
  /// final config = ObjcOptions.fromMap({
  ///   'options': {
  ///     'header_include': 'custom/include',
  ///     'prefix': 'Prefix',
  ///     'copyright_header': ['Copyright Header'],
  ///   },
  /// });
  ///
  /// final options = config.getOptions('my_api');
  /// ```
  ObjcOptions? getOptions(String input) {
    if (_options == null) return null;

    final headerInclude = _options['header_include'] as String?;

    return ObjcOptions(
      headerIncludePath: headerInclude?.let((path) => join(path, '$input.h')),
      prefix: _options['prefix'] as String?,
      copyrightHeader: _options['copyright_header'] as Iterable<String>?,
    );
  }
}
