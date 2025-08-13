import 'dart:io';

import 'output_config.dart';

/// Configuration for C++ code generation.
class CppConfig {
  CppConfig._internal({this.headerOut, this.sourceOut});

  /// Configuration for the ".h" C++ file that will be generated.
  final OutputConfig? headerOut;

  /// Configuration for the ".cpp" C++ file that will be generated.
  final OutputConfig? sourceOut;

  /// Creates a [CppConfig] instance from a map.
  ///
  /// If the map is `false`, or `null` and the "windows" directory does not
  /// exist, it returns a [CppConfig] with null values. Otherwise, it returns
  /// a [CppConfig] with default values.
  factory CppConfig.fromMap(dynamic map) {
    if (map == false || (map == null && !Directory('windows').existsSync())) {
      return CppConfig._internal();
    }

    map = map is Map ? map : <String, dynamic>{};

    return CppConfig._internal(
      headerOut: OutputConfig.fromOptions(
        map['header_out'] as String? ?? 'windows/runner',
        extension: 'h',
      ),
      sourceOut: OutputConfig.fromOptions(
        map['source_out'] as String? ?? 'windows/runner',
        extension: 'cpp',
      ),
    );
  }
}
