import 'dart:io';

import 'package:build/build.dart';
import 'package:path/path.dart' as path;
import 'package:pigeon/generator_tools.dart' show mergeMaps;
import 'package:pigeon/pigeon.dart';

import 'pigeon_config.dart';
import 'pigeon_extensions.dart';
import 'pigeon_scratch_space.dart';

/// A [Builder] that uses Pigeon to generate code from Dart files.
class PigeonBuilder extends Builder {
  /// Creates a new [PigeonBuilder] with the given [PigeonConfig].
  PigeonBuilder(this.pigeonConfig);

  /// The Pigeon configuration to use.
  final PigeonConfig pigeonConfig;

  /// The path context to use for file operations.
  final path.Context _pathContext = path.Context(
    style: Platform.isWindows ? path.Style.posix : path.Style.platform,
  );

  /// The resource for managing the Pigeon scratch space.
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

      await PigeonExtension.runWithGenerator(scratchSpacePigeonOptions);

      // Copy the generated outputs to their respective locations.
      for (final allowedOutput in allowedOutputs) {
        final scratchSpaceFile = scratchSpace.fileFor(allowedOutput);

        if (await scratchSpaceFile.exists()) {
          await scratchSpace.copyOutput(allowedOutput, buildStep);
        }
      }
    }
  }

  /// Returns the [PigeonOptions] for the given input file.
  PigeonOptions _getPigeonOptions(String input) {
    final parseResults = PigeonExtension.parseInput(input);

    if (parseResults.errors.isNotEmpty) {
      throw Exception('Errors found in input: ${parseResults.errors}');
    }

    final fileName = path.basenameWithoutExtension(input);

    KotlinOptions kotlinOptions = KotlinOptions(
      errorClassName: "${_pascalCase(fileName)}FlutterError",
    );

    if (pigeonConfig.kotlin?.options != null) {
      kotlinOptions = kotlinOptions.merge(pigeonConfig.kotlin!.options!);
    }

    PigeonOptions options = PigeonOptions(
      input: input,
      dartOut: _getOutPath(fileName, pigeonConfig.dart?.out),
      dartTestOut: _getOutPath(fileName, pigeonConfig.dart?.testOut),
      dartPackageName: pigeonConfig.dart?.packageName,
      dartOptions: pigeonConfig.dart?.options,
      cppHeaderOut: _getOutPath(fileName, pigeonConfig.cpp?.headerOut),
      cppSourceOut: _getOutPath(fileName, pigeonConfig.cpp?.sourceOut),
      cppOptions: pigeonConfig.cpp?.options,
      gobjectHeaderOut: _getOutPath(fileName, pigeonConfig.gobject?.headerOut),
      gobjectSourceOut: _getOutPath(fileName, pigeonConfig.gobject?.sourceOut),
      gobjectOptions: pigeonConfig.gobject?.options,
      kotlinOut: _getOutPath(fileName, pigeonConfig.kotlin?.out),
      kotlinOptions: kotlinOptions,
      javaOut: _getOutPath(fileName, pigeonConfig.java?.out),
      javaOptions: pigeonConfig.java?.options,
      swiftOut: _getOutPath(fileName, pigeonConfig.swift?.out),
      swiftOptions: pigeonConfig.swift?.options,
      objcHeaderOut: _getOutPath(fileName, pigeonConfig.objc?.headerOut),
      objcSourceOut: _getOutPath(fileName, pigeonConfig.objc?.sourceOut),
      objcOptions: pigeonConfig.objc?.options,
      astOut: _getOutPath(fileName, pigeonConfig.ast?.out),
      copyrightHeader: pigeonConfig.copyrightHeader,
      debugGenerators: pigeonConfig.debugGenerators,
      oneLanguage: pigeonConfig.oneLanguage,
      basePath: pigeonConfig.basePath,
    );

    if (parseResults.pigeonOptions != null) {
      options = PigeonOptions.fromMap(
        mergeMaps(options.toMap(), parseResults.pigeonOptions!),
      );
    }

    if (pigeonConfig.skipOutputs?.containsKey(fileName) != true) return options;

    final optionsMap = options.toMap();

    for (final skipOutput in pigeonConfig.skipOutputs![fileName]) {
      switch (skipOutput) {
        case 'android':
          optionsMap.remove('javaOut');
          optionsMap.remove('javaOptions');
          optionsMap.remove('kotlinOut');
          optionsMap.remove('kotlinOptions');
          break;
        case 'ios':
          optionsMap.remove('swiftOut');
          optionsMap.remove('swiftOptions');
        case 'macos':
          optionsMap.remove('objcHeaderOut');
          optionsMap.remove('objcSourceOut');
          optionsMap.remove('objcOptions');
          break;
        case 'windows':
          optionsMap.remove('cppHeaderOut');
          optionsMap.remove('cppSourceOut');
          optionsMap.remove('cppOptions');
          break;
        case 'linux':
          optionsMap.remove('gobjectHeaderOut');
          optionsMap.remove('gobjectSourceOut');
          optionsMap.remove('gobjectOptions');
          break;
      }
    }

    return PigeonOptions.fromMap(optionsMap);
  }

  /// Returns the file path for the given input name and output options.
  String? _getOutPath(String inputName, PigeonOutput? output) {
    if (output == null) return null;

    String fileName = inputName;

    // Append the output.append to the fileName.
    if (output.append != null) fileName += output.append!;

    // Convert the fileName to PascalCase.
    if (output.pascalCase) fileName = _pascalCase(fileName);

    // Replace outTemplate name and extension respectively.
    String outputName = pigeonConfig.outTemplate;
    outputName = outputName.replaceAll('name', fileName);
    outputName = outputName.replaceAll('extension', output.extension);

    return path.join(output.path, outputName);
  }

  /// Converts a string to PascalCase.
  String _pascalCase(String name) {
    final regex = RegExp(r'(_[a-z])|(^[a-z])');

    return name.replaceAllMapped(regex, (Match match) {
      return match[0]!.replaceAll('_', '').toUpperCase();
    });
  }
}
