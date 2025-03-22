import 'package:pigeon/pigeon.dart';

import 'base_config.dart';
import 'output_config.dart';

final class GObjectConfig extends BaseConfig {
  GObjectConfig._internal({this.headerOut, this.sourceOut, this.options});

  final OutputConfig? headerOut;

  final OutputConfig? sourceOut;

  final GObjectOptions? options;

  static GObjectConfig? fromMap(Map<String, dynamic>? map) {
    return null;
  }
}
