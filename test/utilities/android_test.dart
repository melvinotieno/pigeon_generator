import 'dart:io';

import 'package:pigeon_generator/src/utilities/android.dart';
import 'package:test/test.dart';

const _appIdGradle = '''
android {
  applicationId "com.example.myapp"
}
''';

const _namespaceGradle = '''
android {
  namespace "com.example.namespace"
}
''';

void main() {
  group('Android', () {
    late Directory tempDir;
    late String originalDir;

    // We do not use the setupAll and tearDownAll variants here because the
    // Android class returns a singleton instance therefore it will maintain
    // the initially created class across tests unless we reset it.

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

      Android.reset();
    });

    group('regex', () {
      test('should match applicationId or namespace', () {
        final regexp = RegExp(regex);
        final package = 'com.example.myapp';

        // applicationId
        String singleQuotes = "applicationId '$package'";
        String doubleQuotes = 'applicationId "$package"';
        String equalSignSingle = "applicationId='$package'";
        String equalSignDouble = 'applicationId="$package"';
        String equalSignSpaces = 'applicationId   =   "$package"';

        expect(regexp.firstMatch(singleQuotes)?.group(2), equals(package));
        expect(regexp.firstMatch(doubleQuotes)?.group(2), equals(package));
        expect(regexp.firstMatch(equalSignSingle)?.group(2), equals(package));
        expect(regexp.firstMatch(equalSignDouble)?.group(2), equals(package));
        expect(regexp.firstMatch(equalSignSpaces)?.group(2), equals(package));

        // namespace
        singleQuotes = "namespace '$package'";
        doubleQuotes = 'namespace "$package"';
        equalSignSingle = "namespace='$package'";
        equalSignDouble = 'namespace="$package"';
        equalSignSpaces = 'namespace   =   "$package"';

        expect(regexp.firstMatch(singleQuotes)?.group(2), equals(package));
        expect(regexp.firstMatch(doubleQuotes)?.group(2), equals(package));
        expect(regexp.firstMatch(equalSignSingle)?.group(2), equals(package));
        expect(regexp.firstMatch(equalSignDouble)?.group(2), equals(package));
        expect(regexp.firstMatch(equalSignSpaces)?.group(2), equals(package));
      });
    });

    group('constructor', () {
      test('should return same instance for multiple calls', () {
        final instance1 = Android('my_folder');
        final instance2 = Android('my_project');

        expect(identical(instance1, instance2), isTrue);
      });
    });

    group('determineSrcRoot', () {
      test('should return null if project structure is not detected', () {
        final android = Android('my_project');

        expect(android.determineSrcRoot(), isNull);
      });

      test('should return android/app for Android application', () async {
        await Directory('android/app/src').create(recursive: true);

        final android = Android('my_project');

        expect(android.determineSrcRoot(), equals('android/app'));
      });

      test('should return android for Android library', () async {
        await Directory('android/src').create(recursive: true);

        final android = Android('my_project');

        expect(android.determineSrcRoot(), equals('android'));
      });

      test('should prefer Android application over library', () async {
        await Directory('android/app/src').create(recursive: true);
        await Directory('android/src').create(recursive: true);

        final android = Android('my_project');

        expect(android.determineSrcRoot(), equals('android/app'));
      });
    });

    group('getApplicationId', () {
      test('should return null if no gradle file is found', () {
        final android = Android('my_project');

        expect(android.getApplicationId(), isNull);
      });

      test('should return null for invalid gradle file', () async {
        await Directory('android/app').create(recursive: true);
        await File('android/app/build.gradle').writeAsString('invalid content');

        final android = Android('my_project');

        expect(android.getApplicationId(), isNull);
      });

      test('should extract package name from build.gradle', () async {
        await Directory('android/app/src').create(recursive: true);
        await File('android/app/build.gradle').writeAsString(_appIdGradle);

        final android = Android('my_project');

        expect(android.getApplicationId(), equals('com.example.myapp'));
      });

      test('should extract package name from build.gradle.kts', () async {
        await Directory('android/src').create(recursive: true);
        await File('android/build.gradle.kts').writeAsString(_namespaceGradle);

        final android = Android('my_project');

        expect(android.getApplicationId(), equals('com.example.namespace'));
      });
    });

    group('get', () {
      test('should return provided', () async {
        final android = Android('my_project');
        final config = android.get('java', 'custom/path', 'com.custom.package');

        expect(config['outPath'], equals('custom/path'));
        expect(config['packageName'], equals('com.custom.package'));
      });

      test('should return resolved values', () async {
        await Directory('android/app/src').create(recursive: true);
        await File('android/app/build.gradle').writeAsString(_appIdGradle);

        final android = Android('folder');
        final config = android.get('java', '', '');
        final expected = 'android/app/src/main/java/com/example/myapp/folder';

        expect(config['outPath'], equals(expected));
        expect(config['packageName'], equals('com.example.myapp.folder'));
      });
    });
  });
}
