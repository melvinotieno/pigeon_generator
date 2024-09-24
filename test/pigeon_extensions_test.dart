import 'package:pigeon/pigeon.dart';
import 'package:pigeon_generator/src/pigeon_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('PigeonOptionsExtension Tests', () {
    test('getOutputs returns correct list of outputs', () {
      final options = PigeonOptions(
        dartOut: 'lib',
        dartTestOut: 'test',
        cppHeaderOut: 'cpp_header',
        cppSourceOut: 'cpp_source',
        gobjectHeaderOut: 'gobject_header',
        gobjectSourceOut: 'gobject_source',
        kotlinOut: 'kotlin',
        javaOut: 'java',
        swiftOut: 'swift',
        objcHeaderOut: 'objc_header',
        objcSourceOut: 'objc_source',
        astOut: 'ast',
      );

      final outputs = options.getOutputs();
      expect(outputs, [
        'lib',
        'test',
        'cpp_header',
        'cpp_source',
        'gobject_header',
        'gobject_source',
        'kotlin',
        'java',
        'swift',
        'objc_header',
        'objc_source',
        'ast',
      ]);
    });

    test('getOutputs returns empty list when no outputs are set', () {
      final options = PigeonOptions();
      final outputs = options.getOutputs();
      expect(outputs, isEmpty);
    });
  });
}
