import 'package:pigeon/pigeon.dart';

import '../utilities/android.dart';
import 'output_config.dart';

/// Configuration for Java code generation.
class JavaConfig {
  JavaConfig._internal({this.out, Map<String, dynamic>? options})
    : _options = options;

  /// Configuration for the ".java" file that will be generated.
  final OutputConfig? out;

  /// Options that control how Java code will be generated.
  final Map<String, dynamic>? _options;

  /// Creates a [JavaConfig] instance from a map.
  ///
  /// Parameters:
  /// - [map]: The configuration map containing Java settings. Can be:
  ///   - `null` or `false`: Disables Java code generation
  ///   - `Map`: Contains configuration options for Java code generation
  ///   - Any other type: Treated as an empty configuration map
  /// - [outFolder]: Optional folder path for output files. If provided, the
  ///   default Java output path will be appended with [outFolder]
  ///
  /// Returns:
  /// - A [JavaConfig] with null values if [map] is `null` or `false`
  /// - A [JavaConfig] with the provided or default map configuration
  ///
  /// Example:
  /// ```dart
  /// // Disable Java code generation
  /// final config1 = JavaConfig.fromMap(null);
  /// final config2 = JavaConfig.fromMap(false);
  ///
  /// // Enable with default settings picked from Android project
  /// final config3 = JavaConfig.fromMap({}, 'my_project');
  /// final config4 = JavaConfig.fromMap(true, 'my_project');
  ///
  /// // Enable with provided configuration
  /// final config5 = JavaConfig.fromMap({
  ///   'out': 'custom/path',
  ///   'options': {
  ///     'package': 'com.example.pigeon_example',
  ///     'copyright_header': ['Copyright Header'],
  ///     'use_generated_annotation': true,
  ///   }
  /// });
  /// ```
  factory JavaConfig.fromMap(dynamic map, [String? outFolder]) {
    if (map == null || map == false) return JavaConfig._internal();

    final config = map is Map ? map : <String, dynamic>{};
    final options = config['options'] as Map<String, dynamic>? ?? {};

    final instance = Android(outFolder);
    final android = instance.get('java', config['out'], options['package']);

    final resolvedOptions = <String, dynamic>{
      ...options,
      'package': android['packageName'],
    };

    return JavaConfig._internal(
      out: OutputConfig.fromOptions(
        android['outPath'],
        extension: 'java',
        pascalCase: true,
      ),
      options: resolvedOptions,
    );
  }

  /// Returns the Java options for the given input.
  ///
  /// Parameters:
  /// - [input]: The input file name to generate options for
  ///
  /// Returns:
  /// - `null` if no options are configured
  /// - A [JavaOptions] instance with the provided options
  ///
  /// Example:
  /// ```dart
  /// final config = JavaConfig.fromMap({
  ///   'options': {
  ///     'package': 'com.example.pigeon_example',
  ///     'copyright_header': ['Copyright Header'],
  ///     'use_generated_annotation': true,
  ///   }
  /// });
  ///
  /// final options = config.getOptions('my_api');
  /// ```
  JavaOptions? getOptions(String input) {
    if (_options == null) return null;

    return JavaOptions(
      package: _options['package'] as String?,
      copyrightHeader: _options['copyright_header'] as Iterable<String>?,
      useGeneratedAnnotation: _options['use_generated_annotation'] as bool?,
    );
  }
}
