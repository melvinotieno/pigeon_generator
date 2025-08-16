import 'dart:io';

import 'package:pigeon_generator/src/config/gobject_config.dart';
import 'package:test/test.dart';

void main() {
  group('GObjectConfig', () {
    late Directory tempDir;
    late String originalDir;

    setUpAll(() async {
      originalDir = Directory.current.path;
      tempDir = await Directory.systemTemp.createTemp('gobject_config_test_');
      Directory.current = tempDir;
    });

    tearDownAll(() async {
      Directory.current = originalDir;

      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    group('fromMap', () {
      test('should return empty config when map is false', () {
        final gobjectConfig = GObjectConfig.fromMap(false);

        expect(gobjectConfig.headerOut, isNull);
        expect(gobjectConfig.sourceOut, isNull);
      });

      test('should return empty config when map is null', () {
        final gobjectConfig = GObjectConfig.fromMap(null);

        expect(gobjectConfig.headerOut, isNull);
        expect(gobjectConfig.sourceOut, isNull);
      });

      test('should return default config when map is true', () {
        final gobjectConfig = GObjectConfig.fromMap(true);
        final headerOut = gobjectConfig.headerOut!;
        final sourceOut = gobjectConfig.sourceOut!;

        expect(headerOut.path, 'linux');
        expect(headerOut.extension, 'h');
        expect(headerOut.pascalCase, isFalse);
        expect(headerOut.append, isNull);
        expect(sourceOut.path, 'linux');
        expect(sourceOut.extension, 'cc');
        expect(sourceOut.pascalCase, isFalse);
        expect(sourceOut.append, isNull);
      });

      test('should return default config when linux folder exists', () async {
        await Directory('linux').create();

        final gobjectConfig = GObjectConfig.fromMap(null);
        final headerOut = gobjectConfig.headerOut!;
        final sourceOut = gobjectConfig.sourceOut!;

        expect(headerOut.path, 'linux');
        expect(headerOut.extension, 'h');
        expect(headerOut.pascalCase, isFalse);
        expect(headerOut.append, isNull);
        expect(sourceOut.path, 'linux');
        expect(sourceOut.extension, 'cc');
        expect(sourceOut.pascalCase, isFalse);
        expect(sourceOut.append, isNull);
      });

      test('should create config with default values for missing fields', () {
        final gobjectConfig = GObjectConfig.fromMap({});
        final headerOut = gobjectConfig.headerOut!;
        final sourceOut = gobjectConfig.sourceOut!;

        expect(headerOut.path, 'linux');
        expect(headerOut.extension, 'h');
        expect(headerOut.pascalCase, isFalse);
        expect(headerOut.append, isNull);
        expect(sourceOut.path, 'linux');
        expect(sourceOut.extension, 'cc');
        expect(sourceOut.pascalCase, isFalse);
        expect(sourceOut.append, isNull);
      });

      test('should create config with provided values', () {
        final config = <String, dynamic>{
          'header_out': 'path/to/header',
          'source_out': 'path/to/source',
        };

        final gobjectConfig = GObjectConfig.fromMap(config);
        final headerOut = gobjectConfig.headerOut!;
        final sourceOut = gobjectConfig.sourceOut!;

        expect(headerOut.path, 'path/to/header');
        expect(headerOut.extension, 'h');
        expect(headerOut.pascalCase, isFalse);
        expect(headerOut.append, isNull);
        expect(sourceOut.path, 'path/to/source');
        expect(sourceOut.extension, 'cc');
        expect(sourceOut.pascalCase, isFalse);
        expect(sourceOut.append, isNull);
      });
    });
  });
}
