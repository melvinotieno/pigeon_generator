import 'dart:io';

import 'package:pigeon_generator/src/config/cpp_config.dart';
import 'package:test/test.dart';

void main() {
  group('CppConfig', () {
    test('should create CppConfig of null values when map is false', () {
      final cppConfig = CppConfig.fromMap(false);

      expect(cppConfig.headerOut, isNull);
      expect(cppConfig.sourceOut, isNull);
      expect(cppConfig.options, isNull);
    });

    test('should create CppConfig with null values when map is null', () {
      final cppConfig = CppConfig.fromMap(null);

      expect(cppConfig.headerOut, isNull);
      expect(cppConfig.sourceOut, isNull);
      expect(cppConfig.options, isNull);
    });

    test('should create CppConfig with default values when map is true', () {
      final cppConfig = CppConfig.fromMap(true);

      expect(cppConfig.headerOut?.path, 'windows/runner');
      expect(cppConfig.headerOut?.extension, 'h');
      expect(cppConfig.sourceOut?.path, 'windows/runner');
      expect(cppConfig.sourceOut?.extension, 'cpp');
      expect(cppConfig.options, isNull);
    });

    test('should create CppConfig with default values when windows exists', () {
      Directory('windows').createSync();

      try {
        final cppConfig = CppConfig.fromMap(null);

        expect(cppConfig.headerOut?.path, 'windows/runner');
        expect(cppConfig.headerOut?.extension, 'h');
        expect(cppConfig.sourceOut?.path, 'windows/runner');
        expect(cppConfig.sourceOut?.extension, 'cpp');
        expect(cppConfig.options, isNull);
      } finally {
        Directory('windows').deleteSync();
      }
    });

    test('should create CppConfig with default values for missing fields', () {
      final cppConfig = CppConfig.fromMap({});

      expect(cppConfig.headerOut?.path, 'windows/runner');
      expect(cppConfig.headerOut?.extension, 'h');
      expect(cppConfig.sourceOut?.path, 'windows/runner');
      expect(cppConfig.sourceOut?.extension, 'cpp');
      expect(cppConfig.options, isNull);
    });

    test('should create CppConfig from config map', () {
      final config = <String, dynamic>{
        'header_out': 'path/to/header',
        'source_out': 'path/to/source',
        'options': {
          'header_include_path': 'include/path',
          'namespace': 'namespace',
          'copyright_header': ['Copyright (c) 2023'],
          'header_out_path': 'path/to/header_out',
        },
      };

      final cppConfig = CppConfig.fromMap(config);

      expect(cppConfig.headerOut?.path, 'path/to/header');
      expect(cppConfig.headerOut?.extension, 'h');
      expect(cppConfig.sourceOut?.path, 'path/to/source');
      expect(cppConfig.sourceOut?.extension, 'cpp');
      expect(cppConfig.options?.headerIncludePath, 'include/path');
      expect(cppConfig.options?.namespace, 'namespace');
      expect(cppConfig.options?.copyrightHeader, ['Copyright (c) 2023']);
      expect(cppConfig.options?.headerOutPath, 'path/to/header_out');
    });
  });
}
