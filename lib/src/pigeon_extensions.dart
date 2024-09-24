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
