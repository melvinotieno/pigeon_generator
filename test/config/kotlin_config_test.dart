import 'dart:io';

import 'package:pigeon_generator/src/config/kotlin_config.dart';
import 'package:pigeon_generator/src/utilities/android.dart';
import 'package:test/test.dart';

const appIdGradle = '''
android {
  applicationId "com.example.myapp"
}
''';

void main() {
  group('KotlinConfig', () {
    late Directory tempDir;
    late String originalDir;

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
      test('should return empty config when map is false', () {
        final kotlinConfig = KotlinConfig.fromMap(false);

        expect(kotlinConfig.out, isNull);
      });

      test('should return empty config when map is null', () {
        final kotlinConfig = KotlinConfig.fromMap(null);

        expect(kotlinConfig.out, isNull);
      });

      test('should return empty config when map is true and no gradle', () {
        final kotlinConfig = KotlinConfig.fromMap(true);

        expect(kotlinConfig.out, isNull);
      });

      test('should return default config when map is true', () async {
        await Directory('android/src').create(recursive: true);
        await File('android/build.gradle').writeAsString(appIdGradle);

        final kotlinConfig = KotlinConfig.fromMap(true);
        final out = kotlinConfig.out!;

        expect(out.path, 'android/src/main/kotlin/com/example/myapp');
        expect(out.extension, 'kt');
        expect(out.pascalCase, isTrue);
        expect(out.append, isNull);
      });

      test('should return default config for an android project', () async {
        await Directory('android/src').create(recursive: true);
        await File('android/build.gradle').writeAsString(appIdGradle);

        final kotlinConfig = KotlinConfig.fromMap(null);
        final out = kotlinConfig.out!;

        expect(out.path, 'android/src/main/kotlin/com/example/myapp');
        expect(out.extension, 'kt');
        expect(out.pascalCase, isTrue);
        expect(out.append, isNull);
      });

      test('should return default values for missing fields', () async {
        await Directory('android/src').create(recursive: true);
        await File('android/build.gradle').writeAsString(appIdGradle);

        final kotlinConfig = KotlinConfig.fromMap(true);
        final out = kotlinConfig.out!;

        expect(out.path, 'android/src/main/kotlin/com/example/myapp');
        expect(out.extension, 'kt');
        expect(out.pascalCase, isTrue);
        expect(out.append, isNull);
      });

      test('should create config with provided values', () {
        final config = <String, dynamic>{'out': 'path/to/source'};

        final kotlinConfig = KotlinConfig.fromMap(config);
        final out = kotlinConfig.out!;

        expect(out.path, 'path/to/source');
        expect(out.extension, 'kt');
        expect(out.pascalCase, isTrue);
        expect(out.append, isNull);
      });
    });

    group('getOptions', () {
      test('should return null when no options provided', () {
        final kotlinConfig = KotlinConfig.fromMap(null);
        final options = kotlinConfig.getOptions('custom');

        expect(options, isNull);
      });

      test('should return default options', () async {
        await Directory('android/src').create(recursive: true);
        await File('android/build.gradle').writeAsString(appIdGradle);

        final kotlinConfig = KotlinConfig.fromMap(true);
        final options = kotlinConfig.getOptions('custom')!;

        expect(options.package, 'com.example.myapp');
        expect(options.errorClassName, 'CustomError');
        expect(options.includeErrorClass, isTrue);
        expect(options.copyrightHeader, isNull);
      });

      test('should return options from provided config', () {
        final config = <String, dynamic>{
          'out': 'path/to/source',
          'options': {
            'package': 'com.example.myapp',
            'include_error_class': true,
            'copyright_header': ['Copyright 2024'],
          },
        };

        final kotlinConfig = KotlinConfig.fromMap(config);
        final options = kotlinConfig.getOptions('custom')!;

        expect(options.package, 'com.example.myapp');
        expect(options.errorClassName, 'CustomError');
        expect(options.includeErrorClass, isTrue);
        expect(options.copyrightHeader, contains('Copyright 2024'));
      });
    });
  });
}
