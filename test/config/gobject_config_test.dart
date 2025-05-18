import 'dart:io';

import 'package:pigeon_generator/src/config/gobject_config.dart';
import 'package:test/test.dart';

void main() {
  group('GObjectConfig', () {
    test('should create GObjectConfig of null values when map is false', () {
      final gobjectConfig = GObjectConfig.fromMap(false);

      expect(gobjectConfig.headerOut, isNull);
      expect(gobjectConfig.sourceOut, isNull);
      expect(gobjectConfig.options, isNull);
    });

    test('should create GObjectConfig with null values when map is null', () {
      final gobjectConfig = GObjectConfig.fromMap(null);

      expect(gobjectConfig.headerOut, isNull);
      expect(gobjectConfig.sourceOut, isNull);
      expect(gobjectConfig.options, isNull);
    });

    test(
      'should create GObjectConfig with default values when map is true',
      () {
        final gobjectConfig = GObjectConfig.fromMap(true);

        expect(gobjectConfig.headerOut?.path, 'linux');
        expect(gobjectConfig.headerOut?.extension, 'h');
        expect(gobjectConfig.headerOut?.pascalCase, isFalse);
        expect(gobjectConfig.headerOut?.append, isNull);
        expect(gobjectConfig.sourceOut?.path, 'linux');
        expect(gobjectConfig.sourceOut?.extension, 'cc');
        expect(gobjectConfig.sourceOut?.pascalCase, isFalse);
        expect(gobjectConfig.sourceOut?.append, isNull);
        expect(gobjectConfig.options, isNull);
      },
    );

    test(
      'should create GObjectConfig with default values when linux directory exists',
      () {
        Directory('linux').createSync();

        try {
          final gobjectConfig = GObjectConfig.fromMap(null);

          expect(gobjectConfig.headerOut?.path, 'linux');
          expect(gobjectConfig.headerOut?.extension, 'h');
          expect(gobjectConfig.headerOut?.pascalCase, isFalse);
          expect(gobjectConfig.headerOut?.append, isNull);
          expect(gobjectConfig.sourceOut?.path, 'linux');
          expect(gobjectConfig.sourceOut?.extension, 'cc');
          expect(gobjectConfig.sourceOut?.pascalCase, isFalse);
          expect(gobjectConfig.sourceOut?.append, isNull);
          expect(gobjectConfig.options, isNull);
        } finally {
          Directory('linux').deleteSync();
        }
      },
    );

    test(
      'should create GObjectConfig with default values for missing fields',
      () {
        final gobjectConfig = GObjectConfig.fromMap({});

        expect(gobjectConfig.headerOut?.path, 'linux');
        expect(gobjectConfig.headerOut?.extension, 'h');
        expect(gobjectConfig.headerOut?.pascalCase, isFalse);
        expect(gobjectConfig.headerOut?.append, isNull);
        expect(gobjectConfig.sourceOut?.path, 'linux');
        expect(gobjectConfig.sourceOut?.extension, 'cc');
        expect(gobjectConfig.sourceOut?.pascalCase, isFalse);
        expect(gobjectConfig.sourceOut?.append, isNull);
        expect(gobjectConfig.options, isNull);
      },
    );

    test('should create GObjectConfig from config map', () {
      final config = <String, dynamic>{
        'header_out': 'path/to/header',
        'source_out': 'path/to/source',
        'options': {
          'header_include_path': 'path/to/include',
          'module': 'module_name',
          'copyright_header': ['Copyright (c) 2023'],
          'header_out_path': 'path/to/header_out',
        },
      };

      final gobjectConfig = GObjectConfig.fromMap(config);

      expect(gobjectConfig.headerOut?.path, 'path/to/header');
      expect(gobjectConfig.headerOut?.extension, 'h');
      expect(gobjectConfig.headerOut?.pascalCase, isFalse);
      expect(gobjectConfig.headerOut?.append, isNull);
      expect(gobjectConfig.sourceOut?.path, 'path/to/source');
      expect(gobjectConfig.sourceOut?.extension, 'cc');
      expect(gobjectConfig.sourceOut?.pascalCase, isFalse);
      expect(gobjectConfig.sourceOut?.append, isNull);
      expect(gobjectConfig.options?.headerIncludePath, 'path/to/include');
      expect(gobjectConfig.options?.module, 'module_name');
      expect(gobjectConfig.options?.copyrightHeader, ['Copyright (c) 2023']);
      expect(gobjectConfig.options?.headerOutPath, 'path/to/header_out');
    });
  });
}
