import 'dart:io';

import 'package:pigeon_generator/src/config/java_config.dart';
import 'package:test/test.dart';

const appIdGradle = '''
android {
  applicationId "com.example.myapp"
}
''';

void main() {
  group('JavaConfig', () {
    late Directory tempDir;
    late String originalDir;

    setUpAll(() async {
      originalDir = Directory.current.path;
      tempDir = await Directory.systemTemp.createTemp('java_config_test_');
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
        final javaConfig = JavaConfig.fromMap(false);

        expect(javaConfig.out, isNull);
        expect(javaConfig.options, isNull);
      });

      test('should return empty config when map is null', () {
        final javaConfig = JavaConfig.fromMap(null);

        expect(javaConfig.out, isNull);
        expect(javaConfig.options, isNull);
      });

      test('should return empty config when map is true and no gradle', () {
        final javaConfig = JavaConfig.fromMap(true);

        expect(javaConfig.out, isNull);
        expect(javaConfig.options, isNotNull);
      });

      test('should return default config when map is true', () async {
        await Directory('android/src').create(recursive: true);
        await File('android/build.gradle').writeAsString(appIdGradle);

        final javaConfig = JavaConfig.fromMap(true);
        final out = javaConfig.out!;
        final options = javaConfig.options!;

        expect(out.path, 'android/src/main/java/com/example/myapp');
        expect(out.extension, 'java');
        expect(out.pascalCase, isTrue);
        expect(out.append, isNull);
        expect(options.package, 'com.example.myapp');
      });

      test('should return default values for missing fields', () async {
        await Directory('android/src').create(recursive: true);
        await File('android/build.gradle').writeAsString(appIdGradle);

        final javaConfig = JavaConfig.fromMap({});
        final out = javaConfig.out!;
        final options = javaConfig.options!;

        expect(out.path, 'android/src/main/java/com/example/myapp');
        expect(out.extension, 'java');
        expect(out.pascalCase, isTrue);
        expect(out.append, isNull);
        expect(options.package, 'com.example.myapp');
      });

      test('should create config with provided values', () {
        final config = <String, dynamic>{
          'out': 'path/to/source',
          'options': {
            'package': 'com.example.myapp',
            'use_generated_annotation': true,
            'copyright_header': ['Copyright 2024'],
          },
        };

        final javaConfig = JavaConfig.fromMap(config);
        final out = javaConfig.out!;
        final options = javaConfig.options!;

        expect(out.path, 'path/to/source');
        expect(out.extension, 'java');
        expect(out.pascalCase, isTrue);
        expect(out.append, isNull);
        expect(options.package, 'com.example.myapp');
        expect(options.useGeneratedAnnotation, isTrue);
        expect(options.copyrightHeader, ['Copyright 2024']);
      });
    });
  });
}
