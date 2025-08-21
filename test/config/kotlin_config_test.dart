import 'dart:io';

import 'package:pigeon/pigeon.dart';
import 'package:pigeon_generator/src/config/kotlin_config.dart';
import 'package:pigeon_generator/src/utilities/android.dart';
import 'package:test/test.dart';

const _appIdGradle = '''
android {
  applicationId "com.example.myapp"
}
''';

void main() {
  group('KotlinConfig', () {
    late Directory tempDir;
    late String originalDir;

    // We do not use the setupAll and tearDownAll variants here because the
    // Android class returns a singleton instance therefore it will maintain
    // the initially created class across tests unless we reset it.

    setUp(() async {
      originalDir = Directory.current.path;
      tempDir = await Directory.systemTemp.createTemp('kotlin_config_test_');
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
        KotlinConfig config = KotlinConfig.fromMap(null);

        expect(config.out, isNull);
        expect(config.getOptions('test_file'), isNull);

        // Tests for false value
        config = KotlinConfig.fromMap(false);

        expect(config.out, isNull);
        expect(config.getOptions('test_file'), isNull);
      });

      test('should return config with provided values', () {
        final config = KotlinConfig.fromMap({'out': 'custom/kotlin'});

        expect(config.out?.path, equals('custom/kotlin'));
        expect(config.out?.extension, equals('kt'));
        expect(config.out?.pascalCase, isTrue);
        expect(config.out?.append, isNull);
      });

      test('should return default values for any other type', () async {
        // Testing is done with a valid Android project. If a project does not
        // exist, then the values for null map will be null while that of true
        // will only have errorClassName and includeErrorClass options.
        await Directory('android/src').create(recursive: true);
        await File('android/build.gradle').writeAsString(_appIdGradle);

        final expected = 'android/src/main/kotlin/com/example/myapp';

        // Tests for null value
        KotlinConfig config = KotlinConfig.fromMap(null);
        KotlinOptions? options = config.getOptions('custom');

        expect(config.out?.path, equals(expected));
        expect(config.out?.extension, equals('kt'));
        expect(config.out?.pascalCase, isTrue);
        expect(config.out?.append, isNull);
        expect(options?.package, equals('com.example.myapp'));
        expect(options?.errorClassName, equals('CustomError'));
        expect(options?.includeErrorClass, isTrue);
        expect(options?.copyrightHeader, isNull);

        // Tests for true value
        config = KotlinConfig.fromMap(true);
        options = config.getOptions('test_file');

        expect(config.out?.path, equals(expected));
        expect(config.out?.extension, equals('kt'));
        expect(config.out?.pascalCase, isTrue);
        expect(config.out?.append, isNull);
        expect(options?.package, equals('com.example.myapp'));
        expect(options?.errorClassName, equals('TestFileError'));
        expect(options?.includeErrorClass, isTrue);
        expect(options?.copyrightHeader, isNull);
      });
    });

    group('getOptions', () {
      test('should return options with provided values', () {
        final map = {
          'options': {
            'package': 'com.example.myapp',
            'include_error_class': true,
            'copyright_header': ['Copyright 2024'],
          },
        };

        final config = KotlinConfig.fromMap(map);
        final options = config.getOptions('custom');

        expect(options?.package, 'com.example.myapp');
        expect(options?.errorClassName, 'CustomError');
        expect(options?.includeErrorClass, isTrue);
        expect(options?.copyrightHeader, contains('Copyright 2024'));
      });
    });
  });
}
