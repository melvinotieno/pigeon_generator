import 'package:path/path.dart' show join;

import 'output_config.dart';

/// Configuration for AST (Abstract Syntax Tree) generation.
class AstConfig {
  AstConfig._internal({this.out});

  /// Configuration for AST debugging output.
  final OutputConfig? out;

  /// Creates a [AstConfig] instance from a map config.
  ///
  /// Parameters:
  /// - [map]: The configuration map containing AST settings. Can be:
  ///   - `null` or `false`: Disables AST generation
  ///   - `Map`: Contains configuration options for AST generation
  ///   - Any other type: Treated as an empty configuration map
  /// - [outFolder]: Optional base folder path for output files. If provided,
  ///   the default AST output path will be 'ast/{outFolder}'
  ///
  /// Returns:
  /// - An [AstConfig] with null values if [map] is `null` or `false`
  /// - An [AstConfig] with the default or provided map configuration
  ///
  /// Example:
  /// ```dart
  /// // Disable AST generation
  /// final config1 = AstConfig.fromMap(null);
  /// final config2 = AstConfig.fromMap(false);
  ///
  /// // Enable with default settings
  /// final config3 = AstConfig.fromMap({}, 'my_project');
  /// final config4 = AstConfig.fromMap(true, 'my_project');
  ///
  /// // Custom output path
  /// final config5 = AstConfig.fromMap({
  ///   'out': 'custom/path'
  /// });
  /// ```
  factory AstConfig.fromMap(dynamic map, [String? outFolder]) {
    if (map == false || map == null) return AstConfig._internal();

    final config = map is Map ? map : <String, dynamic>{};
    final defaultPath = join('ast', outFolder);

    return AstConfig._internal(
      out: OutputConfig.fromOptions(
        config['out'] as String? ?? defaultPath,
        extension: 'ast',
      ),
    );
  }
}
