import 'package:pigeon/pigeon.dart';

extension PigeonOptionsExtension on PigeonOptions {
  /// Merges input options from a Pigeon file into the current [PigeonOptions].
  ///
  /// Parameters:
  /// - [input]: The path to the Pigeon input file to parse for options
  ///
  /// Returns:
  /// - A new [PigeonOptions] instance with merged options from input file
  /// - Current [PigeonOptions] if no options were found in the input file
  ///
  /// Throws:
  /// - [Exception]: If there are parsing errors in the input file
  ///
  /// Example:
  /// ```dart
  /// final options = PigeonOptions(dartOut: 'lib/api.dart');
  /// final mergedOptions = options.mergeInputOptions('pigeon/messages.dart');
  /// ```
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
  /// The following output types are checked:
  /// - Dart output ([dartOut])
  /// - Dart test output ([dartTestOut])
  /// - C++ header and source ([cppHeaderOut], [cppSourceOut])
  /// - GObject header and source ([gobjectHeaderOut], [gobjectSourceOut])
  /// - Kotlin output ([kotlinOut])
  /// - Java output ([javaOut])
  /// - Swift output ([swiftOut])
  /// - Objective-C header and source ([objcHeaderOut], [objcSourceOut])
  /// - AST output ([astOut])
  ///
  /// Returns:
  /// - A [List<String>] containing all non-null output file paths
  ///
  /// Example:
  /// ```dart
  /// final options = PigeonOptions(
  ///   dartOut: 'lib/api.dart',
  /// );
  /// final outputs = options.getOutputs(); // ['lib/api.dart']
  /// ```
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
  ///
  /// Parameters:
  /// - [platforms]: A list of platform names to skip. Valid platform names are:
  ///   - `'dart'`: Removes Dart output and options
  ///   - `'dart_test'`: Removes Dart test output
  ///   - `'java'`: Removes Java output and options
  ///   - `'kotlin'`: Removes Kotlin output and options
  ///   - `'swift'`: Removes Swift output and options
  ///   - `'objc'`: Removes Objective-C header/source output and options
  ///   - `'cpp'`: Removes C++ header/source output and options
  ///   - `'gobject'`: Removes GObject header/source output and options
  ///   - `'ast'`: Removes AST output
  ///
  /// Returns:
  /// - A new [PigeonOptions] instance with the specified platforms removed.
  ///
  /// Example:
  /// ```dart
  /// final options = PigeonOptions(
  ///   dartOut: 'lib/api.dart',
  ///   javaOut: 'android/Api.java',
  /// );
  ///
  /// // Skip Java generation, keeping only Dart
  /// final dartOnlyOptions = options.skipOutputs(['java']);
  /// ```
  PigeonOptions skipOutputs(List<String> platforms) {
    final optionsMap = toMap();

    for (final platform in platforms) {
      switch (platform) {
        case 'dart':
          optionsMap.remove('dartOut');
          optionsMap.remove('dartOptions');
          break;
        case 'dart_test':
          optionsMap.remove('dartTestOut');
          break;
        case 'java':
          optionsMap.remove('javaOut');
          optionsMap.remove('javaOptions');
          break;
        case 'kotlin':
          optionsMap.remove('kotlinOut');
          optionsMap.remove('kotlinOptions');
          break;
        case 'swift':
          optionsMap.remove('swiftOut');
          optionsMap.remove('swiftOptions');
          break;
        case 'objc':
          optionsMap.remove('objcHeaderOut');
          optionsMap.remove('objcSourceOut');
          optionsMap.remove('objcOptions');
          break;
        case 'cpp':
          optionsMap.remove('cppHeaderOut');
          optionsMap.remove('cppSourceOut');
          optionsMap.remove('cppOptions');
          break;
        case 'gobject':
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
