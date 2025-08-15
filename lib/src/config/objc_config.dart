import 'dart:io';

import 'output_config.dart';

/// Configuration for Objective-C code generation.
final class ObjcConfig {
  ObjcConfig._internal({this.headerOut, this.sourceOut});

  /// Configuration for the ".h" Objective-C file that will be generated.
  final OutputConfig? headerOut;

  /// Configuration for the ".m" Objective-C file that will be generated.
  final OutputConfig? sourceOut;

  /// Creates a [ObjcConfig] instance from a map.
  ///
  /// If the map is `false`, or `null` and the "macos" directory does not
  /// exist, it returns a [ObjcConfig] with null values. Otherwise, it
  /// returns a [ObjcConfig] with default values.
  factory ObjcConfig.fromMap(dynamic map) {
    if (map == false || (map == null && !Directory('macos').existsSync())) {
      return ObjcConfig._internal();
    }

    map = map is Map ? map : <String, dynamic>{};

    return ObjcConfig._internal(
      headerOut: OutputConfig.fromOptions(
        map['header_out'] as String? ?? 'macos',
        extension: 'h',
      ),
      sourceOut: OutputConfig.fromOptions(
        map['source_out'] as String? ?? 'macos',
        extension: 'm',
      ),
    );
  }
}
