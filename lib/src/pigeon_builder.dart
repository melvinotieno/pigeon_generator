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
    final inputName = path.basenameWithoutExtension(input);

    /// Converts a string to PascalCase.
    String pascalCase(String name) {
      final regex = RegExp(r'(_[a-z])|(^[a-z])');
      return name.replaceAllMapped(regex, (Match match) {
        return match[0]!.replaceAll('_', '').toUpperCase();
      });
    }

    /// Returns the path for the given output file.
    String? getPath(
      String? output,
      String extension, {
      String? append,
      bool? pascal,
    }) {
      if (output == null) return null;

      var outputName = inputName;

      if (append != null) outputName += append;

      if (pascal == true) outputName = pascalCase(outputName);

      // Replace outTemplate name with outputName and extension with extension.
      var outputFileName = pigeonConfig.outTemplate;
      outputFileName = outputFileName.replaceAll('name', outputName);
      outputFileName = outputFileName.replaceAll('extension', extension);

      return path.join(output, outputFileName);
    }

    String? cppHeaderOut = pigeonConfig.cpp?.headerOut;
    String? cppSourceOut = pigeonConfig.cpp?.sourceOut;
    String? gobjectHeaderOut = pigeonConfig.gobject?.headerOut;
    String? gobjectSourceOut = pigeonConfig.gobject?.sourceOut;
    String? kotlinOut = pigeonConfig.kotlin?.out;
    String? javaOut = pigeonConfig.java?.out;
    String? swiftOut = pigeonConfig.swift?.out;
    String? objcHeaderOut = pigeonConfig.objc?.headerOut;
    String? objcSourceOut = pigeonConfig.objc?.sourceOut;

    if (pigeonConfig.skipOutputs != null) {
      final skipOutputs = pigeonConfig.skipOutputs?[inputName];

      if (skipOutputs != null) {
        for (final skipOutput in skipOutputs) {
          switch (skipOutput) {
            case 'android':
              kotlinOut = null;
              javaOut = null;
              break;
            case 'ios':
              swiftOut = null;
              break;
            case 'macos':
              objcHeaderOut = null;
              objcSourceOut = null;
              break;
            case 'windows':
              cppHeaderOut = null;
              cppSourceOut = null;
              break;
            case 'linux':
              gobjectHeaderOut = null;
              gobjectSourceOut = null;
              break;
          }
        }
      }
    }

    return PigeonOptions(
      input: input,
      dartOut: getPath(pigeonConfig.dart?.out, 'dart'),
      dartTestOut: getPath(pigeonConfig.dart?.testOut, 'dart', append: '_test'),
      dartPackageName: pigeonConfig.dart?.packageName,
      cppHeaderOut: getPath(cppHeaderOut, 'h'),
      cppSourceOut: getPath(cppSourceOut, 'cpp'),
      cppOptions: CppOptions(namespace: pigeonConfig.cpp?.namespace),
      gobjectHeaderOut: getPath(gobjectHeaderOut, 'h'),
      gobjectSourceOut: getPath(gobjectSourceOut, 'cc'),
      gobjectOptions: GObjectOptions(module: pigeonConfig.gobject?.module),
      kotlinOut: getPath(kotlinOut, 'kt', pascal: true),
      kotlinOptions: KotlinOptions(
        package: pigeonConfig.kotlin?.package,
        errorClassName: "${pascalCase(inputName)}FlutterError",
      ),
      javaOut: getPath(javaOut, 'java', pascal: true),
      javaOptions: JavaOptions(
        package: pigeonConfig.java?.package,
        useGeneratedAnnotation: pigeonConfig.java?.useGeneratedAnnotation,
      ),
      swiftOut: getPath(swiftOut, 'swift', pascal: true),
      objcHeaderOut: getPath(objcHeaderOut, 'h'),
      objcSourceOut: getPath(objcSourceOut, 'm'),
      objcOptions: ObjcOptions(prefix: pigeonConfig.objc?.prefix),
      astOut: getPath(pigeonConfig.ast?.out, 'ast'),
      debugGenerators: pigeonConfig.debugGenerators,
      copyrightHeader: pigeonConfig.copyrightHeader,
      oneLanguage: pigeonConfig.oneLanguage,
      basePath: pigeonConfig.basePath,
    );
  }
}
