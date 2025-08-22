import 'dart:io';

import 'package:pigeon_generator/src/config/cpp_config.dart';
import 'package:test/test.dart';

void main() {
  group('CppConfig', () {
    late Directory tempDir;
    late String originalDir;

    setUpAll(() async {
      originalDir = Directory.current.path;
      tempDir = await Directory.systemTemp.createTemp('cpp_config_test_');
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
        CppConfig config = CppConfig.fromMap(false);

        expect(config.headerOut, isNull);
        expect(config.sourceOut, isNull);
        expect(config.getOptions('test_file'), isNull);

        // Tests for false value
        config = CppConfig.fromMap(false);

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
        CppConfig config = CppConfig.fromMap(map);

        expect(config.headerOut?.path, equals('path/to/header'));
        expect(config.headerOut?.extension, equals('h'));
        expect(config.headerOut?.pascalCase, isFalse);
        expect(config.headerOut?.append, isNull);
        expect(config.sourceOut?.path, equals('path/to/source'));
        expect(config.sourceOut?.extension, equals('cpp'));
        expect(config.sourceOut?.pascalCase, isFalse);
        expect(config.sourceOut?.append, isNull);

        // Tests with base folder path
        config = CppConfig.fromMap(map, 'my_project');

        expect(config.headerOut?.path, equals('path/to/header'));
        expect(config.headerOut?.extension, equals('h'));
        expect(config.headerOut?.pascalCase, isFalse);
        expect(config.headerOut?.append, isNull);
        expect(config.sourceOut?.path, equals('path/to/source'));
        expect(config.sourceOut?.extension, equals('cpp'));
        expect(config.sourceOut?.pascalCase, isFalse);
        expect(config.sourceOut?.append, isNull);
      });

      test('should return default values for any other type', () async {
        // Tests for true value
        CppConfig config = CppConfig.fromMap(true);

        expect(config.headerOut?.path, 'windows/runner');
        expect(config.headerOut?.extension, 'h');
        expect(config.headerOut?.pascalCase, isFalse);
        expect(config.headerOut?.append, isNull);
        expect(config.sourceOut?.path, 'windows/runner');
        expect(config.sourceOut?.extension, 'cpp');
        expect(config.sourceOut?.pascalCase, isFalse);
        expect(config.sourceOut?.append, isNull);

        // For null to return default values, there needs to exist a windows
        // directory in the root of the project.
        await Directory('windows').create();

        // Tests for null values
        config = CppConfig.fromMap(null);

        expect(config.headerOut?.path, 'windows/runner');
        expect(config.headerOut?.extension, 'h');
        expect(config.headerOut?.pascalCase, isFalse);
        expect(config.headerOut?.append, isNull);
        expect(config.sourceOut?.path, 'windows/runner');
        expect(config.sourceOut?.extension, 'cpp');
        expect(config.sourceOut?.pascalCase, isFalse);
        expect(config.sourceOut?.append, isNull);
      });
    });

    group('getOptions', () {
      test('should return options with provided values', () {
        final map = {
          'options': {
            'header_include': 'header/include',
            'namespace': 'my_namespace',
            'copyright_header': ['Copyright Header'],
            'header_out': 'header/out',
          },
        };

        final config = CppConfig.fromMap(map);
        final options = config.getOptions('file');

        expect(options?.headerIncludePath, equals('header/include/file.h'));
        expect(options?.namespace, equals('my_namespace'));
        expect(options?.copyrightHeader, contains('Copyright Header'));
        expect(options?.headerOutPath, equals('header/out/file.h'));
      });
    });
  });
}
