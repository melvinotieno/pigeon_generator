import 'package:yaml/yaml.dart';

/// Recursively converts a [Map] or [YamlMap] into a `Map<String, dynamic>`.
///
/// This ensures that nested [YamlMap] and [YamlList] objects are transformed
/// into Dart-native structures (`Map` and `List`) so they can be easily used.
///
/// Example:
/// ```yaml
/// users:
///   - name: Alice
///     age: 30
///   - name: Bob
///     age: 25
/// ```
///
/// After parsing and passing to [convertConfig], this will produce:
///
/// ```dart
/// {
///   "users": [
///     {"name": "Alice", "age": 30},
///     {"name": "Bob", "age": 25}
///   ]
/// }
/// ```
Map<String, dynamic> convertConfig(dynamic config) {
  if (config is! Map && config is! YamlMap) {
    throw ArgumentError('config must be a Map or YamlMap');
  }

  return Map<String, dynamic>.fromEntries(
    config.entries.map<MapEntry<String, dynamic>>((entry) {
      final key = entry.key.toString();
      final value = entry.value;

      if (value is YamlMap) {
        return MapEntry(key, convertConfig(value));
      }

      if (value is YamlList) {
        final list = value.toList();

        if (list.every((e) => e is String)) {
          return MapEntry(key, list.cast<String>());
        } else if (list.every((e) => e is YamlMap)) {
          return MapEntry(key, list.map((e) => convertConfig(e)).toList());
        } else {
          return MapEntry(
            key,
            list.map((e) => e is YamlMap ? convertConfig(e) : e).toList(),
          );
        }
      }

      return MapEntry(key, value);
    }),
  );
}
