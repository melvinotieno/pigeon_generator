import 'dart:io';

import 'package:mockito/mockito.dart';
import 'package:pigeon_generator/src/pigeon_utilities.dart';
import 'package:test/test.dart';

class MockAndroidUtilities extends Mock implements AndroidUtilities {}

void main() {
  group('AndroidUtilities', () {
    final gradleFile = 'android/app/build.gradle';
    final applicationId = 'com.example.app';
    final outPath = 'android/app/src/main/java/com/example/app/pigeons';
    final package = 'com.example.app.pigeons';

    late MockAndroidUtilities mockAndroid;

    setUp(() {
      mockAndroid = MockAndroidUtilities();
    });

    test('observes singleton pattern', () {
      expect(android, same(AndroidUtilities()));
    });

    test('methods return null if build.gradle does not exist', () {
      when(mockAndroid.getApplicationId()).thenReturn(null);
      when(mockAndroid.getOutPath('java')).thenReturn(null);
      when(mockAndroid.getPackage()).thenReturn(null);

      expect(mockAndroid.getApplicationId(), isNull);
      expect(mockAndroid.getOutPath('java'), isNull);
      expect(mockAndroid.getPackage(), isNull);
    });

    test('methods return null if build.gradle has no applicationId', () {
      final file = File(gradleFile);
      if (!file.existsSync()) file.createSync(recursive: true);
      file.writeAsStringSync('');

      when(mockAndroid.getApplicationId()).thenReturn(null);
      when(mockAndroid.getOutPath('java')).thenReturn(null);
      when(mockAndroid.getPackage()).thenReturn(null);

      expect(mockAndroid.getApplicationId(), isNull);
      expect(mockAndroid.getOutPath('java'), isNull);
      expect(mockAndroid.getPackage(), isNull);

      file.deleteSync(recursive: true);
    });

    test('methods return correct values if build.gradle exists', () {
      final file = File(gradleFile);
      if (!file.existsSync()) file.createSync(recursive: true);
      file.writeAsStringSync('applicationId = "$applicationId"');

      when(mockAndroid.getApplicationId()).thenReturn(applicationId);
      when(mockAndroid.getOutPath('java')).thenReturn(outPath);
      when(mockAndroid.getPackage()).thenReturn(package);

      expect(mockAndroid.getApplicationId(), applicationId);
      expect(mockAndroid.getOutPath('java'), outPath);
      expect(mockAndroid.getPackage(), package);

      file.deleteSync(recursive: true);
    });
  });
}
