import 'dart:io';

import 'package:build/build.dart';
import 'package:path/path.dart' as path;
import 'package:pigeon/pigeon.dart';

import 'pigeon_config.dart';
import 'pigeon_extensions.dart';
import 'pigeon_scratch_space.dart';

class PigeonBuilder extends Builder {
  PigeonBuilder(this.pigeonConfig);

  final PigeonConfig pigeonConfig;

  final path.Context _pathContext = path.Context(
    style: Platform.isWindows ? path.Style.posix : path.Style.platform,
  );

  final Resource<PigeonScratchSpace> _scratchSpaceResource = Resource(
    () => PigeonScratchSpace(),
    dispose: (scratchSpace) => scratchSpace.delete(),
  );

  @override
  Map<String, List<String>> get buildExtensions {
    final result = <String, List<String>>{};

    final inputsPath = _pathContext.normalize(pigeonConfig.inputs);
    final inputsDirectory = Directory(inputsPath);

    // If inputs directory does not exist, return empty result
    if (!inputsDirectory.existsSync()) return result;

    final inputs = inputsDirectory.listSync();

    for (final input in inputs) {
      if (input is File && input.path.endsWith('.dart')) {
        final inputPath = input.path;
        final pigeonOptions = _getPigeonOptions(inputPath);
        result[inputPath] = pigeonOptions.getOutputs();
      }
    }

    return result;
  }

  @override
  Future<void> build(BuildStep buildStep) async {
    final inputId = buildStep.inputId;
    final allowedOutputs = buildStep.allowedOutputs;

    if (await buildStep.canRead(inputId)) {
      final pigeonOptions = _getPigeonOptions(inputId.path);

      final scratchSpace = await buildStep.fetchResource(
        _scratchSpaceResource,
      );

      final scratchSpacePigeonOptions = scratchSpace.getPigeonOptions(
        pigeonOptions,
        allowedOutputs,
      );

      await scratchSpace.ensureAssets(
        [AssetId(inputId.package, 'pubspec.yaml')],
        buildStep,
      );

      await Pigeon.runWithOptions(scratchSpacePigeonOptions);

      // Copy the generated outputs to their respective locations.
      for (final allowedOutput in allowedOutputs) {
        final scratchSpaceFile = scratchSpace.fileFor(allowedOutput);

        if (await scratchSpaceFile.exists()) {
          await scratchSpace.copyOutput(allowedOutput, buildStep);
        }
      }
    }
  }

  PigeonOptions _getPigeonOptions(String input) {
    final fileName = path.basenameWithoutExtension(input);

    String? getPath(String extension, String? output) {
      return output != null ? '$output/$fileName$extension' : null;
    }

    return PigeonOptions(
      input: input,
      dartOut: getPath('.g.dart', pigeonConfig.dart?.out),
      dartTestOut: getPath('_test.g.dart', pigeonConfig.dart?.testOut),
      cppHeaderOut: getPath('.g.h', pigeonConfig.cpp?.headerOut),
      cppSourceOut: getPath('.g.cpp', pigeonConfig.cpp?.sourceOut),
      cppOptions: CppOptions(namespace: pigeonConfig.cpp?.namespace),
      gobjectHeaderOut: getPath('.g.h', pigeonConfig.gobject?.headerOut),
      gobjectSourceOut: getPath('.g.cc', pigeonConfig.gobject?.sourceOut),
      gobjectOptions: GObjectOptions(module: pigeonConfig.gobject?.module),
      kotlinOut: getPath('.g.kt', pigeonConfig.kotlin?.out),
      kotlinOptions: KotlinOptions(package: pigeonConfig.kotlin?.package),
      javaOut: getPath('.g.java', pigeonConfig.java?.out),
      javaOptions: JavaOptions(
        package: pigeonConfig.java?.package,
        useGeneratedAnnotation: pigeonConfig.java?.useGeneratedAnnotation,
      ),
      swiftOut: getPath('.g.swift', pigeonConfig.swift?.out),
      objcHeaderOut: getPath('.g.h', pigeonConfig.objc?.headerOut),
      objcSourceOut: getPath('.g.m', pigeonConfig.objc?.sourceOut),
      objcOptions: ObjcOptions(prefix: pigeonConfig.objc?.prefix),
      astOut: getPath('.g.ast.json', pigeonConfig.ast?.out),
      dartPackageName: pigeonConfig.dart?.packageName,
    );
  }
}
