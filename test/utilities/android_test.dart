import 'dart:io';

import 'package:pigeon_generator/src/utilities/android.dart';
import 'package:test/test.dart';

// Global gradle content for reuse in tests
const gradleApplicationId = '''
android {
  applicationId "com.example.myapp"
}
''';

const gradleNamespace = '''
android {
  namespace "com.example.namespace"
}
''';

const gradleInvalid = '''
android {
  compileSdkVersion 30
  minSdkVersion 16
}
''';

void main() {
  group('Android', () {
    late Directory tempDir;
    late String originalDir;

    setUp(() async {
      // Save current directory
      originalDir = Directory.current.path;

      // Create temporary directory for tests
      tempDir = await Directory.systemTemp.createTemp('android_test_');
      Directory.current = tempDir;
    });

    tearDown(() async {
      // Restore original directory
      Directory.current = originalDir;

      // Clean up temporary directory
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }

      // Reset singleton instance
      Android.reset();
    });

    group('Singleton Pattern', () {
      test('should return same instance for multiple calls', () {
        final instance1 = Android();
        final instance2 = Android();

        expect(identical(instance1, instance2), isTrue);
      });

      test('should initialize only once', () async {
        await Directory('android/src').create(recursive: true);
        await File('android/build.gradle').writeAsString(gradleApplicationId);

        final android1 = Android();
        final result1 = android1.get('java', null, null);

        // Change gradle file content
        await File('android/build.gradle').writeAsString(gradleNamespace);

        final android2 = Android();
        final result2 = android2.get('java', null, null);

        // Second instance should have same behavior as first (not re-initialized)
        expect(result1['packageName'], equals(result2['packageName']));
        expect(result1['outPath'], equals(result2['outPath']));
      });
    });

    group('Project Structure Detection', () {
      test('should handle library project structure (android/src)', () async {
        // Create android/src directory structure
        await Directory('android/src').create(recursive: true);

        final android = Android();
        final result = android.get('java', null, 'com.example.test');
        final expectedPath = 'android/src/main/java/com/example/test';

        expect(result['outPath'], equals(expectedPath));
        expect(result['packageName'], equals('com.example.test'));
      });

      test('should handle app project structure (android/app/src)', () async {
        // Create android/app/src directory structure
        await Directory('android/app/src').create(recursive: true);

        final android = Android();
        final result = android.get('kotlin', null, 'com.example.app');
        final expectedPath = 'android/app/src/main/kotlin/com/example/app';

        expect(result['outPath'], equals(expectedPath));
        expect(result['packageName'], equals('com.example.app'));
      });

      test(
        'should prefer app structure over library structure when both exist',
        () async {
          // Create both directory structures
          await Directory('android/src').create(recursive: true);
          await Directory('android/app/src').create(recursive: true);

          final android = Android();
          final result = android.get('java', null, 'com.example.test');
          final expectedPath = 'android/app/src/main/java/com/example/test';

          expect(result['outPath'], equals(expectedPath));
        },
      );

      test(
        'should return null outPath when neither directory structure exists',
        () {
          final android = Android();
          final result = android.get('java', null, 'com.example.test');

          expect(result['outPath'], isNull);
          expect(result['packageName'], equals('com.example.test'));
        },
      );
    });

    group('Application ID Extraction', () {
      test('should extract applicationId from build.gradle', () async {
        await Directory('android/src').create(recursive: true);
        await File('android/build.gradle').writeAsString(gradleApplicationId);

        final android = Android();
        final result = android.get('java', null, null);

        // Should use applicationId as package when no package provided
        expect(result['packageName'], isNotNull);
        expect(result['outPath'], isNotNull);
      });

      test('should extract namespace from build.gradle', () async {
        await Directory('android/src').create(recursive: true);
        await File('android/build.gradle').writeAsString(gradleNamespace);

        final android = Android();
        final result = android.get('java', null, null);

        // Should use namespace as package when no package provided
        expect(result['packageName'], isNotNull);
        expect(result['outPath'], isNotNull);
      });

      test('should extract applicationId from build.gradle.kts', () async {
        await Directory('android/src').create(recursive: true);
        await File('android/build.gradle.kts').writeAsString(gradleNamespace);

        final android = Android();
        final result = android.get('kotlin', null, null);

        // Should use applicationId as package when no package provided
        expect(result['packageName'], isNotNull);
        expect(result['outPath'], isNotNull);
      });

      test(
        'should return null packageName when no applicationId or namespace found',
        () async {
          await Directory('android/src').create(recursive: true);
          await File('android/build.gradle').writeAsString(gradleInvalid);

          final android = Android();
          final result = android.get('java', null, null);

          expect(result['packageName'], isNull);
          expect(result['outPath'], isNull);
        },
      );

      test(
        'should return null packageName when gradle file does not exist',
        () async {
          await Directory('android/src').create(recursive: true);
          // Don't create gradle file

          final android = Android();
          final result = android.get('java', null, null);

          expect(result['packageName'], isNull);
          expect(result['outPath'], isNull);
        },
      );

      group('get method', () {
        test(
          'should return provided path and package when both are given',
          () async {
            await Directory('android/src').create(recursive: true);

            final android = Android();
            final result = android.get(
              'java',
              'custom/path',
              'com.custom.package',
            );

            expect(result['outPath'], equals('custom/path'));
            expect(result['packageName'], equals('com.custom.package'));
          },
        );

        test(
          'should use applicationId as package when package is null',
          () async {
            await Directory('android/src').create(recursive: true);
            await File(
              'android/build.gradle',
            ).writeAsString(gradleApplicationId);

            final android = Android();
            final result = android.get('java', 'custom/path', null);

            expect(result['outPath'], equals('custom/path'));
            expect(result['packageName'], isNotNull);
          },
        );

        test(
          'should use applicationId as package when package is empty',
          () async {
            await Directory('android/src').create(recursive: true);
            await File(
              'android/build.gradle',
            ).writeAsString(gradleApplicationId);

            final android = Android();
            final result = android.get('java', 'custom/path', '');

            expect(result['outPath'], equals('custom/path'));
            expect(result['packageName'], isNotNull);
          },
        );

        test(
          'should construct path when path is null but srcRoot and package are available',
          () async {
            await Directory('android/app/src').create(recursive: true);

            final android = Android();
            final result = android.get('kotlin', null, 'com.example.myapp');
            final expectedPath =
                'android/app/src/main/kotlin/com/example/myapp';

            expect(result['outPath'], equals(expectedPath));
            expect(result['packageName'], equals('com.example.myapp'));
          },
        );

        test(
          'should construct path when path is empty but srcRoot and package are available',
          () async {
            await Directory('android/src').create(recursive: true);

            final android = Android();
            final result = android.get('java', '', 'com.example.test');
            final expectedPath = 'android/src/main/java/com/example/test';

            expect(result['outPath'], equals(expectedPath));
            expect(result['packageName'], equals('com.example.test'));
          },
        );

        test(
          'should construct path using applicationId when both path and package are null',
          () async {
            await Directory('android/src').create(recursive: true);
            await File(
              'android/build.gradle',
            ).writeAsString(gradleApplicationId);

            final android = Android();
            final result = android.get('java', null, null);

            expect(result['outPath'], isNotNull);
            expect(result['packageName'], isNotNull);

            // The path should contain the language and be constructed properly
            expect(result['outPath'], contains('src/main/java'));
          },
        );

        test(
          'should return null values when insufficient information is available',
          () {
            // Don't create any directories or files

            final android = Android();
            final result = android.get('java', null, null);

            expect(result['outPath'], isNull);
            expect(result['packageName'], isNull);
          },
        );

        test(
          'should return null outPath when srcRoot is null but package is available',
          () {
            // Don't create android directories

            final android = Android();
            final result = android.get('java', null, 'com.example.test');

            expect(result['outPath'], isNull);
            expect(result['packageName'], equals('com.example.test'));
          },
        );

        test('should work with different languages', () async {
          await Directory('android/src').create(recursive: true);

          final android = Android();

          // Test with java
          final javaResult = android.get('java', null, 'com.example.test');
          final expectedJavaPath = 'android/src/main/java/com/example/test';

          expect(javaResult['outPath'], equals(expectedJavaPath));

          // Test with kotlin
          final kotlinResult = android.get('kotlin', null, 'com.example.test');
          final expectedKotlinPath = 'android/src/main/kotlin/com/example/test';

          expect(kotlinResult['outPath'], equals(expectedKotlinPath));
        });
      });
    });
  });
}
