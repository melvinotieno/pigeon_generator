import 'dart:io';

import 'package:pigeon_generator/src/config/swift_config.dart';
import 'package:test/test.dart';

void main() {
  group('SwiftConfig', () {
    late Directory tempDir;
    late String originalDir;

    setUpAll(() async {
      originalDir = Directory.current.path;
      tempDir = await Directory.systemTemp.createTemp('swift_config_test_');
      Directory.current = tempDir;
    });

    tearDownAll(() async {
      Directory.current = originalDir;

      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    group('fromMap', () {
      test('should return null values when disabled', () {
        // Tests for null value
        SwiftConfig config = SwiftConfig.fromMap(null);

        expect(config.out, isNull);
        expect(config.getOptions('test_file'), isNull);

        // Tests for false value
        config = SwiftConfig.fromMap(false);

        expect(config.out, isNull);
        expect(config.getOptions('test_file'), isNull);
      });

      test('should return config with provided values', () {
        final map = {'out': 'path/to/output'};

        // Tests without base folder path
        SwiftConfig config = SwiftConfig.fromMap(map);

        expect(config.out?.path, equals('path/to/output'));
        expect(config.out?.extension, equals('swift'));
        expect(config.out?.pascalCase, isTrue);
        expect(config.out?.append, isNull);

        // Tests with base folder path
        config = SwiftConfig.fromMap(map, 'my_project');

        expect(config.out?.path, equals('path/to/output'));
        expect(config.out?.extension, equals('swift'));
        expect(config.out?.pascalCase, isTrue);
        expect(config.out?.append, isNull);
      });

      test('should return default values for any other type', () async {
        // Tests for true value
        SwiftConfig config = SwiftConfig.fromMap(true);

        expect(config.out?.path, equals('ios/Runner'));
        expect(config.out?.extension, equals('swift'));
        expect(config.out?.pascalCase, isTrue);
        expect(config.out?.append, isNull);

        // For null to return default values, there needs to exist an ios
        // directory in the root of the project.
        await Directory('ios').create();

        config = SwiftConfig.fromMap(null, 'project/folder');

        expect(config.out?.path, equals('ios/Runner/Project/Folder'));
        expect(config.out?.extension, equals('swift'));
        expect(config.out?.pascalCase, isTrue);
        expect(config.out?.append, isNull);
      });
    });

    group('getOptions', () {
      test('should return options with provided values', () {
        final map = {
          'options': {
            'include_error_class': false,
            'copyright_header': ['Copyright 2024'],
          },
        };

        final config = SwiftConfig.fromMap(map);
        final options = config.getOptions('custom');

        expect(options?.includeErrorClass, isFalse);
        expect(options?.errorClassName, 'CustomError');
        expect(options?.copyrightHeader, ['Copyright 2024']);
      });
    });
  });
}
