import 'dart:io';

import 'package:pigeon_generator/src/config/objc_config.dart';
import 'package:test/test.dart';

void main() {
  group('ObjcConfig', () {
    late Directory tempDir;
    late String originalDir;

    setUpAll(() async {
      originalDir = Directory.current.path;
      tempDir = await Directory.systemTemp.createTemp('objc_config_test_');
      Directory.current = tempDir;
    });

    tearDownAll(() async {
      Directory.current = originalDir;

      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    group('fromMap', () {
      test('should return empty config when pam is false', () {
        final objcConfig = ObjcConfig.fromMap(false);

        expect(objcConfig.headerOut, isNull);
        expect(objcConfig.sourceOut, isNull);
      });

      test('should return empty config when map is null', () {
        final objcConfig = ObjcConfig.fromMap(null);

        expect(objcConfig.headerOut, isNull);
        expect(objcConfig.sourceOut, isNull);
      });

      test('should return default config when map is true', () {
        final objcConfig = ObjcConfig.fromMap(true);
        final headerOut = objcConfig.headerOut!;
        final sourceOut = objcConfig.sourceOut!;

        expect(headerOut.path, 'macos');
        expect(headerOut.extension, 'h');
        expect(headerOut.pascalCase, isFalse);
        expect(headerOut.append, isNull);
        expect(sourceOut.path, 'macos');
        expect(sourceOut.extension, 'm');
        expect(sourceOut.pascalCase, isFalse);
        expect(sourceOut.append, isNull);
      });

      test('should return default config when macos folder exists', () async {
        await Directory('macos').create();

        final objcConfig = ObjcConfig.fromMap(null);
        final headerOut = objcConfig.headerOut!;
        final sourceOut = objcConfig.sourceOut!;

        expect(headerOut.path, 'macos');
        expect(headerOut.extension, 'h');
        expect(headerOut.pascalCase, isFalse);
        expect(headerOut.append, isNull);
        expect(sourceOut.path, 'macos');
        expect(sourceOut.extension, 'm');
        expect(sourceOut.pascalCase, isFalse);
        expect(sourceOut.append, isNull);
      });

      test('should create config with default values for missing fields', () {
        final objcConfig = ObjcConfig.fromMap({});
        final headerOut = objcConfig.headerOut!;
        final sourceOut = objcConfig.sourceOut!;

        expect(headerOut.path, 'macos');
        expect(headerOut.extension, 'h');
        expect(headerOut.pascalCase, isFalse);
        expect(headerOut.append, isNull);
        expect(sourceOut.path, 'macos');
        expect(sourceOut.extension, 'm');
        expect(sourceOut.pascalCase, isFalse);
        expect(sourceOut.append, isNull);
      });

      test('should create config with provided values', () {
        final config = <String, dynamic>{
          'header_out': 'path/to/header',
          'source_out': 'path/to/source',
        };

        final objcConfig = ObjcConfig.fromMap(config);
        final headerOut = objcConfig.headerOut!;
        final sourceOut = objcConfig.sourceOut!;

        expect(headerOut.path, 'path/to/header');
        expect(headerOut.extension, 'h');
        expect(headerOut.pascalCase, isFalse);
        expect(headerOut.append, isNull);
        expect(sourceOut.path, 'path/to/source');
        expect(sourceOut.extension, 'm');
        expect(sourceOut.pascalCase, isFalse);
        expect(sourceOut.append, isNull);
      });
    });
  });
}
