import 'package:build/build.dart';
import 'package:path/path.dart' as p;
import 'package:pigeon/pigeon.dart';
import 'package:pigeon_generator/src/pigeon_scratch_space.dart';
import 'package:test/test.dart';

void main() {
  group('PigeonScratchSpace', () {
    late PigeonScratchSpace scratchSpace;
    late String libPath;

    setUpAll(() {
      scratchSpace = PigeonScratchSpace();
      libPath = p.join(
        scratchSpace.tempDir.path,
        'package',
        'test_package',
        'lib',
      );
    });

    tearDownAll(() {
      scratchSpace.delete();
    });

    test('fileFor returns correct file path', () {
      final assetId = AssetId('test_package', 'lib/test.dart');
      final file = scratchSpace.fileFor(assetId);
      final expectedPath = p.join(libPath, 'test.dart');

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

      expect(updatedOptions.dartOut, p.join(libPath, 'dart_out.dart'));
      expect(updatedOptions.cppHeaderOut, p.join(libPath, 'cpp_header.h'));
      expect(updatedOptions.cppSourceOut, p.join(libPath, 'cpp_source.cpp'));
      expect(
        updatedOptions.gobjectHeaderOut,
        p.join(libPath, 'gobject_header.h'),
      );
      expect(
        updatedOptions.gobjectSourceOut,
        p.join(libPath, 'gobject_source.cpp'),
      );
      expect(updatedOptions.kotlinOut, p.join(libPath, 'kotlin_out.kt'));
      expect(updatedOptions.javaOut, p.join(libPath, 'java_out.java'));
      expect(updatedOptions.swiftOut, p.join(libPath, 'swift_out.swift'));
      expect(updatedOptions.objcHeaderOut, p.join(libPath, 'objc_header.h'));
      expect(updatedOptions.objcSourceOut, p.join(libPath, 'objc_source.m'));
      expect(updatedOptions.astOut, p.join(libPath, 'ast_out.ast'));

      final multiSwiftOptions = PigeonOptions(
        swiftOut: ['lib/swift_out_1.swift', 'lib/swift_out_2.swift'],
      );
      final multiSwiftAllowedOutputs = [
        AssetId('test_package', 'lib/swift_out_1.swift'),
        AssetId('test_package', 'lib/swift_out_2.swift'),
      ];
      final updatedMultiSwiftOptions = scratchSpace.getPigeonOptions(
        multiSwiftOptions,
        multiSwiftAllowedOutputs,
      );

      expect(updatedMultiSwiftOptions.swiftOut, [
        p.join(libPath, 'swift_out_1.swift'),
        p.join(libPath, 'swift_out_2.swift'),
      ]);
    });
  });
}
