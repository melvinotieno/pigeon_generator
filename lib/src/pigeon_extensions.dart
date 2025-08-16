import 'package:pigeon/pigeon.dart';

extension PigeonOptionsExtension on PigeonOptions {
  /// Merges input options from a Pigeon file into the current [PigeonOptions].
  ///
  /// This overrides the current options with those from the input file.
  PigeonOptions mergeInputOptions(String input) {
    final pigeon = Pigeon.setup();
    final results = pigeon.parseFile(input);

    if (results.errors.isNotEmpty) {
      throw Exception('Errors found in input: ${results.errors}');
    }

    return results.pigeonOptions != null
        ? merge(PigeonOptions.fromMap(results.pigeonOptions!))
        : this;
  }

  /// Gets the list of output file paths based on the current [PigeonOptions].
  ///
  /// This method collects all the output file paths specified in the
  /// [PigeonOptions] for various languages and configurations.
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

  /// Skips the specified output platforms to prevent code generation for them.
  PigeonOptions skipOutputs(List<String> platforms) {
    final optionsMap = toMap();

    for (final platform in platforms) {
      switch (platform) {
        case 'dart':
          optionsMap.remove('dart');
          optionsMap.remove('dartTestOut');
          optionsMap.remove('dartOptions');
          optionsMap.remove('dartPackageName');
          break;
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
        case 'ast':
          optionsMap.remove('astOut');
          break;
      }
    }

    return PigeonOptions.fromMap(optionsMap);
  }
}
