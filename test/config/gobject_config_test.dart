import 'dart:io';

import 'package:pigeon_generator/src/config/gobject_config.dart';
import 'package:test/test.dart';

void main() {
  group('GObjectConfig', () {
    late Directory tempDir;
    late String originalDir;

    setUpAll(() async {
      originalDir = Directory.current.path;
      tempDir = await Directory.systemTemp.createTemp('gobject_config_test_');
      Directory.current = tempDir;
    });

    tearDownAll(() async {
      Directory.current = originalDir;

      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    group('fromMap', () {
      test('should return null values when disabled', () {
        // Tests for null value
        GObjectConfig config = GObjectConfig.fromMap(null);

        expect(config.headerOut, isNull);
        expect(config.sourceOut, isNull);
        expect(config.getOptions('test_file'), isNull);

        // Tests for false value
        config = GObjectConfig.fromMap(false);

        expect(config.headerOut, isNull);
        expect(config.sourceOut, isNull);
        expect(config.getOptions('test_file'), isNull);
      });

      test('should return config with provided values', () {
        final map = {
          'header_out': 'path/to/header',
          'source_out': 'path/to/source',
        };

        // Tests without base folder path
        GObjectConfig config = GObjectConfig.fromMap(map);

        expect(config.headerOut?.path, equals('path/to/header'));
        expect(config.headerOut?.extension, equals('h'));
        expect(config.headerOut?.pascalCase, isFalse);
        expect(config.headerOut?.append, isNull);
        expect(config.sourceOut?.path, equals('path/to/source'));
        expect(config.sourceOut?.extension, equals('cc'));
        expect(config.sourceOut?.pascalCase, isFalse);
        expect(config.sourceOut?.append, isNull);

        // Tests with base folder path
        config = GObjectConfig.fromMap(map, 'my_project');

        expect(config.headerOut?.path, equals('path/to/header'));
        expect(config.headerOut?.extension, equals('h'));
        expect(config.headerOut?.pascalCase, isFalse);
        expect(config.headerOut?.append, isNull);
        expect(config.sourceOut?.path, equals('path/to/source'));
        expect(config.sourceOut?.extension, equals('cc'));
        expect(config.sourceOut?.pascalCase, isFalse);
        expect(config.sourceOut?.append, isNull);
      });

      test('should return default values for any other type', () async {
        // Tests for true value
        GObjectConfig config = GObjectConfig.fromMap(true);

        expect(config.headerOut?.path, equals('linux'));
        expect(config.headerOut?.extension, equals('h'));
        expect(config.headerOut?.pascalCase, isFalse);
        expect(config.headerOut?.append, isNull);
        expect(config.sourceOut?.path, equals('linux'));
        expect(config.sourceOut?.extension, equals('cc'));
        expect(config.sourceOut?.pascalCase, isFalse);
        expect(config.sourceOut?.append, isNull);

        // For null to return default values, there needs to exist a linux
        // directory in the root of the project.
        await Directory('linux').create();

        // Tests for null values
        config = GObjectConfig.fromMap(null, 'my_project');

        expect(config.headerOut?.path, equals('linux/my_project'));
        expect(config.headerOut?.extension, equals('h'));
        expect(config.headerOut?.pascalCase, isFalse);
        expect(config.headerOut?.append, isNull);
        expect(config.sourceOut?.path, equals('linux/my_project'));
        expect(config.sourceOut?.extension, equals('cc'));
        expect(config.sourceOut?.pascalCase, isFalse);
        expect(config.sourceOut?.append, isNull);
      });
    });

    group('getOptions', () {
      test('should return options with provided values', () {
        final map = {
          'options': {
            'header_include': 'header/include',
            'module': 'my_module',
            'copyright_header': ['Copyright Header'],
            'header_out': 'header/out',
          },
        };

        final config = GObjectConfig.fromMap(map);
        final options = config.getOptions('file');

        expect(options?.headerIncludePath, equals('header/include/file.h'));
        expect(options?.module, equals('my_module'));
        expect(options?.copyrightHeader, contains('Copyright Header'));
        expect(options?.headerOutPath, equals('header/out/file.h'));
      });
    });
  });
}
