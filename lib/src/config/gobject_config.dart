import 'dart:io';

import 'output_config.dart';

/// Configuration for the GObject code generation.
class GObjectConfig {
  GObjectConfig._internal({this.headerOut, this.sourceOut});

  /// Configuration for the ".h" GObject file that will be generated.
  final OutputConfig? headerOut;

  /// Configuration for the ".cc" GObject file that will be generated.
  final OutputConfig? sourceOut;

  /// Creates a [GObjectConfig] instance from a map.
  ///
  /// If the map is `false`, or `null` and the "linux" directory does not
  /// exist, it returns a [GObjectConfig] with null values. Otherwise, it
  /// returns a [GObjectConfig] with default values.
  factory GObjectConfig.fromMap(dynamic map) {
    if (map == false || (map == null && !Directory('linux').existsSync())) {
      return GObjectConfig._internal();
    }

    map = map is Map ? map : <String, dynamic>{};

    return GObjectConfig._internal(
      headerOut: OutputConfig.fromOptions(
        map['header_out'] as String? ?? 'linux',
        extension: 'h',
      ),
      sourceOut: OutputConfig.fromOptions(
        map['source_out'] as String? ?? 'linux',
        extension: 'cc',
      ),
    );
  }
}
