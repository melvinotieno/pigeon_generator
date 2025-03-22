import 'package:pigeon/pigeon.dart';

import 'base_config.dart';
import 'output_config.dart';

final class ObjcConfig extends BaseConfig {
  ObjcConfig._internal({this.headerOut, this.sourceOut, this.options});

  final OutputConfig? headerOut;

  final OutputConfig? sourceOut;

  final ObjcOptions? options;

  static ObjcConfig? fromMap(Map<String, dynamic>? map) {
    return null;
  }
}
