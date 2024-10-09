import 'dart:io';

import 'package:path/path.dart' show join, normalize;
import 'package:pigeon/pigeon.dart';

import 'pigeon_utilities.dart';

/// Configuration for Pigeon code generation.
class PigeonConfig {
  PigeonConfig({
    required this.inputs,
    this.dart,
    this.cpp,
    this.gobject,
    this.kotlin,
    this.java,
    this.swift,
    this.objc,
    this.ast,
    this.copyrightHeader,
    this.oneLanguage,
    this.debugGenerators,
    this.basePath,
    this.skipOutputs,
    String? outTemplate,
  }) : outTemplate = outTemplate ?? 'name.g.extension';

  /// The input directory of the Pigeon files.
  final String inputs;

  /// Configuration for Dart code generation.
  final PigeonDartConfig? dart;

  /// Configuration for C++ code generation.
  final PigeonCppConfig? cpp;

  /// Configuration for GObject code generation.
  final PigeonGobjectConfig? gobject;

  /// Configuration for Kotlin code generation.
  final PigeonKotlinConfig? kotlin;

  /// Configuration for Java code generation.
  final PigeonJavaConfig? java;

  /// Configuration for Swift code generation.
  final PigeonSwiftConfig? swift;

  /// Configuration for Objective-C code generation.
  final PigeonObjcConfig? objc;

  /// Configuration for AST (Abstract Syntax Tree) generation.
  final PigeonAstConfig? ast;

  /// Path to a copyright header that will get prepended to generated code.
  final String? copyrightHeader;

  /// If Pigeon allows generating code for one language.
  final bool? oneLanguage;

  /// True means print out line number of generators in comments at newlines.
  final bool? debugGenerators;

  /// A base path to be prepended to all provided output paths.
  final String? basePath;

  /// Declares which outputs to skip.
  final dynamic skipOutputs;

  /// The template for naming the generated files.
  final String outTemplate;

  /// Creates a [PigeonConfig] from the provided config.
  factory PigeonConfig.fromConfig(Map<String, dynamic> config) {
    final inputs = normalize((config['inputs'] as String? ?? 'pigeons').trim());
    final oneLanguage = config['one_language'] as bool?;

    var copyrightHeader = config['copyright_header'] as String?;
    if (copyrightHeader == null) {
      // If copyright.txt file exists in inputs, set as copyright header.
      final copyrightPath = join(inputs, 'copyright.txt');
      final hasCopyright = File(copyrightPath).existsSync();
      if (hasCopyright) copyrightHeader = copyrightPath;
    }

    return PigeonConfig(
      inputs: inputs,
      dart: PigeonDartConfig.fromConfig(config['dart'], oneLanguage),
      cpp: PigeonCppConfig.fromConfig(config['cpp']),
      gobject: PigeonGobjectConfig.fromConfig(config['gobject']),
      kotlin: PigeonKotlinConfig.fromConfig(config['kotlin']),
      java: PigeonJavaConfig.fromConfig(config['java']),
      swift: PigeonSwiftConfig.fromConfig(config['swift']),
      objc: PigeonObjcConfig.fromConfig(config['objc']),
      ast: PigeonAstConfig.fromConfig(config['ast']),
      copyrightHeader: copyrightHeader,
      oneLanguage: oneLanguage,
      debugGenerators: config['debug_generators'] as bool?,
      basePath: config['base_path'] as String?,
      skipOutputs: config['skip_outputs'], // YamlMap
      outTemplate: config['out_template'] as String?,
    );
  }
}

/// Configuration for Dart code generation.
class PigeonDartConfig {
  PigeonDartConfig({this.out, this.testOut, this.packageName, this.options});

  /// The output details for the generated Dart code.
  final PigeonOutput? out;

  /// The output details for the generated Dart test code.
  final PigeonOutput? testOut;

  /// The package name for the generated Dart code.
  final String? packageName;

  /// Options that control how Dart will be generated.
  final DartOptions? options;

  /// Creates a [PigeonDartConfig] from the provided config.
  ///
  /// If config is null and oneLanguage is true, it returns null.
  static PigeonDartConfig? fromConfig(dynamic config, bool? oneLanguage) {
    if (config == null && oneLanguage == true) return null;

    final options = config['options'];

    return PigeonDartConfig(
      out: PigeonOutput(
        config['out'] as String? ?? 'lib/pigeons',
        extension: 'dart',
      ),
      testOut: PigeonOutput.fromConfig(
        _getTestOutPath(config['test_out']),
        extension: 'dart',
        append: '_test',
      ),
      packageName: config?['package_name'] as String?,
      options: DartOptions(
        copyrightHeader: options?['copyright_header'] as Iterable<String>?,
      ),
    );
  }

  /// Returns the generated Dart test code output path.
  ///
  /// If config is null, return default if `test` directory exists.
  ///
  /// If the config is a boolean and true, return the default.
  static String? _getTestOutPath(dynamic config) {
    if (config == null) {
      final testDir = Directory('test');
      return testDir.existsSync() ? 'test/pigeons' : null;
    }

    if (config is bool) return config ? 'test/pigeons' : null;

    return config as String;
  }
}

/// Configuration for C++ code generation.
class PigeonCppConfig {
  PigeonCppConfig({this.headerOut, this.sourceOut, this.options});

  /// The output details for the generated C++ header file.
  final PigeonOutput? headerOut;

  /// The output details for the generated C++ source file.
  final PigeonOutput? sourceOut;

  /// Options that control how C++ source will be generated.
  final CppOptions? options;

  /// Creates a [PigeonCppConfig] from the provided config.
  ///
  /// If config is null, return default if `windows` directory exists.
  ///
  /// If the config is a boolean and true, return the default.
  static PigeonCppConfig? fromConfig(dynamic config) {
    final cpp = PigeonCppConfig(
      headerOut: PigeonOutput('windows/runner/pigeons', extension: 'h'),
      sourceOut: PigeonOutput('windows/runner/pigeons', extension: 'cpp'),
    );

    if (config == null) {
      final windowsDir = Directory('windows');
      return windowsDir.existsSync() ? cpp : null;
    }

    if (config is bool) return config ? cpp : null;

    final options = config['options'];

    return PigeonCppConfig(
      headerOut: PigeonOutput.fromConfig(
        config['header_out'] as String?,
        extension: cpp.headerOut!.extension,
      ),
      sourceOut: PigeonOutput.fromConfig(
        config['source_out'] as String?,
        extension: cpp.sourceOut!.extension,
      ),
      options: CppOptions(
        namespace: config('namespace') as String?,
        copyrightHeader: options?['copyright_header'] as Iterable<String>?,
      ),
    );
  }
}

/// Configuration for GObject code generation.
class PigeonGobjectConfig {
  PigeonGobjectConfig({this.headerOut, this.sourceOut, this.options});

  /// The output details for the generated GObject header file.
  final PigeonOutput? headerOut;

  /// The output details for the generated GObject source file.
  final PigeonOutput? sourceOut;

  /// Options that control how GObject source will be generated.
  final GObjectOptions? options;

  /// Creates a [PigeonGobjectConfig] from the provided config.
  ///
  /// If config is null, return default if `linux` directory exists.
  ///
  /// If the config is a boolean and true, return the default.
  static PigeonGobjectConfig? fromConfig(dynamic config) {
    final gobject = PigeonGobjectConfig(
      headerOut: PigeonOutput('linux/pigeons', extension: 'h'),
      sourceOut: PigeonOutput('linux/pigeons', extension: 'cc'),
    );

    if (config == null) {
      final linuxDir = Directory('linux');
      return linuxDir.existsSync() ? gobject : null;
    }

    if (config is bool) return config ? gobject : null;

    final options = config['options'];

    return PigeonGobjectConfig(
      headerOut: PigeonOutput.fromConfig(
        config['header_out'] as String?,
        extension: gobject.headerOut!.extension,
      ),
      sourceOut: PigeonOutput.fromConfig(
        config['source_out'] as String?,
        extension: gobject.sourceOut!.extension,
      ),
      options: GObjectOptions(
        module: config('module') as String?,
        copyrightHeader: options?['copyright_header'] as Iterable<String>?,
      ),
    );
  }
}

/// Configuration for Kotlin code generation.
class PigeonKotlinConfig {
  PigeonKotlinConfig({this.out, this.options});

  /// The output details for the generated Kotlin code.
  final PigeonOutput? out;

  /// Options that control how Kotlin will be generated.
  final KotlinOptions? options;

  /// Creates a [PigeonKotlinConfig] from the provided config.
  ///
  /// If config is null, return default if `android` directory exists.
  ///
  /// If the config is a boolean and true, return the default.
  static PigeonKotlinConfig? fromConfig(dynamic config) {
    if (config == null) {
      final androidDir = Directory('android');
      return androidDir.existsSync() ? _default : null;
    }

    if (config is bool) return config ? _default : null;

    final options = config['options'];

    return PigeonKotlinConfig(
      out: PigeonOutput.fromConfig(
        config['out'] as String?,
        extension: 'kt',
        pascalCase: true,
      ),
      options: KotlinOptions(
        package: options?['package'] as String?,
        copyrightHeader: options?['copyright_header'] as Iterable<String>?,
      ),
    );
  }

  /// Returns the default configuration for Kotlin code generation.
  static PigeonKotlinConfig? get _default {
    if (android.getApplicationId() == null) return null;

    return PigeonKotlinConfig(
      out: PigeonOutput(
        android.getOutPath('kotlin')!,
        extension: 'kt',
        pascalCase: true,
      ),
      options: KotlinOptions(
        package: android.getPackage(),
      ),
    );
  }
}

/// Configuration for Java code generation.
class PigeonJavaConfig {
  PigeonJavaConfig({this.out, this.options});

  /// The output details for the generated Java code.
  final PigeonOutput? out;

  /// Options that control how Java will be generated.
  final JavaOptions? options;

  /// Creates a [PigeonJavaConfig] from the provided config.
  ///
  /// If the config is a boolean and true, return the default.
  static PigeonJavaConfig? fromConfig(dynamic config) {
    // For Android, Kotlin is the language of choice.
    if (config == null) return null;

    if (config is bool) return config ? _default : null;

    final options = config['options'];

    return PigeonJavaConfig(
      out: PigeonOutput.fromConfig(
        config['out'] as String?,
        extension: 'java',
        pascalCase: true,
      ),
      options: JavaOptions(
        package: options?['package'] as String?,
        copyrightHeader: options?['copyright_header'] as Iterable<String>?,
        useGeneratedAnnotation: options?['use_generated_annotation'] as bool?,
      ),
    );
  }

  /// Returns the default configuration for Java code generation.
  static PigeonJavaConfig? get _default {
    if (android.getApplicationId() == null) return null;

    return PigeonJavaConfig(
      out: PigeonOutput(
        android.getOutPath('java')!,
        extension: 'java',
        pascalCase: true,
      ),
      options: JavaOptions(
        package: android.getPackage(),
      ),
    );
  }
}

/// Configuration for Swift code generation.
class PigeonSwiftConfig {
  PigeonSwiftConfig({this.out, this.options});

  /// The output details for the generated Swift code.
  final PigeonOutput? out;

  /// Options that control how Swift will be generated.
  final SwiftOptions? options;

  /// Creates a [PigeonSwiftConfig] from the provided config.
  ///
  /// If config is null, return default if `ios` directory exists.
  ///
  /// If the config is a boolean and true, return the default.
  static PigeonSwiftConfig? fromConfig(dynamic config) {
    final swift = PigeonSwiftConfig(
      out: PigeonOutput(
        'ios/Runner/Pigeons',
        extension: 'swift',
        pascalCase: true,
      ),
    );

    if (config == null) {
      final iosDir = Directory('ios');
      return iosDir.existsSync() ? swift : null;
    }

    if (config is bool) return config ? swift : null;

    final options = config['options'];

    return PigeonSwiftConfig(
      out: PigeonOutput.fromConfig(
        config['out'] as String?,
        extension: swift.out!.extension,
        pascalCase: true,
      ),
      options: SwiftOptions(
        copyrightHeader: options?['copyright_header'] as Iterable<String>?,
      ),
    );
  }
}

/// Configuration for Objective-C code generation.
class PigeonObjcConfig {
  PigeonObjcConfig({this.headerOut, this.sourceOut, this.options});

  /// The output details for the generated Objective-C header code.
  final PigeonOutput? headerOut;

  /// The output details for the generated Objective-C source code.
  final PigeonOutput? sourceOut;

  /// Options that control how Objective-C will be generated.
  final ObjcOptions? options;

  /// Creates a [PigeonObjcConfig] from the provided config.
  ///
  /// If config is null, return default if `macos` directory exists.
  ///
  /// If the config is a boolean and true, return the default.
  static PigeonObjcConfig? fromConfig(dynamic config) {
    final objc = PigeonObjcConfig(
      headerOut: PigeonOutput('macos/Runner/Pigeons', extension: 'h'),
      sourceOut: PigeonOutput('macos/Runner/Pigeons', extension: 'm'),
      options: ObjcOptions(prefix: 'Pigeon'),
    );

    if (config == null) {
      final macosDir = Directory('macos');
      return macosDir.existsSync() ? objc : null;
    }

    if (config is bool) return config ? objc : null;

    final options = config['options'];

    return PigeonObjcConfig(
      headerOut: PigeonOutput.fromConfig(
        config['header_out'] as String?,
        extension: objc.headerOut!.extension,
      ),
      sourceOut: PigeonOutput.fromConfig(
        config['source_out'] as String?,
        extension: objc.sourceOut!.extension,
      ),
      options: ObjcOptions(
        prefix: options?['prefix'] as String? ?? 'Pigeon',
        copyrightHeader: options?['copyright_header'] as Iterable<String>?,
      ),
    );
  }
}

/// Configuration for AST (Abstract Syntax Tree) generation.
class PigeonAstConfig {
  PigeonAstConfig({this.out});

  /// The output details for the generated AST code.
  final PigeonOutput? out;

  /// Creates a [PigeonAstConfig] from the provided config.
  ///
  /// If the config is a boolean and true, return the default.
  static PigeonAstConfig? fromConfig(dynamic config) {
    if (config == null) return null;

    final ast = PigeonAstConfig(
      out: PigeonOutput('output/pigeons', extension: 'ast'),
    );

    if (config is bool) return config ? ast : null;

    return PigeonAstConfig(
      out: PigeonOutput.fromConfig(
        config['out'] as String?,
        extension: ast.out!.extension,
      ),
    );
  }
}

/// The output details for a file generated by Pigeon.
class PigeonOutput {
  PigeonOutput(
    String path, {
    required this.extension,
    this.pascalCase = false,
    this.append,
  }) : path = normalize(path.trim());

  /// The folder path to the output file.
  final String path;

  /// The extension of the output file.
  final String extension;

  /// Whether to convert the output file name to PascalCase.
  final bool pascalCase;

  /// The string to append to the output file name.
  final String? append;

  /// Creates a [PigeonOutput] from the provided details.
  static PigeonOutput? fromConfig(
    String? path, {
    required String extension,
    bool pascalCase = false,
    String? append,
  }) {
    // If path is not given, return null.
    if (path == null) return null;

    return PigeonOutput(
      path,
      extension: extension,
      pascalCase: pascalCase,
      append: append,
    );
  }
}
