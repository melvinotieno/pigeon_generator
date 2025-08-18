import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:pigeon/pigeon.dart';

import 'output_config.dart';

/// Configuration for Swift code generation.
class SwiftConfig {
  SwiftConfig._internal({this.out, Map<String, dynamic>? options})
    : _options = options;

  /// Configuration for the ".swift" file that will be generated.
  final OutputConfig? out;

  /// Options that control how Swift will be generated.
  final Map<String, dynamic>? _options;

  /// Creates a [SwiftConfig] instance from a map.
  ///
  /// If the map is `false`, or `null` and the "ios" directory does not exist,
  /// it returns a [SwiftConfig] with null values. Otherwise, it returns a
  /// [SwiftConfig] with default values.
  factory SwiftConfig.fromMap(dynamic map, [String? outFolder]) {
    if (map == false || (map == null && !Directory('ios').existsSync())) {
      return SwiftConfig._internal();
    }

    map = map is Map ? map : <String, dynamic>{};

    final defaultPath = path.join('ios/Runner', outFolder);

    return SwiftConfig._internal(
      out: OutputConfig.fromOptions(
        map['out'] as String? ?? defaultPath,
        extension: 'swift',
        pascalCase: true,
      ),
      options: map['options'] as Map<String, dynamic>?,
    );
  }

  /// Returns the Swift options for the given file name.
  SwiftOptions? getOptions(String fileName) {
    if (_options == null) return null;

    return SwiftOptions(
      copyrightHeader: _options['copyright_header'] as Iterable<String>?,
      includeErrorClass: _options['include_error_class'] as bool? ?? true,
      errorClassName: '${fileName.pascalCase}Error',
    );
  }
}
