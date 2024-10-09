import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:pigeon/ast.dart';
import 'package:pigeon/generator_tools.dart';
import 'package:pigeon/pigeon.dart';

/// Extension on [PigeonOptions] to provide additional functionality.
extension PigeonOptionsExtension on PigeonOptions {
  /// Gets the list of output file paths based on the current [PigeonOptions].
  ///
  /// This method collects all the output file paths specified in the
  /// [PigeonOptions] for various languages and configurations.
  ///
  /// It includes paths for:
  /// - Dart (main and test)
  /// - C++ (header and source)
  /// - GObject (header and source)
  /// - Kotlin
  /// - Java
  /// - Swift
  /// - Objective-C (header and source)
  /// - AST (Abstract Syntax Tree)
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

/// Extension on [Pigeon] to provide additional functionality.
extension PigeonExtension on Pigeon {
  static ParseResults parseInput(String input, {String? sdkPath}) {
    final Pigeon pigeon = Pigeon.setup();
    return pigeon.parseFile(input, sdkPath: sdkPath);
  }

  static Future<int> runWithGenerator(
    PigeonOptions options, {
    List<GeneratorAdapter>? adapters,
    String? sdkPath,
    bool injectOverflowTypes = false,
  }) async {
    if (options.debugGenerators ?? false) {
      debugGenerators = true;
    }

    final List<GeneratorAdapter> safeGeneratorAdapters = adapters ??
        <GeneratorAdapter>[
          DartGeneratorAdapter(),
          JavaGeneratorAdapter(),
          SwiftGeneratorAdapter(),
          KotlinGeneratorAdapter(),
          CppGeneratorAdapter(),
          GObjectGeneratorAdapter(),
          DartTestGeneratorAdapter(),
          ObjcGeneratorAdapter(),
          AstGeneratorAdapter(),
        ];

    final parseResults = parseInput(options.input!, sdkPath: sdkPath);

    if (injectOverflowTypes) {
      final List<Enum> addedEnums = List<Enum>.generate(
        totalCustomCodecKeysAllowed - 1,
        (final int tag) {
          return Enum(
            name: 'FillerEnum$tag',
            members: <EnumMember>[EnumMember(name: 'FillerMember$tag')],
          );
        },
      );

      addedEnums.addAll(parseResults.root.enums);
      parseResults.root.enums = addedEnums;
    }

    final List<Error> errors = <Error>[];
    errors.addAll(parseResults.errors);

    // Helper to clean up non-Stdout sinks.
    Future<void> releaseSink(IOSink sink) async {
      if (sink is! Stdout) {
        await sink.close();
      }
    }

    for (final GeneratorAdapter adapter in safeGeneratorAdapters) {
      if (injectOverflowTypes && adapter is GObjectGeneratorAdapter) {
        continue;
      }

      final IOSink? sink = adapter.shouldGenerate(options, FileType.source);

      if (sink != null) {
        final adapterErrors = adapter.validate(options, parseResults.root);
        errors.addAll(adapterErrors);
        await releaseSink(sink);
      }
    }

    if (errors.isNotEmpty) {
      Pigeon.printErrors(errors
          .map((Error err) => Error(
              message: err.message,
              filename: options.input,
              lineNumber: err.lineNumber))
          .toList());
      return 1;
    }

    if (options.objcHeaderOut != null) {
      options = options.merge(PigeonOptions(
          objcOptions: (options.objcOptions ?? const ObjcOptions()).merge(
              ObjcOptions(
                  headerIncludePath: options.objcOptions?.headerIncludePath ??
                      path.basename(options.objcHeaderOut!)))));
    }

    if (options.cppHeaderOut != null) {
      options = options.merge(PigeonOptions(
          cppOptions: (options.cppOptions ?? const CppOptions()).merge(
              CppOptions(
                  headerIncludePath: options.cppOptions?.headerIncludePath ??
                      path.basename(options.cppHeaderOut!)))));
    }

    if (options.gobjectHeaderOut != null) {
      options = options.merge(PigeonOptions(
          gobjectOptions: (options.gobjectOptions ?? const GObjectOptions())
              .merge(GObjectOptions(
                  headerIncludePath:
                      path.basename(options.gobjectHeaderOut!)))));
    }

    for (final GeneratorAdapter adapter in safeGeneratorAdapters) {
      for (final FileType fileType in adapter.fileTypeList) {
        final IOSink? sink = adapter.shouldGenerate(options, fileType);
        if (sink != null) {
          adapter.generate(sink, options, parseResults.root, fileType);
          await sink.flush();
          await releaseSink(sink);
        }
      }
    }

    return 0;
  }
}
