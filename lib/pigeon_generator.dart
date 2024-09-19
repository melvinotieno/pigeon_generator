library;

import 'package:build/build.dart';

import 'src/pigeon_builder.dart';
import 'src/pigeon_extensions.dart';

Builder pigeonBuilder(BuilderOptions options) {
  final config = options.config;

  final platforms = (config['platforms'] as List? ?? []).toSet();

  final platformOutputs = {
    'cpp': platforms.contains('windows'),
    'gobject': platforms.contains('linux'),
    'kotlin': platforms.contains('android:kotlin'),
    'java': platforms.contains('android:java'),
    'swift': platforms.contains('ios'),
    'objc': platforms.contains('macos'),
  };

  final pigeonConfig = PigeonExtension.loadConfig(
    platformOutputs,
    ast: config['ast'] ?? false,
    dartTest: config['dart_test'] ?? false,
    debugGenerators: config['debug_generators'] ?? false,
  );

  return PigeonBuilder(pigeonConfig);
}
