import 'dart:io';

import 'package:pigeon/pigeon.dart';

import '../utilities/android.dart';
import 'output_config.dart';

/// Configuration for Kotlin code generation.
class KotlinConfig {
  KotlinConfig._internal({this.out, KotlinOptions? options})
    : _options = options;

  /// Configuration for the ".kt" file that will be generated.
  final OutputConfig? out;

  /// Options that control how Kotlin will be generated.
  final KotlinOptions? _options;

  /// Creates a [KotlinConfig] instance from a map.
  ///
  /// If the map is `false`, or `null` and the "android" directory does not exist,
  /// it returns a [KotlinConfig] with null values. Otherwise, it returns a
  /// [KotlinConfig] with default values.
  factory KotlinConfig.fromMap(dynamic map, [String? outFolder]) {
    if (map == false || (map == null && !Directory('android').existsSync())) {
      return KotlinConfig._internal();
    }

    map = map is Map ? map : <String, dynamic>{};

    final options = map['options'] as Map<String, dynamic>? ?? {};

    final android = Android().get(
      'kotlin',
      map['out'],
      outFolder,
      options['package'],
    );

    return KotlinConfig._internal(
      out: OutputConfig.fromOptions(
        android['outPath'],
        extension: 'kt',
        pascalCase: true,
      ),
      options: KotlinOptions(
        package: android['packageName'],
        copyrightHeader: options['copyright_header'] as Iterable<String>?,
        includeErrorClass: options['include_error_class'] as bool? ?? true,
      ),
    );
  }

  /// Returns the Kotlin options for the given file name.
  KotlinOptions? getOptions(String fileName) {
    if (_options == null) return null;

    return _options.merge(
      KotlinOptions(errorClassName: '${fileName.pascalCase}Error'),
    );
  }
}
