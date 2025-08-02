import 'dart:io';

import 'package:build/build.dart';
import 'package:path/path.dart' as path;
import 'package:pigeon/pigeon.dart';

import 'pigeon_config.dart';
import 'pigeon_scratch_space.dart';

/// A [Builder] that uses Pigeon to generate code from Dart files.
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

      final scratchSpace = await buildStep.fetchResource(_scratchSpaceResource);

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

final _scratchSpace = PigeonScratchSpace();

/// A resource that manages a scratch space for Pigeon code generation.
///
/// This resource ensures that the scratch space is created before use and
/// cleaned up after the build process is complete. It provides a temporary
/// directory for Pigeon to generate its output files, which are then copied
/// to their final locations.
final _scratchSpaceResource = Resource<PigeonScratchSpace>(
  () {
    if (!_scratchSpace.exists) {
      _scratchSpace.tempDir.createSync(recursive: true);
      _scratchSpace.exists = true;
    }

    return _scratchSpace;
  },
  beforeExit: () async {
    try {
      if (_scratchSpace.exists) {
        await _scratchSpace.delete();
      } else {
        await _scratchSpace.tempDir.delete(recursive: true);
      }
    } on FileSystemException {
      log.warning('Failed to delete temp dir: ${_scratchSpace.tempDir.path}.');
    }
  },
);

extension on PigeonOptions {
  /// Gets the list of output file paths based on the current [PigeonOptions].
  ///
  /// This method collects all the output file paths specified in the
  /// [PigeonOptions] for various languages and configurations.
  ///
  /// Returns:
  ///   A [List<String>] containing all non-null output file paths.
  List<String> getOutputs() {
    final outputs = [
      dartOut,
      dartTestOut,
      cppHeaderOut,
      cppSourceOut,
      gobjectHeaderOut,
      gobjectSourceOut,
      kotlinOut,
      javaOut,
      swiftOut,
      objcHeaderOut,
      objcSourceOut,
      astOut,
    ];

    return outputs.where((output) => output != null).cast<String>().toList();
  }
}
