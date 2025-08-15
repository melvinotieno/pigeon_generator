import 'dart:io';

import 'package:pigeon_generator/src/config/dart_config.dart';
import 'package:test/test.dart';

void main() {
  group('DartConfig', () {
    late Directory tempDir;
    late String originalDir;

    setUp(() async {
      originalDir = Directory.current.path;
      tempDir = await Directory.systemTemp.createTemp('dart_config_test_');
      Directory.current = tempDir;
    });

    tearDown(() async {
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
      });

      test('should return default config when map is null', () {
        final config = DartConfig.fromMap(null);

        expect(config.out, isNotNull);
        expect(config.testOut, isNull); // No test directory exists
        expect(config.packageName, isNull);
      });

      test('should create config with provided values', () {
        final map = {
          'out': 'src/lib',
          'test_out': 'src/test',
          'package_name': 'my_package',
          'options': {'key': 'value'},
        };

        final config = DartConfig.fromMap(map);

        expect(config.out, isNotNull);
        expect(config.testOut, isNotNull);
        expect(config.packageName, equals('my_package'));
      });

      test('should handle test_out when test directory exists', () async {
        await Directory('test').create();

        final config = DartConfig.fromMap({'test_out': 'custom_test'});

        expect(config.testOut, isNotNull);
      });

      test('should handle test_out as false', () {
        final config = DartConfig.fromMap({'test_out': false});

        expect(config.testOut, isNull);
      });
    });

    group('getOptions', () {
      test('should return null when no options provided', () {
        final config = DartConfig.fromMap({'out': 'lib'});

        expect(config.getOptions('test_file'), isNull);
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
        final options = config.getOptions('my_file')!;

        expect(options, isNotNull);
        expect(options.sourceOutPath, equals('src/generated/my_file.dart'));
        expect(options.testOutPath, equals('test/generated/my_file_test.dart'));
        expect(options.copyrightHeader, contains('Copyright 2024'));
      });

      test('should handle partial options', () {
        final map = {
          'options': {'source_out': 'src/only'},
        };

        final config = DartConfig.fromMap(map);
        final options = config.getOptions('my_file')!;

        expect(options.sourceOutPath, equals('src/only/my_file.dart'));
        expect(options.testOutPath, isNull);
      });
    });
  });
}
