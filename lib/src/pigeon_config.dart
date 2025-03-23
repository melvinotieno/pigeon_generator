import 'dart:io';

import 'package:build/build.dart';
import 'package:path/path.dart' show join, normalize;
import 'package:pigeon/pigeon.dart';

import 'config/ast_config.dart';
import 'config/cpp_config.dart';
import 'config/dart_config.dart';
import 'config/gobject_config.dart';
import 'config/java_config.dart';
import 'config/kotlin_config.dart';
import 'config/objc_config.dart';
import 'config/swift_config.dart';

class PigeonConfig {
  PigeonConfig._internal({
    required this.inputs,
    this.dart,
    this.objc,
    this.java,
    this.swift,
    this.kotlin,
    this.cpp,
    this.gobject,
    this.ast,
    this.copyrightHeader,
    this.debugGenerators,
    this.basePath,
    this.skipOutputs,
    this.outFolder,
    String? outTemplate,
  }) : outTemplate = outTemplate ?? 'name.g.extension';

  final String inputs;

  final DartConfig? dart;

  final ObjcConfig? objc;

  final JavaConfig? java;

  final SwiftConfig? swift;

  final KotlinConfig? kotlin;

  final CppConfig? cpp;

  final GObjectConfig? gobject;

  final AstConfig? ast;

  /// Path to a copyright header that will get prepended to generated code.
  final String? copyrightHeader;

  /// True means print out line number of generators in comments at newlines.
  final bool? debugGenerators;

  /// A base path to be prepended to all provided output paths.
  final String? basePath;

  final Map<String, dynamic>? skipOutputs;

  final String? outFolder;

  final String outTemplate;

  factory PigeonConfig.fromMap(Map<String, dynamic> map) {
    final inputs = normalize((map['inputs'] as String? ?? 'pigeons').trim());

    return PigeonConfig._internal(
      inputs: inputs,
      dart: DartConfig.fromMap(map['dart']),
      objc: ObjcConfig.fromMap(map['objc']),
      java: JavaConfig.fromMap(map['java']),
      swift: SwiftConfig.fromMap(map['swift']),
      kotlin: KotlinConfig.fromMap(map['kotlin']),
      cpp: CppConfig.fromMap(map['cpp']),
      gobject: GObjectConfig.fromMap(map['gobject']),
      ast: AstConfig.fromMap(map['ast']),
      copyrightHeader: _getCopyrightHeader(inputs, map['copyright_header']),
      debugGenerators: map['debug_generators'] as bool?,
      basePath: map['base_path'] as String?,
      outFolder: map['out_folder'] as String?,
      outTemplate: map['out_template'] as String?,
    );
  }

  PigeonOptions getPigeonOptions(String input) {
    return PigeonOptions();
  }

  static String? _getCopyrightHeader(String inputs, String? defaultPath) {
    if (defaultPath != null) {
      final path = normalize(defaultPath.trim());

      // If file exists, return the path, otherwise, attempt to find a
      // copyright header file in the inputs path.
      if (File(path).existsSync()) {
        return path;
      } else {
        log.warning(
          'Warning: The copyright_header path ["$path"] specified in the '
          'configuration does not exist. If a copyright_header.txt or '
          'copyright.txt file is found in the inputs path [$inputs] provided, '
          'then it will be used instead.',
        );
      }
    }

    final possibleFiles = ['copyright.txt', 'copyright_header.txt'];
    for (final file in possibleFiles) {
      final path = normalize(join(inputs, file));
      if (File(path).existsSync()) {
        return path;
      }
    }

    return null;
  }
}
