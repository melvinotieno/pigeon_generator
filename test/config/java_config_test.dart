import 'dart:io';

import 'package:pigeon_generator/src/config/java_config.dart';
import 'package:pigeon_generator/src/utilities/android.dart';
import 'package:test/test.dart';

const _appIdGradle = '''
android {
  applicationId "com.example.myapp"
}
''';

void main() {
  group('JavaConfig', () {
    late Directory tempDir;
    late String originalDir;

    // We do not use the setupAll and tearDownAll variants here because the
    // Android class returns a singleton instance therefore it will maintain
    // the initially created class across tests unless we reset it.

    setUp(() async {
      originalDir = Directory.current.path;
      tempDir = await Directory.systemTemp.createTemp('java_config_test_');
      Directory.current = tempDir;
    });

    tearDown(() async {
      Directory.current = originalDir;

      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }

      Android.reset();
    });

    group('fromMap', () {
      test('should return null values when disabled', () {
        // Tests for null value
        JavaConfig config = JavaConfig.fromMap(null);

        expect(config.out, isNull);
        expect(config.getOptions('test_file'), isNull);

        // Tests for false value
        config = JavaConfig.fromMap(false);

        expect(config.out, isNull);
        expect(config.getOptions('test_file'), isNull);
      });

      test('should return config with provided values', () {
        final config = JavaConfig.fromMap({'out': 'custom/java'});

        expect(config.out?.path, equals('custom/java'));
        expect(config.out?.extension, equals('java'));
        expect(config.out?.pascalCase, isTrue);
        expect(config.out?.append, isNull);
      });

      test('should return default values for any other type', () async {
        await Directory('android/src').create(recursive: true);
        await File('android/build.gradle').writeAsString(_appIdGradle);

        final expected = 'android/src/main/java/com/example/myapp';

        final config = JavaConfig.fromMap(true);
        final options = config.getOptions('test_file');

        expect(config.out?.path, equals(expected));
        expect(config.out?.extension, equals('java'));
        expect(config.out?.pascalCase, isTrue);
        expect(config.out?.append, isNull);
        expect(options?.package, equals('com.example.myapp'));
        expect(options?.useGeneratedAnnotation, isNull);
        expect(options?.copyrightHeader, isNull);
      });
    });

    group('getOptions', () {
      test('should return options with provided values', () {
        final map = {
          'options': {
            'package': 'com.example.myapp',
            'use_generated_annotation': true,
            'copyright_header': ['Copyright 2024'],
          },
        };

        final config = JavaConfig.fromMap(map);
        final options = config.getOptions('file');

        expect(options?.package, equals('com.example.myapp'));
        expect(options?.useGeneratedAnnotation, isTrue);
        expect(options?.copyrightHeader, contains('Copyright 2024'));
      });
    });
  });
}
