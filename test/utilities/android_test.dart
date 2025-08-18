import 'dart:io';

import 'package:pigeon_generator/src/utilities/android.dart';
import 'package:test/test.dart';

const appIdGradle = '''
android {
  applicationId "com.example.myapp"
}
''';

const namespaceGradle = '''
android {
  namespace "com.example.namespace"
}
''';

const invalidGradle = '''
android {
  compileSdkVersion 31
}
''';

void main() {
  group('Android', () {
    late Directory tempDir;
    late String originalDir;

    setUp(() async {
      originalDir = Directory.current.path;
      tempDir = await Directory.systemTemp.createTemp('android_test_');
      Directory.current = tempDir;
    });

    tearDown(() async {
      Directory.current = originalDir;

      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }

      // Reset singleton instance
      Android.reset();
    });

    group('singleton', () {
      test('should return same instance for multiple calls', () {
        final instance1 = Android();
        final instance2 = Android();

        expect(identical(instance1, instance2), isTrue);
      });

      test('should initialize only once', () async {
        await Directory('android/src').create(recursive: true);
        await File('android/build.gradle').writeAsString(appIdGradle);

        final android1 = Android();
        final result1 = android1.get('java', null, null, null);

        // Change gradle file content
        await File('android/build.gradle').writeAsString(namespaceGradle);

        final android2 = Android();
        final result2 = android2.get('java', null, null, null);

        // Second instance should behave as first instance (not re-initialized)
        expect(result1['packageName'], equals(result2['packageName']));
        expect(result1['outPath'], equals(result2['outPath']));
      });
    });

    group('project', () {
      test('should handle library project structure (android/src)', () async {
        await Directory('android/src').create(recursive: true);

        final android = Android();
        final result = android.get('java', null, null, 'com.example.test');
        final expectedPath = 'android/src/main/java/com/example/test';

        expect(result['outPath'], equals(expectedPath));
        expect(result['packageName'], equals('com.example.test'));
      });

      test('should handle app project structure (android/app/src)', () async {
        await Directory('android/app/src').create(recursive: true);

        final android = Android();
        final result = android.get('kotlin', null, null, 'com.example.app');
        final expectedPath = 'android/app/src/main/kotlin/com/example/app';

        expect(result['outPath'], equals(expectedPath));
        expect(result['packageName'], equals('com.example.app'));
      });

      test('should prefer application over library structure', () async {
        await Directory('android/src').create(recursive: true);
        await Directory('android/app/src').create(recursive: true);

        final android = Android();
        final result = android.get('java', null, null, 'com.example.test');
        final expectedPath = 'android/app/src/main/java/com/example/test';

        expect(result['outPath'], equals(expectedPath));
      });

      test('should return null values for non-existent package', () async {
        final android = Android();
        final result = android.get('java', null, null, null);

        expect(result['outPath'], isNull);
        expect(result['packageName'], isNull);
      });
    });

    group('applicationId', () {
      test('should extract applicationId from build.gradle', () async {
        await Directory('android/src').create(recursive: true);
        await File('android/build.gradle').writeAsString(appIdGradle);

        final android = Android();
        final result = android.get('java', null, null, null);

        expect(result['packageName'], isNotNull);
        expect(result['outPath'], isNotNull);
      });

      test('should extract applicationId from build.gradle.kts', () async {
        await Directory('android/src').create(recursive: true);
        await File('android/build.gradle.kts').writeAsString(appIdGradle);

        final android = Android();
        final result = android.get('kotlin', null, null, null);

        expect(result['packageName'], isNotNull);
        expect(result['outPath'], isNotNull);
      });

      test('should extract namespace from build.gradle', () async {
        await Directory('android/src').create(recursive: true);
        await File('android/build.gradle').writeAsString(namespaceGradle);

        final android = Android();
        final result = android.get('java', null, null, null);

        expect(result['packageName'], isNotNull);
        expect(result['outPath'], isNotNull);
      });

      test('should extract namespace from build.gradle.kts', () async {
        await Directory('android/src').create(recursive: true);
        await File('android/build.gradle.kts').writeAsString(namespaceGradle);

        final android = Android();
        final result = android.get('kotlin', null, null, null);

        expect(result['packageName'], isNotNull);
        expect(result['outPath'], isNotNull);
      });

      test('should return null for invalid gradle', () async {
        await Directory('android/src').create(recursive: true);
        await File('android/build.gradle').writeAsString(invalidGradle);

        final android = Android();
        final result = android.get('java', null, null, null);

        expect(result['packageName'], isNull);
        expect(result['outPath'], isNull);
      });
    });

    group('get', () {
      test('should return provided values', () async {
        await Directory('android/src').create(recursive: true);

        final android = Android();

        final result = android.get(
          'java',
          'custom/path',
          null,
          'com.custom.package',
        );

        expect(result['outPath'], equals('custom/path'));
        expect(result['packageName'], equals('com.custom.package'));
      });

      test('should construct values when provided are empty', () async {
        await Directory('android/app/src').create(recursive: true);
        await File('android/app/build.gradle').writeAsString(appIdGradle);

        final android = Android();
        final result = android.get('java', '', null, '');
        final expectedPath = 'android/app/src/main/java/com/example/myapp';

        expect(result['outPath'], expectedPath);
        expect(result['packageName'], 'com.example.myapp');
      });

      test('should construct path when no values are provided', () async {
        await Directory('android/app/src').create(recursive: true);
        await File('android/app/build.gradle').writeAsString(appIdGradle);

        final android = Android();
        final result = android.get('kotlin', null, null, null);
        final expectedPath = 'android/app/src/main/kotlin/com/example/myapp';

        expect(result['outPath'], expectedPath);
        expect(result['packageName'], 'com.example.myapp');
      });
    });
  });
}
