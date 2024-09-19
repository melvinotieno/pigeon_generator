import 'dart:io';

class PigeonConfig {
  PigeonConfig({
    String? inputs,
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
  }) : _inputs = inputs ?? 'pigeons';

  String? _inputs;
  final PigeonDartConfig? dart;
  final PigeonCppConfig? cpp;
  final PigeonGobjectConfig? gobject;
  final PigeonKotlinConfig? kotlin;
  final PigeonJavaConfig? java;
  final PigeonSwiftConfig? swift;
  final PigeonObjcConfig? objc;
  final bool? oneLanguage;
  final PigeonAstConfig? ast;
  final bool? debugGenerators;
  final String? basePath;
  String? copyrightHeader;

  String get inputs => _inputs ?? 'pigeons';

  /// Set the path to the file that contains the copyright.
  ///
  /// If the file does not exist, this method does nothing.
  void setCopyrightHeader(String path) {
    if (File(path).existsSync()) {
      copyrightHeader = path;
    }
  }

  factory PigeonConfig.fromMap(Map map) {
    final dart = map['dart'];
    final cpp = map['cpp'];
    final gobject = map['gobject'];
    final kotlin = map['kotlin'];
    final java = map['java'];
    final swift = map['swift'];
    final objc = map['objc'];
    final ast = map['ast'];

    return PigeonConfig(
      inputs: map['inputs'] as String?,
      dart: dart != null ? PigeonDartConfig.fromMap(dart) : null,
      cpp: cpp != null ? PigeonCppConfig.fromMap(cpp) : null,
      gobject: gobject != null ? PigeonGobjectConfig.fromMap(gobject) : null,
      kotlin: kotlin != null ? PigeonKotlinConfig.fromMap(kotlin) : null,
      java: java != null ? PigeonJavaConfig.fromMap(java) : null,
      swift: swift != null ? PigeonSwiftConfig.fromMap(swift) : null,
      objc: objc != null ? PigeonObjcConfig.fromMap(objc) : null,
      copyrightHeader: map['copyright_header'] as String?,
      oneLanguage: map['one_language'] as bool?,
      ast: ast != null ? PigeonAstConfig.fromMap(ast) : null,
      debugGenerators: map['debug_generators'] as bool?,
      basePath: map['base_path'] as String?,
    );
  }
}

class PigeonDartConfig {
  PigeonDartConfig({this.out, this.testOut, this.packageName});

  final String? out;
  final String? testOut;
  final String? packageName;

  factory PigeonDartConfig.fromMap(Map map) {
    return PigeonDartConfig(
      out: map['out'] as String?,
      testOut: map['test_out'] as String?,
      packageName: map['package_name'] as String?,
    );
  }

  factory PigeonDartConfig.defaults(bool? dartTest) {
    return PigeonDartConfig(
      out: 'lib',
      testOut: dartTest == true ? 'test' : null,
    );
  }
}

class PigeonCppConfig {
  PigeonCppConfig({this.headerOut, this.sourceOut, this.namespace});

  final String? headerOut;
  final String? sourceOut;
  final String? namespace;

  factory PigeonCppConfig.fromMap(Map map) {
    return PigeonCppConfig(
      headerOut: map['header_out'] as String?,
      sourceOut: map['source_out'] as String?,
      namespace: map['namespace'] as String?,
    );
  }

  factory PigeonCppConfig.defaults() {
    return PigeonCppConfig(
      headerOut: 'windows/runner',
      sourceOut: 'windows/runner',
    );
  }
}

class PigeonGobjectConfig {
  PigeonGobjectConfig({this.headerOut, this.sourceOut, this.module});

  final String? headerOut;
  final String? sourceOut;
  final String? module;

  factory PigeonGobjectConfig.fromMap(Map map) {
    return PigeonGobjectConfig(
      headerOut: map['header_out'] as String?,
      sourceOut: map['source_out'] as String?,
      module: map['module'] as String?,
    );
  }

  factory PigeonGobjectConfig.defaults() {
    return PigeonGobjectConfig(
      headerOut: 'linux',
      sourceOut: 'linux',
    );
  }
}

class PigeonKotlinConfig {
  PigeonKotlinConfig({this.out, this.package});

  final String? out;
  final String? package;

  factory PigeonKotlinConfig.fromMap(Map map) {
    return PigeonKotlinConfig(
      out: map['out'] as String?,
      package: map['package'] as String?,
    );
  }

  factory PigeonKotlinConfig.defaults() {
    return PigeonKotlinConfig(out: 'src/main/kotlin');
  }
}

class PigeonJavaConfig {
  PigeonJavaConfig({this.out, this.package, this.useGeneratedAnnotation});

  final String? out;
  final String? package;
  final bool? useGeneratedAnnotation;

  factory PigeonJavaConfig.fromMap(Map map) {
    return PigeonJavaConfig(
      out: map['out'] as String?,
      package: map['package'] as String?,
      useGeneratedAnnotation: map['use_generated_annotation'] as bool?,
    );
  }

  factory PigeonJavaConfig.defaults() {
    return PigeonJavaConfig(out: 'src/main/java');
  }
}

class PigeonSwiftConfig {
  PigeonSwiftConfig({this.out});

  final String? out;

  factory PigeonSwiftConfig.fromMap(Map map) {
    return PigeonSwiftConfig(out: map['out'] as String?);
  }

  factory PigeonSwiftConfig.defaults() {
    return PigeonSwiftConfig(out: 'ios/Runner');
  }
}

class PigeonObjcConfig {
  PigeonObjcConfig({this.headerOut, this.sourceOut, this.prefix});

  final String? headerOut;
  final String? sourceOut;
  final String? prefix;

  factory PigeonObjcConfig.fromMap(Map map) {
    return PigeonObjcConfig(
      headerOut: map['header_out'] as String?,
      sourceOut: map['source_out'] as String?,
      prefix: map['prefix'] as String?,
    );
  }

  factory PigeonObjcConfig.defaults() {
    return PigeonObjcConfig(
      headerOut: 'macos/Runner',
      sourceOut: 'macos/Runner',
    );
  }
}

class PigeonAstConfig {
  PigeonAstConfig({this.out});

  final String? out;

  factory PigeonAstConfig.fromMap(Map map) {
    return PigeonAstConfig(out: map['out'] as String?);
  }

  factory PigeonAstConfig.defaults() {
    return PigeonAstConfig(out: 'output');
  }
}
