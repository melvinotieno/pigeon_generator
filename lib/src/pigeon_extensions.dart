import 'dart:io';

import 'package:checked_yaml/checked_yaml.dart';
import 'package:path/path.dart' as path;
import 'package:pigeon/pigeon.dart';

import 'pigeon_config.dart';
import 'pigeon_validator.dart';

extension PigeonExtension on Pigeon {
  /// Load the pigeon configuration from the `pigeon.yml` or `pigeon.yaml` file.
  ///
  /// If neither of the files exist, a default configuration is provided.
  static PigeonConfig loadConfig(
    Map<String, bool?> platformOutputs, {
    bool? ast,
    bool? dartTest,
    bool? debugGenerators,
  }) {
    final ymlFile = File('pigeon.yml');
    final yamlFile = File('pigeon.yaml');

    bool ymlExists = ymlFile.existsSync();
    bool yamlExists = yamlFile.existsSync();

    if (ymlExists && yamlExists) {
      throw FileSystemException(
        'Both pigeon.yml and pigeon.yaml exist. Please remove one of them.',
        ymlFile.parent.path,
      );
    }

    final file = ymlExists ? ymlFile : (yamlExists ? yamlFile : null);

    PigeonConfig pigeonConfig;
    if (file != null) {
      pigeonConfig = checkedYamlDecode<PigeonConfig>(
        file.readAsStringSync(),
        (map) => PigeonConfig.fromMap(Map.from(map!)),
        sourceUrl: file.uri,
      );

      PigeonValidator.validate(pigeonConfig);
    } else {
      final cpp = platformOutputs['cpp'];
      final gobject = platformOutputs['gobject'];
      final kotlin = platformOutputs['kotlin'];
      final java = platformOutputs['java'];
      final swift = platformOutputs['swift'];
      final objc = platformOutputs['objc'];

      pigeonConfig = PigeonConfig(
        dart: PigeonDartConfig.defaults(dartTest),
        cpp: cpp == true ? PigeonCppConfig.defaults() : null,
        gobject: gobject == true ? PigeonGobjectConfig.defaults() : null,
        kotlin: kotlin == true ? PigeonKotlinConfig.defaults() : null,
        java: java == true ? PigeonJavaConfig.defaults() : null,
        swift: swift == true ? PigeonSwiftConfig.defaults() : null,
        objc: objc == true ? PigeonObjcConfig.defaults() : null,
        ast: ast == true ? PigeonAstConfig(out: 'output') : null,
        debugGenerators: debugGenerators,
      );
    }

    if (pigeonConfig.copyrightHeader == null) {
      pigeonConfig.setCopyrightHeader(
        path.join(pigeonConfig.inputs, 'copyright.txt'),
      );
    }

    return pigeonConfig;
  }
}

extension PigeonOptionsExtension on PigeonOptions {
  /// Get the list of outputs based on the pigeon options.
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
