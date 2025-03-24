import 'package:pigeon_generator/src/config/dart_config.dart';
import 'package:test/test.dart';

void main() {
  group('DartConfig', () {
    test('should return null if config map is false', () {
      final config = DartConfig.fromMap(false);

      expect(config, isNull);
    });

    test('should create DartConfig from config map', () {
      final config = <String, dynamic>{'out': 'path/to/output'};

      final dartConfig = DartConfig.fromMap(config);

      expect(dartConfig?.out?.path, isNotNull);
      expect(dartConfig?.out?.path, config['out']);
      expect(dartConfig?.out?.extension, 'dart');
      expect(dartConfig?.out?.pascalCase, isFalse);
      expect(dartConfig?.out?.append, isNull);
    });
  });
}
