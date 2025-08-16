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
      test('should return empty config when map is false', () {
        final config = DartConfig.fromMap(false);

        expect(config.out, isNull);
        expect(config.testOut, isNull);
        expect(config.packageName, isNull);
        expect(config.getOptions('test_file'), isNull);
      });

      test('should return default config when map is null', () {
        final config = DartConfig.fromMap(null);
        final out = config.out!;

        expect(out.path, 'lib');
        expect(out.extension, 'dart');
        expect(out.pascalCase, isFalse);
        expect(out.append, isNull);
        expect(config.testOut, isNull); // No test directory exists
        expect(config.packageName, isNull);
        expect(config.getOptions('test_file'), isNull);
      });

      test('should create config with default values for missing fields', () {
        final config = DartConfig.fromMap({});
        final out = config.out!;

        expect(out.path, 'lib');
        expect(out.extension, 'dart');
        expect(out.pascalCase, isFalse);
        expect(out.append, isNull);
        expect(config.testOut, isNull); // No test directory exists
        expect(config.packageName, isNull);
        expect(config.getOptions('test_file'), isNull);
      });

      test('should create config with provided values', () {
        final map = {
          'out': 'custom/lib',
          'test_out': 'custom/test',
          'package_name': 'dart_package',
        };

        final config = DartConfig.fromMap(map);
        final out = config.out!;
        final testOut = config.testOut!;

        expect(out.path, 'custom/lib');
        expect(out.extension, 'dart');
        expect(out.pascalCase, isFalse);
        expect(out.append, isNull);
        expect(testOut.path, 'custom/test');
        expect(testOut.extension, 'dart');
        expect(testOut.pascalCase, isFalse);
        expect(testOut.append, '_test');
        expect(config.packageName, equals('dart_package'));
      });

      test('should handle test_out as false', () {
        final config = DartConfig.fromMap({'test_out': false});

        expect(config.testOut, isNull);
      });

      test('should handle test_out when test directory exists', () async {
        await Directory('test').create();

        final config = DartConfig.fromMap({'test_out': 'custom_test'});
        final testOut = config.testOut!;

        expect(testOut.path, 'custom_test');
        expect(testOut.extension, 'dart');
        expect(testOut.pascalCase, isFalse);
        expect(testOut.append, '_test');
      });
    });

    group('getOptions', () {
      test('should return null when no options provided', () {
        final config = DartConfig.fromMap({'out': 'lib'});

        expect(config.getOptions('file'), isNull);
      });

      test('should return DartOptions with paths when options provided', () {
        final map = {
          'options': {
            'source_out': 'src/generated',
            'test_out': 'test/generated',
            'copyright_header': ['Copyright 2024'],
          },
        };

        final config = DartConfig.fromMap(map);
        final options = config.getOptions('file')!;

        expect(options.sourceOutPath, equals('src/generated/file.dart'));
        expect(options.testOutPath, equals('test/generated/file_test.dart'));
        expect(options.copyrightHeader, contains('Copyright 2024'));
      });

      test('should handle partial options', () {
        final map = {
          'options': {'source_out': 'src/generated'},
        };

        final config = DartConfig.fromMap(map);
        final options = config.getOptions('file')!;

        expect(options.sourceOutPath, equals('src/generated/file.dart'));
        expect(options.testOutPath, isNull);
      });
    });
  });
}
