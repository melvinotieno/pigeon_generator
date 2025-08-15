import 'dart:io';

import 'package:pigeon_generator/src/config/cpp_config.dart';
import 'package:test/test.dart';

void main() {
  group('CppConfig', () {
    late Directory tempDir;
    late String originalDir;

    setUp(() async {
      originalDir = Directory.current.path;
      tempDir = await Directory.systemTemp.createTemp('cpp_config_test_');
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
        final cppConfig = CppConfig.fromMap(false);

        expect(cppConfig.headerOut, isNull);
        expect(cppConfig.sourceOut, isNull);
      });

      test('should return empty config when map is null', () {
        final cppConfig = CppConfig.fromMap(null);

        expect(cppConfig.headerOut, isNull);
        expect(cppConfig.sourceOut, isNull);
      });

      test('should return default config when map is true', () {
        final cppConfig = CppConfig.fromMap(true);
        final headerOut = cppConfig.headerOut!;
        final sourceOut = cppConfig.sourceOut!;

        expect(headerOut.path, 'windows/runner');
        expect(headerOut.extension, 'h');
        expect(headerOut.pascalCase, isFalse);
        expect(headerOut.append, isNull);
        expect(sourceOut.path, 'windows/runner');
        expect(sourceOut.extension, 'cpp');
        expect(sourceOut.pascalCase, isFalse);
        expect(sourceOut.append, isNull);
      });

      test('should return default config when windows folder exists', () async {
        await Directory('windows').create();

        final cppConfig = CppConfig.fromMap(null);
        final headerOut = cppConfig.headerOut!;
        final sourceOut = cppConfig.sourceOut!;

        expect(headerOut.path, 'windows/runner');
        expect(headerOut.extension, 'h');
        expect(headerOut.pascalCase, isFalse);
        expect(headerOut.append, isNull);
        expect(sourceOut.path, 'windows/runner');
        expect(sourceOut.extension, 'cpp');
        expect(sourceOut.pascalCase, isFalse);
        expect(sourceOut.append, isNull);
      });

      test('should create config with default values for missing fields', () {
        final cppConfig = CppConfig.fromMap({});
        final headerOut = cppConfig.headerOut!;
        final sourceOut = cppConfig.sourceOut!;

        expect(headerOut.path, 'windows/runner');
        expect(headerOut.extension, 'h');
        expect(headerOut.pascalCase, isFalse);
        expect(headerOut.append, isNull);
        expect(sourceOut.path, 'windows/runner');
        expect(sourceOut.extension, 'cpp');
        expect(sourceOut.pascalCase, isFalse);
        expect(sourceOut.append, isNull);
      });

      test('should create config with provided values', () {
        final config = <String, dynamic>{
          'header_out': 'path/to/header',
          'source_out': 'path/to/source',
        };

        final cppConfig = CppConfig.fromMap(config);
        final headerOut = cppConfig.headerOut!;
        final sourceOut = cppConfig.sourceOut!;

        expect(headerOut.path, 'path/to/header');
        expect(headerOut.extension, 'h');
        expect(headerOut.pascalCase, isFalse);
        expect(headerOut.append, isNull);
        expect(sourceOut.path, 'path/to/source');
        expect(sourceOut.extension, 'cpp');
        expect(sourceOut.pascalCase, isFalse);
        expect(sourceOut.append, isNull);
      });
    });
  });
}
