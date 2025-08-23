import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:pigeon/pigeon.dart';

import 'config/ast_config.dart';
import 'config/cpp_config.dart';
import 'config/dart_config.dart';
import 'config/gobject_config.dart';
import 'config/java_config.dart';
import 'config/kotlin_config.dart';
import 'config/objc_config.dart';
import 'config/output_config.dart';
import 'config/swift_config.dart';
import 'pigeon_extensions.dart';

/// Configuration for Pigeon code generation.
class PigeonConfig {
  PigeonConfig._internal({
    required this.inputs,
    required this.dart,
    required this.objc,
    required this.java,
    required this.swift,
    required this.kotlin,
    required this.cpp,
    required this.gobject,
    required this.ast,
    this.copyrightHeader,
    this.debugGenerators,
    this.basePath,
    this.skipOutputs,
    this.outFolder,
    String? outTemplate,
  }) : outTemplate = outTemplate ?? 'name.g.extension';

  /// Path to Pigeon input files.
  final String inputs;

  /// Configuration for Dart code generation.
  final DartConfig dart;

  /// Configuration for Objective-C code generation.
  final ObjcConfig objc;

  /// Configuration for Java code generation.
  final JavaConfig java;

  /// Configuration for Swift code generation.
  final SwiftConfig swift;

  /// Configuration for Kotlin code generation.
  final KotlinConfig kotlin;

  /// Configuration for C++ code generation.
  final CppConfig cpp;

  /// Configuration for GObject code generation.
  final GObjectConfig gobject;

  /// Configuration for AST code generation.
  final AstConfig ast;

  /// Path to a copyright header that will get prepended to generated code.
  final String? copyrightHeader;

  /// True means print out line number of generators in comments at newlines.
  final bool? debugGenerators;

  /// A base path to be prepended to all provided output paths.
  final String? basePath;

  /// Declares which code generation outputs should be skipped.
  final dynamic skipOutputs;

  /// The output folder for generated files.
  final String? outFolder;

  /// The template for naming the generated files.
  final String outTemplate;

  /// Creates a new [PigeonConfig] from a map.
  factory PigeonConfig.fromMap(Map<String, dynamic> map) {
    final inputs = map['inputs'] as String? ?? 'pigeons';

    String? copyrightHeader = map['copyright_header'] as String?;
    if (copyrightHeader == null) {
      // If copyright.txt file exists in inputs, set as copyright header.
      final copyrightPath = path.join(inputs, 'copyright.txt');
      final hasCopyright = File(copyrightPath).existsSync();
      if (hasCopyright) copyrightHeader = copyrightPath;
    }

    String? outFolder = map['out_folder'] as String?;

    return PigeonConfig._internal(
      inputs: inputs,
      dart: DartConfig.fromMap(map['dart'], outFolder),
      objc: ObjcConfig.fromMap(map['objc'], outFolder),
      java: JavaConfig.fromMap(map['java'], outFolder),
      swift: SwiftConfig.fromMap(map['swift'], outFolder),
      kotlin: KotlinConfig.fromMap(map['kotlin'], outFolder),
      cpp: CppConfig.fromMap(map['cpp'], outFolder),
      gobject: GObjectConfig.fromMap(map['gobject'], outFolder),
      ast: AstConfig.fromMap(map['ast'], outFolder),
      copyrightHeader: copyrightHeader,
      debugGenerators: map['debug_generators'] as bool?,
      basePath: map['base_path'] as String?,
      skipOutputs: map['skip_outputs'], // YamlMap
      outFolder: outFolder,
      outTemplate: map['out_template'] as String?,
    );
  }

  /// Get pigeon options for a specific input file.
  PigeonOptions getPigeonOptions(String input) {
    final fileName = path.basenameWithoutExtension(input);

    String? getOutputPath(OutputConfig? config) {
      if (config == null) return null;

      String name = fileName;

      // Append to name if append is provided.
      if (config.append != null) name += config.append!;

      // Use PascalCase if specified.
      if (config.pascalCase) name = name.pascalCase;

      // Replace outTemplate placeholders.
      String outputName = outTemplate;
      outputName = outputName.replaceAll('name', name);
      outputName = outputName.replaceAll('extension', config.extension);

      return path.join(config.path, outputName);
    }

    PigeonOptions options = PigeonOptions(
      input: input,
      dartOut: getOutputPath(dart.out),
      dartTestOut: getOutputPath(dart.testOut),
      dartPackageName: dart.packageName,
      dartOptions: dart.getOptions(fileName),
      objcHeaderOut: getOutputPath(objc.headerOut),
      objcSourceOut: getOutputPath(objc.sourceOut),
      objcOptions: objc.getOptions(fileName),
      javaOut: getOutputPath(java.out),
      javaOptions: java.getOptions(fileName),
      swiftOut: getOutputPath(swift.out),
      swiftOptions: swift.getOptions(fileName),
      kotlinOut: getOutputPath(kotlin.out),
      kotlinOptions: kotlin.getOptions(fileName),
      cppHeaderOut: getOutputPath(cpp.headerOut),
      cppSourceOut: getOutputPath(cpp.sourceOut),
      cppOptions: cpp.getOptions(fileName),
      gobjectHeaderOut: getOutputPath(gobject.headerOut),
      gobjectSourceOut: getOutputPath(gobject.sourceOut),
      gobjectOptions: gobject.getOptions(fileName),
      astOut: getOutputPath(ast.out),
      debugGenerators: debugGenerators,
      basePath: basePath,
    );

    if (skipOutputs?.containsKey(fileName) == true) {
      options = options.skipOutputs(skipOutputs[fileName]);
    }

    return options.mergeInputOptions(input);
  }
}
