import 'dart:io';

import 'package:pigeon/pigeon.dart';

import '../utilities/android.dart';
import 'output_config.dart';

/// Configuration for Kotlin code generation.
class KotlinConfig {
  KotlinConfig._internal({this.out, Map<String, dynamic>? options})
    : _options = options;

  /// Configuration for the ".kt" file that will be generated.
  final OutputConfig? out;

  /// Options that control how Kotlin will be generated.
  final Map<String, dynamic>? _options;

  /// Creates a [KotlinConfig] instance from a map.
  ///
  /// Parameters:
  /// - [map]: The configuration map containing Kotlin settings. Can be:
  ///   - `false`: Explicitly disables Kotlin code generation
  ///   - `null`: Disables code generation unless valid Android project exists
  ///   - `Map`: Contains configuration options for Kotlin code generation
  ///   - Any other type: Treated as an empty configuration map
  /// - [outFolder]: Optional folder path for output files. If provided, the
  ///   default Kotlin output path will be appended with [outFolder]
  ///
  /// Returns:
  /// - A [KotlinConfig] with null values if [map] is `false`
  /// - A [KotlinConfig] with the default or provided map configuration
  ///
  /// Example:
  /// ```dart
  /// // Disable Kotlin code generation
  /// final config1 = KotlinConfig.fromMap(null); // If project does not exist
  /// final config2 = KotlinConfig.fromMap(false);
  ///
  /// // Enable with default settings
  /// final config3 = KotlinConfig.fromMap({}, 'my_project');
  /// final config4 = KotlinConfig.fromMap(true, 'my_project');
  /// final config5 = KotlinConfig.fromMap(null, 'my_project');
  ///
  /// // Enable with provided configuration
  /// final config6 = KotlinConfig.fromMap({
  ///   'out': 'custom/path',
  ///   'options': {
  ///     'package': 'com.example.pigeon_example',
  ///     'copyright_header': ['Copyright Header'],
  ///     'include_error_class': true,
  ///   }
  /// });
  /// ```
  factory KotlinConfig.fromMap(dynamic map, [String? outFolder]) {
    if (map == false || (map == null && !Directory('android').existsSync())) {
      return KotlinConfig._internal();
    }

    final config = map is Map ? map : <String, dynamic>{};
    final options = config['options'] as Map<String, dynamic>? ?? {};

    final instance = Android(outFolder);
    final android = instance.get('kotlin', config['out'], options['package']);

    final resolvedOptions = <String, dynamic>{
      ...options,
      'package': android['packageName'],
    };

    return KotlinConfig._internal(
      out: OutputConfig.fromOptions(
        android['outPath'],
        extension: 'kt',
        pascalCase: true,
      ),
      options: resolvedOptions,
    );
  }

  /// Returns the Kotlin options for the given input.
  ///
  /// Parameters:
  /// - [input]: The input file name to generate options for
  ///
  /// Returns:
  /// - `null` if no options are configured
  /// - A [KotlinOptions] instance with the provided options
  ///
  /// Having multiple files can lead to class name conflicts, therefore, the
  /// options include an `errorClassName` that is unique to each input file.
  ///
  /// Example:
  /// ```dart
  /// final config = KotlinConfig.fromMap({
  ///   'options': {
  ///     'package': 'com.example.pigeon_example',
  ///     'copyright_header': ['Copyright Header'],
  ///     'include_error_class': true,
  ///   },
  /// });
  ///
  /// final options = config.getOptions('my_api');
  /// ```
  KotlinOptions? getOptions(String input) {
    if (_options == null) return null;

    return KotlinOptions(
      package: _options['package'] as String?,
      errorClassName: '${input.pascalCase}Error',
      copyrightHeader: _options['copyright_header'] as Iterable<String>?,
      includeErrorClass: _options['include_error_class'] as bool? ?? true,
    );
  }
}
