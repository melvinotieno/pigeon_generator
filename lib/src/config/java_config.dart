import 'package:pigeon/pigeon.dart';

import 'base_config.dart';
import 'output_config.dart';

final class JavaConfig extends BaseConfig {
  JavaConfig._internal({this.out, this.options});

  final OutputConfig? out;

  final JavaOptions? options;

  static JavaConfig? fromMap(Map<String, dynamic>? map) {
    return null;
  }
}
