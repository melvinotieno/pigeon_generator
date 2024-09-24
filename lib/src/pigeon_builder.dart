import 'dart:io';

import 'package:build/build.dart';
import 'package:path/path.dart' as path;
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

  /// Returns the [PigeonOptions] for the given input file.
  PigeonOptions _getPigeonOptions(String input) {
    String? getPath(
      String? output,
      String extension, {
      String? append,
      bool? capitalize,
    }) {
      if (output == null) return null;

      final inputName = path.basenameWithoutExtension(input);

      var outputName = inputName;

      if (append != null) outputName += append;

      if (capitalize == true) {
        // If outputName is snake case, capitalize the first letter of each word
        // and remove the underscores.
        final regex = RegExp(r'(_[a-z])|(^[a-z])');
        outputName = outputName.replaceAllMapped(regex, (Match match) {
          return match[0]!.replaceAll('_', '').toUpperCase();
        });
      }

      // Replace outTemplate name with outputName and extension with extension.
      var outputFileName = pigeonConfig.outTemplate;
      outputFileName = outputFileName.replaceAll('name', outputName);
      outputFileName = outputFileName.replaceAll('extension', extension);

      return path.join(output, outputFileName);
    }

    return PigeonOptions(
      input: input,
      dartOut: getPath(pigeonConfig.dart?.out, 'dart'),
      dartTestOut: getPath(pigeonConfig.dart?.testOut, 'dart', append: '_test'),
      dartPackageName: pigeonConfig.dart?.packageName,
      cppHeaderOut: getPath(pigeonConfig.cpp?.headerOut, 'h'),
      cppSourceOut: getPath(pigeonConfig.cpp?.sourceOut, 'cpp'),
      cppOptions: CppOptions(namespace: pigeonConfig.cpp?.namespace),
      gobjectHeaderOut: getPath(pigeonConfig.gobject?.headerOut, 'h'),
      gobjectSourceOut: getPath(pigeonConfig.gobject?.sourceOut, 'cc'),
      gobjectOptions: GObjectOptions(module: pigeonConfig.gobject?.module),
      kotlinOut: getPath(pigeonConfig.kotlin?.out, 'kt', capitalize: true),
      kotlinOptions: KotlinOptions(package: pigeonConfig.kotlin?.package),
      javaOut: getPath(pigeonConfig.java?.out, 'java', capitalize: true),
      javaOptions: JavaOptions(
        package: pigeonConfig.java?.package,
        useGeneratedAnnotation: pigeonConfig.java?.useGeneratedAnnotation,
      ),
      swiftOut: getPath(pigeonConfig.swift?.out, 'swift', capitalize: true),
      objcHeaderOut: getPath(pigeonConfig.objc?.headerOut, 'h'),
      objcSourceOut: getPath(pigeonConfig.objc?.sourceOut, 'm'),
      objcOptions: ObjcOptions(prefix: pigeonConfig.objc?.prefix),
      astOut: getPath(pigeonConfig.ast?.out, 'ast'),
      debugGenerators: pigeonConfig.debugGenerators,
      copyrightHeader: pigeonConfig.copyrightHeader,
      oneLanguage: pigeonConfig.oneLanguage,
      basePath: pigeonConfig.basePath,
    );
  }
}
