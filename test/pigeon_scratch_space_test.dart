import 'dart:io';

import 'package:build/build.dart';
import 'package:path/path.dart' as path;
import 'package:pigeon/pigeon.dart';
import 'package:pigeon_generator/src/pigeon_scratch_space.dart';
import 'package:test/test.dart';

void main() {
  group('PigeonScratchSpace Tests', () {
    late PigeonScratchSpace scratchSpace;
    late Directory tempDir;

    setUp(() {
      scratchSpace = PigeonScratchSpace();
      tempDir = scratchSpace.tempDir;
    });

    tearDown(() {
      scratchSpace.delete();
    });

    test('fileFor returns correct file path', () {
      final assetId = AssetId('test_package', 'lib/test.dart');
      final file = scratchSpace.fileFor(assetId);

      final expectedPath = path.join(
        tempDir.path,
        'package/test_package/lib/test.dart',
      );

      expect(file.path, expectedPath);
    });

    test('getPigeonOptions updates paths correctly', () {
      final pigeonOptions = PigeonOptions(
        dartOut: 'lib/dart_out.dart',
        dartTestOut: 'lib/dart_test_out.dart',
        cppHeaderOut: 'lib/cpp_header.h',
        cppSourceOut: 'lib/cpp_source.cpp',
        gobjectHeaderOut: 'lib/gobject_header.h',
        gobjectSourceOut: 'lib/gobject_source.cpp',
        kotlinOut: 'lib/kotlin_out.kt',
        javaOut: 'lib/java_out.java',
        swiftOut: 'lib/swift_out.swift',
        objcHeaderOut: 'lib/objc_header.h',
        objcSourceOut: 'lib/objc_source.m',
        astOut: 'lib/ast_out.ast',
      );

      final allowedOutputs = [
        AssetId('test_package', 'lib/dart_out.dart'),
        AssetId('test_package', 'lib/dart_test_out.dart'),
        AssetId('test_package', 'lib/cpp_header.h'),
        AssetId('test_package', 'lib/cpp_source.cpp'),
        AssetId('test_package', 'lib/gobject_header.h'),
        AssetId('test_package', 'lib/gobject_source.cpp'),
        AssetId('test_package', 'lib/kotlin_out.kt'),
        AssetId('test_package', 'lib/java_out.java'),
        AssetId('test_package', 'lib/swift_out.swift'),
        AssetId('test_package', 'lib/objc_header.h'),
        AssetId('test_package', 'lib/objc_source.m'),
        AssetId('test_package', 'lib/ast_out.ast'),
      ];

      final updatedOptions = scratchSpace.getPigeonOptions(
        pigeonOptions,
        allowedOutputs,
      );

      expect(
        updatedOptions.dartOut,
        path.join(tempDir.path, 'package/test_package/lib/dart_out.dart'),
      );
      expect(
        updatedOptions.dartTestOut,
        path.join(tempDir.path, 'package/test_package/lib/dart_test_out.dart'),
      );
      expect(
        updatedOptions.cppHeaderOut,
        path.join(tempDir.path, 'package/test_package/lib/cpp_header.h'),
      );
      expect(
        updatedOptions.cppSourceOut,
        path.join(tempDir.path, 'package/test_package/lib/cpp_source.cpp'),
      );
      expect(
        updatedOptions.gobjectHeaderOut,
        path.join(tempDir.path, 'package/test_package/lib/gobject_header.h'),
      );
      expect(
        updatedOptions.gobjectSourceOut,
        path.join(tempDir.path, 'package/test_package/lib/gobject_source.cpp'),
      );
      expect(
        updatedOptions.kotlinOut,
        path.join(tempDir.path, 'package/test_package/lib/kotlin_out.kt'),
      );
      expect(
        updatedOptions.javaOut,
        path.join(tempDir.path, 'package/test_package/lib/java_out.java'),
      );
      expect(
        updatedOptions.swiftOut,
        path.join(tempDir.path, 'package/test_package/lib/swift_out.swift'),
      );
      expect(
        updatedOptions.objcHeaderOut,
        path.join(tempDir.path, 'package/test_package/lib/objc_header.h'),
      );
      expect(
        updatedOptions.objcSourceOut,
        path.join(tempDir.path, 'package/test_package/lib/objc_source.m'),
      );
      expect(
        updatedOptions.astOut,
        path.join(tempDir.path, 'package/test_package/lib/ast_out.ast'),
      );
    });
  });
}
