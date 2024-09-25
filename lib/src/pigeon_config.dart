import 'dart:io';

import 'package:build/build.dart';
import 'package:path/path.dart' as path;

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
    this.copyrightHeader,
    this.oneLanguage,
    this.ast,
    this.debugGenerators,
    this.basePath,
    String? outTemplate,
  }) : _outTemplate = outTemplate ?? 'name.g.extension';

  /// The input directory for the Pigeon files.
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

  /// The path to the copyright header file.
  final String? copyrightHeader;

  /// Whether to generate code for only one language.
  final bool? oneLanguage;

  /// Configuration for AST (Abstract Syntax Tree) generation.
  final PigeonAstConfig? ast;

  /// Whether to enable debug generators.
  final bool? debugGenerators;

  /// The base path for the generated code.
  final String? basePath;

  /// The template for naming the generated files.
  String? _outTemplate;

  /// Returns the output template.
  String get outTemplate => _outTemplate ?? 'name.g.extension';

  /// Creates a [PigeonConfig] instance from the given [BuilderOptions].
  factory PigeonConfig.fromBuilderOptions(BuilderOptions options) {
    final config = options.config;

    final inputs = _normalizePath(config['inputs'] as String?) ?? 'pigeons';
    final oneLanguage = config['one_language'] as bool?;

    var copyrightHeader = config['copyright_header'] as String?;
    if (copyrightHeader == null) {
      // If copyright.txt file exists in inputs, set as copyright header.
      final copyrightPath = path.join(inputs, 'copyright.txt');
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
      copyrightHeader: copyrightHeader,
      oneLanguage: oneLanguage,
      ast: PigeonAstConfig.fromConfig(config['ast']),
      debugGenerators: config['debug_generators'] as bool?,
      basePath: config['base_path'] as String?,
      outTemplate: config['out_template'] as String?,
    );
  }
}

/// Configuration for Dart code generation.
class PigeonDartConfig {
  PigeonDartConfig({this.out, this.testOut, this.packageName});

  /// The output directory for the generated Dart code.
  final String? out;

  /// The output directory for the generated Dart test code.
  final String? testOut;

  /// The package name for the generated Dart code.
  final String? packageName;

  /// Creates a [PigeonDartConfig] from a configuration map.
  ///
  /// If the configuration is null and [oneLanguage] is true, it returns null.
  ///
  /// Otherwise, it normalizes the 'out' and 'test_out' paths from the
  /// configuration map and sets the 'package_name'.
  static PigeonDartConfig? fromConfig(dynamic config, bool? oneLanguage) {
    if (config == null && oneLanguage == true) return null;

    return PigeonDartConfig(
      out: _normalizePath(_getOut(config?['out'] as String?, oneLanguage)),
      testOut: _normalizePath(_getTestOut(config?['test_out'])),
      packageName: config?['package_name'] as String?,
    );
  }

  /// Gets the output directory for the generated Dart code.
  ///
  /// If the 'out' path is null, it returns 'lib/pigeons' if [oneLanguage] is
  /// not true as required by pigeon.
  static String? _getOut(String? out, bool? oneLanguage) {
    return out ?? (oneLanguage != true ? 'lib/pigeons' : null);
  }

  /// Gets the output directory for the generated Dart test code.
  ///
  /// If the 'test_out' path is null, it returns null.
  ///
  /// If the 'test_out' is a boolean, it returns 'test/pigeons' if true,
  /// otherwise null.
  static String? _getTestOut(dynamic testOut) {
    if (testOut == null) return null;
    if (testOut is bool) return testOut ? 'test/pigeons' : null;
    return testOut as String?;
  }
}

/// Configuration for C++ code generation.
class PigeonCppConfig {
  PigeonCppConfig({this.headerOut, this.sourceOut, this.namespace});

  /// The output directory for the generated C++ header files.
  final String? headerOut;

  /// The output directory for the generated C++ source files.
  final String? sourceOut;

  /// The namespace for the generated C++ code.
  final String? namespace;

  /// Creates a [PigeonCppConfig] from a configuration map.
  ///
  /// If the configuration is null, it checks if the 'windows' directory exists
  /// and returns the default configuration if it does.
  ///
  /// If the configuration is a boolean, it returns the default configuration
  /// if the boolean is true.
  ///
  /// Otherwise, it normalizes the 'header_out' and 'source_out' paths from the
  /// configuration map and sets the 'namespace'.
  static PigeonCppConfig? fromConfig(dynamic config) {
    if (config == null) {
      final forWindows = Directory('windows').existsSync();
      return forWindows ? _default : null;
    }

    if (config is bool) return config ? _default : null;

    return PigeonCppConfig(
      headerOut: _normalizePath(config['header_out'] as String?),
      sourceOut: _normalizePath(config['source_out'] as String?),
      namespace: config['namespace'] as String?,
    );
  }

  /// The default configuration for C++ code generation.
  static PigeonCppConfig get _default {
    return PigeonCppConfig(
      headerOut: 'windows/runner/pigeons',
      sourceOut: 'windows/runner/pigeons',
    );
  }
}

/// Configuration for GObject code generation.
class PigeonGobjectConfig {
  PigeonGobjectConfig({this.headerOut, this.sourceOut, this.module});

  /// The output directory for the generated GObject header files.
  final String? headerOut;

  /// The output directory for the generated GObject source files.
  final String? sourceOut;

  /// The module name for the generated GObject code.
  final String? module;

  /// Creates a [PigeonGobjectConfig] from a configuration map.
  ///
  /// If the configuration is null, it checks if the 'linux' directory exists
  /// and returns the default configuration if it does.
  ///
  /// If the configuration is a boolean, it returns the default configuration
  /// if the boolean is true.
  ///
  /// Otherwise, it normalizes the 'header_out' and 'source_out' paths from the
  /// configuration map and sets the 'module'.
  static PigeonGobjectConfig? fromConfig(dynamic config) {
    if (config == null) {
      final forLinux = Directory('linux').existsSync();
      return forLinux ? _default : null;
    }

    if (config is bool) return config ? _default : null;

    return PigeonGobjectConfig(
      headerOut: _normalizePath(config['header_out'] as String?),
      sourceOut: _normalizePath(config['source_out'] as String?),
      module: config['module'] as String?,
    );
  }

  /// The default configuration for GObject code generation.
  static PigeonGobjectConfig get _default {
    return PigeonGobjectConfig(
      headerOut: 'linux/pigeons',
      sourceOut: 'linux/pigeons',
    );
  }
}

/// Configuration for Kotlin code generation.
class PigeonKotlinConfig {
  PigeonKotlinConfig({this.out, this.package});

  /// The output directory for the generated Kotlin code.
  final String? out;

  /// The package name for the generated Kotlin code.
  final String? package;

  /// Creates a [PigeonKotlinConfig] from a configuration map.
  ///
  /// If the configuration is null, it checks if the 'android' directory exists
  /// and returns the default configuration if it does.
  ///
  /// If the configuration is a boolean, it returns the default configuration
  /// if the boolean is true.
  ///
  /// Otherwise, it normalizes the 'out' path from the configuration map and
  /// sets the 'package'.
  static PigeonKotlinConfig? fromConfig(dynamic config) {
    final applicationId = _getAndroidApplicationId();

    if (config == null) {
      final forAndroid = Directory('android').existsSync();
      return forAndroid ? _getDefault(applicationId) : null;
    }

    if (config is bool) return config ? _getDefault(applicationId) : null;

    return PigeonKotlinConfig(
      out: _normalizePath(config['out'] as String?),
      package: config['package'] as String?,
    );
  }

  /// Gets the default [PigeonKotlinConfig] based on the Android application ID.
  static PigeonKotlinConfig? _getDefault(String? applicationId) {
    if (applicationId == null) return null;

    return PigeonKotlinConfig(
      out: _getAndroidOut('kotlin', applicationId),
      package: _getAndroidPackage(applicationId),
    );
  }
}

/// Configuration for Java code generation.
class PigeonJavaConfig {
  PigeonJavaConfig({this.out, this.package, this.useGeneratedAnnotation});

  /// The output directory for the generated Java code.
  final String? out;

  /// The package name for the generated Java code.
  final String? package;

  /// Whether to use the generated annotation for the generated Java code.
  final bool? useGeneratedAnnotation;

  /// Creates a [PigeonJavaConfig] from a configuration map.
  ///
  /// Returns null if the configuration is null.
  ///
  /// If the configuration is a boolean, it returns the default configuration
  /// if the boolean is true.
  ///
  /// Otherwise, it normalizes the 'out' path from the configuration map and
  /// sets the 'package' and 'useGeneratedAnnotation'.
  static PigeonJavaConfig? fromConfig(dynamic config) {
    if (config == null) return null;

    if (config is bool) {
      return config ? _getDefault(_getAndroidApplicationId()) : null;
    }

    return PigeonJavaConfig(
      out: _normalizePath(config['out'] as String?),
      package: config['package'] as String?,
      useGeneratedAnnotation: config['use_generated_annotation'] as bool?,
    );
  }

  /// Gets the default [PigeonJavaConfig] based on the Android application ID.
  static PigeonJavaConfig? _getDefault(String? applicationId) {
    if (applicationId == null) return null;

    return PigeonJavaConfig(
      out: _getAndroidOut('java', applicationId),
      package: _getAndroidPackage(applicationId),
    );
  }
}

/// Configuration for Swift code generation.
class PigeonSwiftConfig {
  PigeonSwiftConfig({this.out});

  /// The output directory for the generated Swift code.
  final String? out;

  /// Creates a [PigeonSwiftConfig] from a configuration map.
  ///
  /// If the configuration is null, it checks if the 'ios' directory exists
  /// and returns the default configuration if it does.
  ///
  /// If the configuration is a boolean, it returns the default configuration
  /// if the boolean is true.
  ///
  /// Otherwise, it normalizes the 'out' path from the configuration map.
  static PigeonSwiftConfig? fromConfig(dynamic config) {
    if (config == null) {
      final forIOS = Directory('ios').existsSync();
      return forIOS ? _default : null;
    }

    if (config is bool) return config ? _default : null;

    return PigeonSwiftConfig(out: _normalizePath(config['out'] as String?));
  }

  /// The default configuration for Swift code generation.
  static PigeonSwiftConfig get _default {
    return PigeonSwiftConfig(out: 'ios/Runner/Pigeons');
  }
}

/// Configuration for Objective-C code generation.
class PigeonObjcConfig {
  PigeonObjcConfig({this.headerOut, this.sourceOut, this.prefix});

  /// The output directory for the generated Objective-C header files.
  final String? headerOut;

  /// The output directory for the generated Objective-C source files.
  final String? sourceOut;

  /// The prefix for the generated Objective-C classes.
  final String? prefix;

  /// Creates a [PigeonObjcConfig] from a configuration map.
  ///
  /// If the configuration is null, it checks if the 'macos' directory exists
  /// and returns the default configuration if it does.
  ///
  /// If the configuration is a boolean, it returns the default configuration
  /// if the boolean is true.
  ///
  /// Otherwise, it normalizes the 'header_out' and 'source_out' paths from the
  /// configuration map and sets the 'prefix'.
  static PigeonObjcConfig? fromConfig(dynamic config) {
    if (config == null) {
      final forMacOS = Directory('macos').existsSync();
      return forMacOS ? _default : null;
    }

    if (config is bool) return config ? _default : null;

    return PigeonObjcConfig(
      headerOut: _normalizePath(config['header_out'] as String?),
      sourceOut: _normalizePath(config['source_out'] as String?),
      prefix: config['prefix'] as String?,
    );
  }

  /// The default configuration for Objective-C code generation.
  static PigeonObjcConfig get _default {
    return PigeonObjcConfig(
      headerOut: 'macos/Runner/Pigeons',
      sourceOut: 'macos/Runner/Pigeons',
    );
  }
}

/// Configuration for AST (Abstract Syntax Tree) generation.
class PigeonAstConfig {
  PigeonAstConfig({this.out});

  /// The output directory for the generated AST files.
  final String? out;

  /// Creates a [PigeonAstConfig] from a configuration map.
  ///
  /// If the configuration is null, it returns null.
  ///
  /// If the configuration is a boolean, it returns the default configuration
  /// if the boolean is true.
  ///
  /// Otherwise, it normalizes the 'out' path from the configuration map.
  static PigeonAstConfig? fromConfig(dynamic config) {
    if (config == null) return null;

    if (config is bool) return config ? _default : null;

    return PigeonAstConfig(out: _normalizePath(config['out'] as String?));
  }

  /// The default configuration for AST generation.
  static PigeonAstConfig get _default {
    return PigeonAstConfig(out: 'output/pigeons');
  }
}

/// Normalize the given path string.
///
/// This function takes an optional path string, trims any leading or trailing
/// spaces, and normalizes the path.
///
/// @param pathStr The path string to be normalized.
///
/// @return The normalized path string, or null if the pathStr is null.
String? _normalizePath(String? pathStr) {
  return pathStr != null ? path.normalize(pathStr.trim()) : null;
}

/// Retrieves the Android application ID from the `android/app/build.gradle`
/// file if it exists.
///
/// @return The Android application ID, or null if the file does not exist or
/// the application ID is not found.
String? _getAndroidApplicationId() {
  final gradleFile = File('android/app/build.gradle');

  if (gradleFile.existsSync()) {
    final content = gradleFile.readAsStringSync();
    final regex = RegExp(r'applicationId\s*=\s*"([^"]+)"');
    final match = regex.firstMatch(content);

    if (match != null) {
      return match.group(1)!;
    }
  }

  log.warning(
    'Failed to get Android application ID from android/app/build.gradle',
  );

  return null;
}

/// Generates the output directory for the given language and application ID.
///
/// @param language The language of the generated code.
///
/// @param applicationId The Android application ID.
///
/// @return The output directory for the generated code.
String _getAndroidOut(String language, String applicationId) {
  return 'android/app/src/main/$language/${applicationId.replaceAll('.', '/')}/pigeons';
}

/// Generates the package name for the given application ID.
///
/// @param applicationId The Android application ID.
///
/// @return The package name for the generated code.
String _getAndroidPackage(String applicationId) => '$applicationId.pigeons';
