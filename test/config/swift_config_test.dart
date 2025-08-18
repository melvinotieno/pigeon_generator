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
      test('should return empty config when map is false', () {
        final swiftConfig = SwiftConfig.fromMap(false);

        expect(swiftConfig.out, isNull);
      });

      test('should return empty config when map is null', () {
        final swiftConfig = SwiftConfig.fromMap(null);

        expect(swiftConfig.out, isNull);
      });

      test('should return default config when map is true', () {
        final swiftConfig = SwiftConfig.fromMap(true);
        final out = swiftConfig.out!;

        expect(out.path, 'ios');
        expect(out.extension, 'swift');
        expect(out.pascalCase, isTrue);
        expect(out.append, isNull);
      });

      test('should return default config when ios folder exists', () async {
        await Directory('ios').create();

        final swiftConfig = SwiftConfig.fromMap(null);
        final out = swiftConfig.out!;

        expect(out.path, 'ios');
        expect(out.extension, 'swift');
        expect(out.pascalCase, isTrue);
        expect(out.append, isNull);
      });

      test('should create config with default values for missing fields', () {
        final swiftConfig = SwiftConfig.fromMap({});
        final out = swiftConfig.out!;

        expect(out.path, 'ios');
        expect(out.extension, 'swift');
        expect(out.pascalCase, isTrue);
        expect(out.append, isNull);
      });

      test('should create config with provided values', () {
        final config = <String, dynamic>{
          'out': 'path/to/source',
          'options': {
            'include_error_class': false,
            'error_class_name': 'CustomError',
            'copyright_header': ['Copyright 2024'],
          },
        };

        final swiftConfig = SwiftConfig.fromMap(config);
        final out = swiftConfig.out!;

        expect(out.path, 'path/to/source');
        expect(out.extension, 'swift');
        expect(out.pascalCase, isTrue);
        expect(out.append, isNull);
      });
    });

    group('getOptions', () {
      test('should return null when no options provided', () {
        final swiftConfig = SwiftConfig.fromMap({'out': 'ios'});

        expect(swiftConfig.getOptions('file'), isNull);
      });

      test('should return SwiftOptions with paths when options provided', () {
        final map = {
          'options': {
            'include_error_class': false,
            'copyright_header': ['Copyright 2024'],
          },
        };

        final swiftConfig = SwiftConfig.fromMap(map);
        final options = swiftConfig.getOptions('custom');

        expect(options, isNotNull);
        expect(options!.includeErrorClass, isFalse);
        expect(options.errorClassName, 'CustomError');
        expect(options.copyrightHeader, ['Copyright 2024']);
      });
    });
  });
}
