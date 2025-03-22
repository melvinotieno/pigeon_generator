import 'package:pigeon/pigeon.dart';

import 'base_config.dart';
import 'output_config.dart';

final class DartConfig extends BaseConfig {
  DartConfig._internal({
    this.out,
    this.testOut,
    this.packageName,
    this.options,
  });

  /// Path to the Dart file that will be generated.
  final OutputConfig? out;

  /// Path to the Dart file that will be generated for test support classes.
  final OutputConfig? testOut;

  /// The name of the package the pigeon files will be used in.
  final String? packageName;

  /// Options that control how Dart code will be generated.
  final DartOptions? options;

  static DartConfig? fromMap(dynamic map) {
    if (map == null) return null;

    return DartConfig._internal(
      out: OutputConfig.fromOptions('path', extension: 'dart'),
      testOut: OutputConfig.fromOptions(
        'path',
        extension: 'dart',
        append: '_test',
      ),
      packageName: map?['package_name'] as String?,
      options: DartOptions.fromMap(map['options']),
    );
  }
}
