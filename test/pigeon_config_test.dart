import 'dart:io';

import 'package:pigeon_generator/src/pigeon_config.dart';
import 'package:test/test.dart';

void main() {
  group('PigeonConfig', () {
    test('should initialize with default inputs', () {
      final config = PigeonConfig();
      expect(config.inputs, 'pigeons');
    });

    test('should initialize with provided inputs', () {
      final config = PigeonConfig(inputs: 'custom_inputs');
      expect(config.inputs, 'custom_inputs');
    });

    test('should set copyright header if file exists', () {
      final config = PigeonConfig();
      final path = 'test/copyright.txt';
      File(path).createSync();
      config.setCopyrightHeader(path);
      expect(config.copyrightHeader, path);
      File(path).deleteSync();
    });

    test('should not set copyright header if file does not exist', () {
      final config = PigeonConfig();
      final path = 'non_existent_file.txt';
      config.setCopyrightHeader(path);
      expect(config.copyrightHeader, isNull);
    });

    test('should create PigeonConfig from map', () {
      final map = {
        'inputs': 'custom_inputs',
        'dart': {'out': 'lib/output.dart'},
        'cpp': {'header_out': 'include/header.h'},
        'gobject': {'header_out': 'include/gobject_header.h'},
        'kotlin': {'out': 'src/main/kotlin'},
        'java': {'out': 'src/main/java'},
        'swift': {'out': 'Sources/Swift'},
        'objc': {'header_out': 'include/objc_header.h'},
        'ast': {'out': 'ast/output.ast'},
        'one_language': true,
        'debug_generators': true,
        'base_path': 'base/path',
        'copyright_header': 'copyright.txt',
      };

      final config = PigeonConfig.fromMap(map);

      expect(config.inputs, 'custom_inputs');
      expect(config.dart?.out, 'lib/output.dart');
      expect(config.cpp?.headerOut, 'include/header.h');
      expect(config.gobject?.headerOut, 'include/gobject_header.h');
      expect(config.kotlin?.out, 'src/main/kotlin');
      expect(config.java?.out, 'src/main/java');
      expect(config.swift?.out, 'Sources/Swift');
      expect(config.objc?.headerOut, 'include/objc_header.h');
      expect(config.ast?.out, 'ast/output.ast');
      expect(config.oneLanguage, true);
      expect(config.debugGenerators, true);
      expect(config.basePath, 'base/path');
      expect(config.copyrightHeader, 'copyright.txt');
    });
  });

  group('PigeonDartConfig', () {
    test('should create PigeonDartConfig from map', () {
      final map = {
        'out': 'lib/output.dart',
        'test_out': 'test/output_test.dart',
        'package_name': 'my_package',
      };

      final config = PigeonDartConfig.fromMap(map);

      expect(config.out, 'lib/output.dart');
      expect(config.testOut, 'test/output_test.dart');
      expect(config.packageName, 'my_package');
    });

    test('should create PigeonDartConfig with defaults', () {
      final config = PigeonDartConfig.defaults(true);

      expect(config.out, 'lib');
      expect(config.testOut, 'test');
      expect(config.packageName, isNull);
    });

    test('should create PigeonDartConfig with defaults without test', () {
      final config = PigeonDartConfig.defaults(false);

      expect(config.out, 'lib');
      expect(config.testOut, isNull);
      expect(config.packageName, isNull);
    });
  });

  group('PigeonCppConfig', () {
    test('should create PigeonCppConfig from map', () {
      final map = {
        'header_out': 'include/header.h',
        'source_out': 'src/source.cpp',
        'namespace': 'my_namespace',
      };

      final config = PigeonCppConfig.fromMap(map);

      expect(config.headerOut, 'include/header.h');
      expect(config.sourceOut, 'src/source.cpp');
      expect(config.namespace, 'my_namespace');
    });

    test('should create PigeonCppConfig with defaults', () {
      final config = PigeonCppConfig.defaults();

      expect(config.headerOut, 'windows/runner');
      expect(config.sourceOut, 'windows/runner');
      expect(config.namespace, isNull);
    });
  });

  group('PigeonGobjectConfig', () {
    test('should create PigeonGobjectConfig from map', () {
      final map = {
        'header_out': 'include/gobject_header.h',
        'source_out': 'src/gobject_source.cpp',
        'module': 'my_module',
      };

      final config = PigeonGobjectConfig.fromMap(map);

      expect(config.headerOut, 'include/gobject_header.h');
      expect(config.sourceOut, 'src/gobject_source.cpp');
      expect(config.module, 'my_module');
    });

    test('should create PigeonGobjectConfig with defaults', () {
      final config = PigeonGobjectConfig.defaults();

      expect(config.headerOut, 'linux');
      expect(config.sourceOut, 'linux');
      expect(config.module, isNull);
    });
  });

  group('PigeonKotlinConfig', () {
    test('should create PigeonKotlinConfig from map', () {
      final map = {
        'out': 'src/main/kotlin',
        'package': 'com.example',
      };

      final config = PigeonKotlinConfig.fromMap(map);

      expect(config.out, 'src/main/kotlin');
      expect(config.package, 'com.example');
    });

    test('should create PigeonKotlinConfig with defaults', () {
      final config = PigeonKotlinConfig.defaults();

      expect(config.out, 'src/main/kotlin');
      expect(config.package, isNull);
    });
  });

  group('PigeonJavaConfig', () {
    test('should create PigeonJavaConfig from map', () {
      final map = {
        'out': 'src/main/java',
        'package': 'com.example',
        'use_generated_annotation': true,
      };

      final config = PigeonJavaConfig.fromMap(map);

      expect(config.out, 'src/main/java');
      expect(config.package, 'com.example');
      expect(config.useGeneratedAnnotation, true);
    });

    test('should create PigeonJavaConfig with defaults', () {
      final config = PigeonJavaConfig.defaults();

      expect(config.out, 'src/main/java');
      expect(config.package, isNull);
      expect(config.useGeneratedAnnotation, isNull);
    });
  });

  group('PigeonSwiftConfig', () {
    test('should create PigeonSwiftConfig from map', () {
      final map = {
        'out': 'Sources/Swift',
      };

      final config = PigeonSwiftConfig.fromMap(map);

      expect(config.out, 'Sources/Swift');
    });

    test('should create PigeonSwiftConfig with defaults', () {
      final config = PigeonSwiftConfig.defaults();

      expect(config.out, 'ios/Runner');
    });
  });

  group('PigeonObjcConfig', () {
    test('should create PigeonObjcConfig from map', () {
      final map = {
        'header_out': 'include/objc_header.h',
        'source_out': 'src/objc_source.m',
        'prefix': 'MY',
      };

      final config = PigeonObjcConfig.fromMap(map);

      expect(config.headerOut, 'include/objc_header.h');
      expect(config.sourceOut, 'src/objc_source.m');
      expect(config.prefix, 'MY');
    });

    test('should create PigeonObjcConfig with defaults', () {
      final config = PigeonObjcConfig.defaults();

      expect(config.headerOut, 'macos/Runner');
      expect(config.sourceOut, 'macos/Runner');
      expect(config.prefix, isNull);
    });
  });

  group('PigeonAstConfig', () {
    test('should create PigeonAstConfig from map', () {
      final map = {
        'out': 'ast/output.ast',
      };

      final config = PigeonAstConfig.fromMap(map);

      expect(config.out, 'ast/output.ast');
    });

    test('should create PigeonAstConfig with defaults', () {
      final config = PigeonAstConfig.defaults();

      expect(config.out, 'output');
    });
  });
}
