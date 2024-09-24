import 'package:build/build.dart';
import 'package:pigeon_generator/src/pigeon_config.dart';
import 'package:test/test.dart';

void main() {
  group('PigeonConfig', () {
    test('should create PigeonConfig from BuilderOptions', () {
      final options = BuilderOptions({
        'dart': {'out': 'lib'},
        'cpp': {'header_out': 'windows/runner'},
        'gobject': {'header_out': 'linux'},
        'kotlin': {'out': 'src/main/kotlin/com/example'},
        'java': {'out': 'src/main/java/com/example'},
        'swift': {'out': 'ios/Runner'},
        'objc': {'header_out': 'macos/Runner'},
        'ast': {'out': 'output'},
        'debug_generators': true,
        'base_path': 'base/path',
        'one_language': true,
      });

      final config = PigeonConfig.fromBuilderOptions(options);

      expect(config.inputs, 'pigeons');
      expect(config.dart?.out, 'lib');
      expect(config.cpp?.headerOut, 'windows/runner');
      expect(config.gobject?.headerOut, 'linux');
      expect(config.kotlin?.out, 'src/main/kotlin/com/example');
      expect(config.java?.out, 'src/main/java/com/example');
      expect(config.swift?.out, 'ios/Runner');
      expect(config.objc?.headerOut, 'macos/Runner');
      expect(config.ast?.out, 'output');
      expect(config.debugGenerators, isTrue);
      expect(config.basePath, 'base/path');
      expect(config.oneLanguage, isTrue);
    });
  });
}
