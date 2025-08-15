import 'package:pigeon/pigeon.dart';

import '../utilities/android.dart';
import 'output_config.dart';

/// Configuration for Java code generation.
class JavaConfig {
  JavaConfig._internal({this.out, this.options});

  /// Configuration for the ".java" file that will be generated.
  final OutputConfig? out;

  /// Options that control how Java code will be generated.
  final JavaOptions? options;

  /// Creates a [JavaConfig] instance from a map.
  ///
  /// If the map is `null` or `false`, it returns a [JavaConfig] with null
  /// values. Otherwise, it returns [JavaConfig] with default values.
  ///
  /// When the map is null (no configuration passed), we do not check for the
  /// existence of the android folder because kotlin is the default language.
  factory JavaConfig.fromMap(dynamic map) {
    if (map == null || map == false) return JavaConfig._internal();

    map = map is Map ? map : <String, dynamic>{};

    final options = map['options'] as Map<String, dynamic>? ?? {};
    final android = Android().get('java', map['out'], options['package']);

    return JavaConfig._internal(
      out: OutputConfig.fromOptions(
        android['outPath'],
        extension: 'java',
        pascalCase: true,
      ),
      options: JavaOptions(
        package: android['packageName'],
        copyrightHeader: options['copyright_header'] as Iterable<String>?,
        useGeneratedAnnotation: options['use_generated_annotation'] as bool?,
      ),
    );
  }
}
