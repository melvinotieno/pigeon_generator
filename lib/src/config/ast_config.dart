import 'base_config.dart';
import 'output_config.dart';

final class AstConfig extends BaseConfig {
  AstConfig._internal({this.out});

  final OutputConfig? out;

  static AstConfig? fromMap(Map<String, dynamic>? map) {
    if (map == null) return null;

    return null;
  }
}
