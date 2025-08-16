import 'pigeon_config.dart';

/// Validator for the pigeon configuration.
class PigeonValidator {
  PigeonValidator._();

  /// Validate the pigeon configuration.
  static void validate(PigeonConfig config) {}
}

/// Exception thrown when the pigeon configuration is invalid.
class ValidatorException implements Exception {
  ValidatorException(this.field, this.message);

  /// The field that is invalid.
  final String field;

  /// The message to display.
  final String message;

  @override
  String toString() => 'Invalid field ($field): $message';
}
