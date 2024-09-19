import 'package:pigeon_generator/src/pigeon_config.dart';

class PigeonValidator {
  PigeonValidator._();

  static validate(PigeonConfig config) {
    validateInputs(config.inputs);
  }

  static validateInputs(String inputs) {
    if (inputs.isEmpty) {
      throw ValidatorException('inputs', 'Inputs folder is required.');
    }
  }
}

class ValidatorException implements Exception {
  ValidatorException(this.field, this.message);

  final String field;
  final String message;

  @override
  String toString() => 'Invalid field ($field): $message';
}
