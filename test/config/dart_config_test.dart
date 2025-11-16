import 'dart:io';

import 'package:pigeon_generator/src/config/dart_config.dart';
import 'package:test/test.dart';

void main() {
  group('DartConfig', () {
    late Directory tempDir;
    late String originalDir;

    setUpAll(() async {
      originalDir = Directory.current.path;
      tempDir = await Directory.systemTemp.createTemp('dart_config_test_');
      Directory.current = tempDir;
    });

    tearDownAll(() async {
      Directory.current = originalDir;

      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    group('fromMap', () {
      test('should return null values when map is false', () {
        final config = DartConfig.fromMap(false);

        expect(config.out, isNull);
        expect(config.packageName, isNull);
        expect(config.getOptions('test_file'), isNull);
      });

      test('should return config with provided values', () {
        final map = {
          'out': 'custom/lib',
          'test_out': 'custom/test',
          'package_name': 'dart_package',
        };

        // Tests without base folder path
        DartConfig config = DartConfig.fromMap(map);

        expect(config.out?.path, equals('custom/lib'));
        expect(config.out?.extension, equals('dart'));
        expect(config.out?.pascalCase, isFalse);
        expect(config.out?.append, isNull);
        expect(config.packageName, equals('dart_package'));
        expect(config.getOptions('test_file'), isNull);

        // Tests with base folder path
        config = DartConfig.fromMap(map, 'my_project');

        expect(config.out?.path, equals('custom/lib'));
        expect(config.out?.extension, equals('dart'));
        expect(config.out?.pascalCase, isFalse);
        expect(config.out?.append, isNull);
        expect(config.packageName, equals('dart_package'));
        expect(config.getOptions('test_file'), isNull);
      });

      test('should return default values when map is of any other type', () {
        // Tests for null value
        DartConfig config = DartConfig.fromMap(null);

        expect(config.out?.path, equals('lib'));
        expect(config.out?.extension, equals('dart'));
        expect(config.out?.pascalCase, isFalse);
        expect(config.out?.append, isNull);
        expect(config.packageName, isNull);
        expect(config.getOptions('test_file'), isNull);

        // Tests for true value
        config = DartConfig.fromMap(true, 'my_project');

        expect(config.out?.path, equals('lib/my_project'));
        expect(config.out?.extension, equals('dart'));
        expect(config.out?.pascalCase, isFalse);
        expect(config.out?.append, isNull);
        expect(config.packageName, isNull);
        expect(config.getOptions('test_file'), isNull);
      });
    });

    group('getOptions', () {
      test('should return options with provided values', () {
        final map = {
          'options': {
            'source_out': 'src/generated',
            'test_out': 'test/generated',
            'copyright_header': ['Copyright 2024'],
          },
        };

        final config = DartConfig.fromMap(map);
        final options = config.getOptions('file');

        expect(options?.sourceOutPath, equals('src/generated/file.dart'));
        expect(options?.testOutPath, equals('test/generated/file_test.dart'));
        expect(options?.copyrightHeader, contains('Copyright 2024'));
      });
    });
  });
}
