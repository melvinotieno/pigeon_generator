import 'package:pigeon/pigeon.dart';

import 'base_config.dart';
import 'output_config.dart';

final class KotlinConfig extends BaseConfig {
  KotlinConfig._internal({this.out, this.options});

  final OutputConfig? out;

  final KotlinOptions? options;

  static KotlinConfig? fromMap(Map<String, dynamic>? map) {
    return null;
  }
}
