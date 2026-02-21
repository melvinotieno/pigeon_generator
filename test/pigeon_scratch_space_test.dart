import 'package:build/build.dart';
import 'package:pigeon/pigeon.dart';
import 'package:pigeon_generator/src/pigeon_scratch_space.dart';
import 'package:test/test.dart';

void main() {
  group('PigeonScratchSpace', () {
    late PigeonScratchSpace scratchSpace;
    late String libPath;

    setUpAll(() {
      scratchSpace = PigeonScratchSpace();
      libPath = '${scratchSpace.tempDir.path}/package/test_package/lib';
    });

    tearDownAll(() {
      scratchSpace.delete();
    });

    test('fileFor returns correct file path', () {
      final assetId = AssetId('test_package', 'lib/test.dart');
      final file = scratchSpace.fileFor(assetId);
      final expectedPath = '$libPath/test.dart';

      expect(file.path, expectedPath);
    });

    test('getPigeonOptions updates paths correctly', () {
      final pigeonOptions = PigeonOptions(
        dartOut: 'lib/dart_out.dart',
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

      // Get the updated Pigeon options with the correct paths
      final updatedOptions = scratchSpace.getPigeonOptions(
        pigeonOptions,
        allowedOutputs,
      );

      expect(updatedOptions.dartOut, '$libPath/dart_out.dart');
      expect(updatedOptions.cppHeaderOut, '$libPath/cpp_header.h');
      expect(updatedOptions.cppSourceOut, '$libPath/cpp_source.cpp');
      expect(updatedOptions.gobjectHeaderOut, '$libPath/gobject_header.h');
      expect(updatedOptions.gobjectSourceOut, '$libPath/gobject_source.cpp');
      expect(updatedOptions.kotlinOut, '$libPath/kotlin_out.kt');
      expect(updatedOptions.javaOut, '$libPath/java_out.java');
      expect(updatedOptions.swiftOut, '$libPath/swift_out.swift');
      expect(updatedOptions.objcHeaderOut, '$libPath/objc_header.h');
      expect(updatedOptions.objcSourceOut, '$libPath/objc_source.m');
      expect(updatedOptions.astOut, '$libPath/ast_out.ast');
    });
  });
}
