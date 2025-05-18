import 'package:pigeon_generator/src/config/dart_config.dart';
import 'package:test/test.dart';

void main() {
  group('DartConfig', () {
    test('should create DartConfig of null values when map is false', () {
      final dartConfig = DartConfig.fromMap(false);

      expect(dartConfig.out, isNull);
      expect(dartConfig.testOut, isNull);
      expect(dartConfig.packageName, isNull);
      expect(dartConfig.options, isNull);
    });

    test('should create DartConfig with defaults for missing fields', () {
      final dartConfig = DartConfig.fromMap({});

      expect(dartConfig.out?.path, 'lib');
      expect(dartConfig.out?.extension, 'dart');
      expect(dartConfig.out?.pascalCase, isFalse);
      expect(dartConfig.out?.append, isNull);
      expect(dartConfig.testOut?.path, 'test');
      expect(dartConfig.testOut?.extension, 'dart');
      expect(dartConfig.testOut?.pascalCase, isFalse);
      expect(dartConfig.testOut?.append, '_test');
      expect(dartConfig.packageName, isNull);
      expect(dartConfig.options, isNull);
    });

    test('should create DartConfig with default values for null map', () {
      final dartConfig = DartConfig.fromMap(null);

      expect(dartConfig.out?.path, 'lib');
      expect(dartConfig.out?.extension, 'dart');
      expect(dartConfig.out?.pascalCase, isFalse);
      expect(dartConfig.out?.append, isNull);
      expect(dartConfig.testOut?.path, 'test');
      expect(dartConfig.testOut?.extension, 'dart');
      expect(dartConfig.testOut?.pascalCase, isFalse);
      expect(dartConfig.testOut?.append, '_test');
      expect(dartConfig.packageName, isNull);
      expect(dartConfig.options, isNull);
    });

    test('should create DartConfig from config map', () {
      final config = <String, dynamic>{
        'out': 'path/to/output',
        'test_out': 'path/to/test',
        'package_name': 'package_name',
        'options': {
          'copyright_header': ['Copyright 2024'],
          'source_out_path': 'path/to/source',
          'test_out_path': 'path/to/test',
        }
      };

      final dartConfig = DartConfig.fromMap(config);
      final options = config['options'] as Map<String, dynamic>;

      expect(dartConfig.out?.path, config['out']);
      expect(dartConfig.out?.extension, 'dart');
      expect(dartConfig.out?.pascalCase, isFalse);
      expect(dartConfig.out?.append, isNull);
      expect(dartConfig.testOut?.path, config['test_out']);
      expect(dartConfig.testOut?.extension, 'dart');
      expect(dartConfig.testOut?.pascalCase, isFalse);
      expect(dartConfig.testOut?.append, '_test');
      expect(dartConfig.packageName, config['package_name']);
      expect(dartConfig.options?.copyrightHeader, options['copyright_header']);
      expect(dartConfig.options?.sourceOutPath, options['source_out_path']);
      expect(dartConfig.options?.testOutPath, options['test_out_path']);
    });
  });
}
