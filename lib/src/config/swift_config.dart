import 'package:pigeon/pigeon.dart';

import 'base_config.dart';
import 'output_config.dart';

final class SwiftConfig extends BaseConfig {
  SwiftConfig._internal({this.out, this.options});

  final OutputConfig? out;

  final SwiftOptions? options;

  static SwiftConfig? fromMap(Map<String, dynamic>? map) {
    return null;
  }
}
