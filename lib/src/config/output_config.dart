import 'package:path/path.dart' show normalize;

class OutputConfig {
  OutputConfig._internal(
    String path, {
    required this.extension,
    this.pascalCase = false,
    this.append,
  }) : path = normalize(path.trim());

  // The path to the output directory.
  final String path;

  // The extension of the generated file.
  final String extension;

  // Whether to use PascalCase for the generated file's name.
  final bool pascalCase;

  // The string to append to the generated file's name.
  final String? append;

  /// Creates an [OutputConfig] from the given options.
  ///
  /// Returns null if [path] is not given.
  static OutputConfig? fromOptions(
    String? path, {
    required String extension,
    bool pascalCase = false,
    String? append,
  }) {
    if (path == null) return null; // If path is not given, return null.

    return OutputConfig._internal(
      path,
      extension: extension,
      pascalCase: pascalCase,
      append: append,
    );
  }
}
