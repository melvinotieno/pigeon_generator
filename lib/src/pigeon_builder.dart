import 'dart:io';

import 'package:build/build.dart';
import 'package:path/path.dart' as path;
import 'package:pigeon/pigeon.dart';

import 'pigeon_config.dart';
import 'pigeon_extensions.dart';
import 'pigeon_scratch_space.dart';

/// A [Builder] that uses Pigeon to generate code from Dart input files.
class PigeonBuilder extends Builder {
  /// Creates a new [PigeonBuilder] with the given [PigeonConfig].
  PigeonBuilder(this.config);

  /// The Pigeon configuration to use.
  final PigeonConfig config;

  /// The path context to use for file operations.
  final path.Context _pathContext = path.Context();

  @override
  Map<String, List<String>> get buildExtensions {
    final result = <String, List<String>>{};

    final inputsPath = _pathContext.normalize(config.inputs);
    final inputsDirectory = Directory(inputsPath);

    // If inputs directory does not exist, return empty result.
    if (!inputsDirectory.existsSync()) return result;

    // Iterate through all Dart files in the inputs directory.
    // For each file, get the Pigeon options and their outputs.
    for (final entity in inputsDirectory.listSync()) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final input = entity.path;
        final pigeonOptions = config.getPigeonOptions(input);
        result[input] = pigeonOptions.getOutputs();
      }
    }

    return result;
  }

  @override
  Future<void> build(BuildStep buildStep) async {
    final inputId = buildStep.inputId;
    final allowedOutputs = buildStep.allowedOutputs;

    if (await buildStep.canRead(inputId)) {
      final pigeonOptions = config.getPigeonOptions(inputId.path);

      final scratchSpace = await buildStep.fetchResource(scratchSpaceResource);

      // Code will be generated to the scratch space resource, therefore, the
      // PigeonOptions will be modified to reflect the scratch space paths.
      final scratchSpacePigeonOptions = scratchSpace.getPigeonOptions(
        pigeonOptions,
        allowedOutputs,
      );

      await scratchSpace.ensureAssets([
        AssetId(inputId.package, 'pubspec.yaml'),
      ], buildStep);

      // Make sure that all output directories exist.
      for (final output in scratchSpacePigeonOptions.getOutputs()) {
        final Directory outputDir = File(output).parent;

        if (!await outputDir.exists()) {
          await outputDir.create(recursive: true);
        }
      }

      await Pigeon.runWithOptions(
        scratchSpacePigeonOptions,
        mergeDefinitionFileOptions: false,
      );

      // Copy the generated outputs to their respective locations.
      for (final allowedOutput in allowedOutputs) {
        final scratchSpaceFile = scratchSpace.fileFor(allowedOutput);

        if (await scratchSpaceFile.exists()) {
          await scratchSpace.copyOutput(allowedOutput, buildStep);
        }
      }
    }
  }
}
