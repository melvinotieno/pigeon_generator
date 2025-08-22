import 'dart:io';

import 'package:pigeon/pigeon.dart';
import 'package:pigeon_generator/src/pigeon_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('PigeonOptionsExtension', () {
    late Directory tempDir;
    late String originalDir;

    setUpAll(() async {
      originalDir = Directory.current.path;
      tempDir = await Directory.systemTemp.createTemp('pigeon_test_');
      Directory.current = tempDir;
    });

    tearDownAll(() async {
      Directory.current = originalDir;

      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    group('mergeInputOptions', () {
      test('should return original options when no options found', () async {
        final content = '''
          import 'package:pigeon/pigeon.dart';

          @HostApi()
          abstract class DefaultsApi {
            @async
            void sendMessage(String message);
          }
        ''';

        await File('defaults.dart').writeAsString(content);

        final options = PigeonOptions(dartOut: 'lib/api.dart');
        final mergedOptions = options.mergeInputOptions('defaults.dart');

        expect(identical(options, mergedOptions), isTrue);
      });

      test('should merge options when found in input file', () async {
        final content = '''
          import 'package:pigeon/pigeon.dart';

          @ConfigurePigeon(
            PigeonOptions(
              dartOut: 'lib/overridden_api.dart',
              javaOut: 'android/Api.java',
            )
          )
          @HostApi()
          abstract class OverridesApi {
            @async
            void sendMessage(String message);
          }
        ''';

        await File('overrides.dart').writeAsString(content);

        final options = PigeonOptions(dartOut: 'lib/api.dart');
        final mergedOptions = options.mergeInputOptions('overrides.dart');

        expect(mergedOptions.dartOut, equals('lib/overridden_api.dart'));
        expect(mergedOptions.javaOut, equals('android/Api.java'));
      });
    });

    group('getOutputs', () {
      test('should return empty list when no outputs are set', () {
        final options = PigeonOptions();
        final outputs = options.getOutputs();

        expect(outputs, isEmpty);
      });

      test('should return all set outputs', () {
        final options = PigeonOptions(
          dartOut: 'lib/api.dart',
          dartTestOut: 'test/api_test.dart',
          cppHeaderOut: 'cpp/api.h',
          cppSourceOut: 'cpp/api.cpp',
          gobjectHeaderOut: 'gobject/api.h',
          gobjectSourceOut: 'gobject/api.c',
          kotlinOut: 'android/Api.kt',
          javaOut: 'android/Api.java',
          swiftOut: 'ios/Api.swift',
          objcHeaderOut: 'ios/Api.h',
          objcSourceOut: 'ios/Api.m',
          astOut: 'ast/api.ast',
        );

        final outputs = options.getOutputs();

        final expected = [
          'lib/api.dart',
          'test/api_test.dart',
          'cpp/api.h',
          'cpp/api.cpp',
          'gobject/api.h',
          'gobject/api.c',
          'android/Api.kt',
          'android/Api.java',
          'ios/Api.swift',
          'ios/Api.h',
          'ios/Api.m',
          'ast/api.ast',
        ];

        expect(outputs, containsAll(expected));
      });
    });

    group('skipOutputs', () {
      test('skips outputs correctly', () {
        final options = PigeonOptions(
          dartOut: 'lib/api.dart',
          dartTestOut: 'test/api_test.dart',
          cppHeaderOut: 'cpp/api.h',
          cppSourceOut: 'cpp/api.cpp',
          gobjectHeaderOut: 'gobject/api.h',
          gobjectSourceOut: 'gobject/api.c',
          kotlinOut: 'android/Api.kt',
          javaOut: 'android/Api.java',
          swiftOut: 'ios/Api.swift',
          objcHeaderOut: 'ios/Api.h',
          objcSourceOut: 'ios/Api.m',
          astOut: 'ast/api.ast',
        );

        final skipOutputs = [
          'dart',
          'dart_test',
          'java',
          'kotlin',
          'swift',
          'objc',
          'cpp',
          'gobject',
          'ast',
        ];

        final result = options.skipOutputs(skipOutputs);

        expect(result.dartOut, isNull);
        expect(result.dartTestOut, isNull);
        expect(result.dartOptions, isNull);
        expect(result.javaOut, isNull);
        expect(result.javaOptions, isNull);
        expect(result.kotlinOut, isNull);
        expect(result.kotlinOptions, isNull);
        expect(result.swiftOut, isNull);
        expect(result.swiftOptions, isNull);
        expect(result.objcHeaderOut, isNull);
        expect(result.objcSourceOut, isNull);
        expect(result.objcOptions, isNull);
        expect(result.cppHeaderOut, isNull);
        expect(result.cppSourceOut, isNull);
        expect(result.cppOptions, isNull);
        expect(result.gobjectHeaderOut, isNull);
        expect(result.gobjectSourceOut, isNull);
        expect(result.gobjectOptions, isNull);
        expect(result.astOut, isNull);
      });
    });
  });
}
