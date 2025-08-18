import 'package:path/path.dart' as path;

import 'output_config.dart';

/// Configuration for AST (Abstract Syntax Tree) generation.
class AstConfig {
  AstConfig._internal({this.out});

  /// Configuration for AST debugging output.
  final OutputConfig? out;

  /// Creates a [AstConfig] instance from a map.
  ///
  /// If map is `false` or `null`, it returns an [AstConfig] with null values.
  factory AstConfig.fromMap(dynamic map, [String? outFolder]) {
    if (map == false || map == null) return AstConfig._internal();

    map = map is Map ? map : <String, dynamic>{};

    final defaultPath = path.join('ast', outFolder);

    return AstConfig._internal(
      out: OutputConfig.fromOptions(
        map['out'] as String? ?? defaultPath,
        extension: 'ast',
      ),
    );
  }
}
