import 'package:pigeon/pigeon.dart';

import 'base_config.dart';
import 'output_config.dart';

final class CppConfig extends BaseConfig {
  CppConfig._internal({this.headerOut, this.sourceOut, this.options});

  final OutputConfig? headerOut;

  final OutputConfig? sourceOut;

  final CppOptions? options;

  static CppConfig? fromMap(dynamic map) {
    if (map == null) return null;
    return null;
  }
}
