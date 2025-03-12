library;

import 'package:build/build.dart';

import 'src/pigeon_builder.dart';
import 'src/pigeon_config.dart';
import 'src/pigeon_validator.dart';

/// Creates a [PigeonBuilder] using the provided [BuilderOptions].
///
/// This function extracts the [PigeonConfig] from the [BuilderOptions] config,
/// validates the configuration, and then returns a [PigeonBuilder] instance
/// initialized with the validated configuration.
///
/// [options] - The [BuilderOptions] provided to the builder.
///
/// Returns a [PigeonBuilder] instance with the validated [PigeonConfig].
Builder pigeonBuilder(BuilderOptions options) {
  final pigeonConfig = PigeonConfig.fromMap(options.config);

  // Validate the pigeon config first.
  PigeonValidator.validate(pigeonConfig);

  return PigeonBuilder(pigeonConfig);
}
