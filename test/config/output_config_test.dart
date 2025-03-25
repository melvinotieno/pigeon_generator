import 'package:pigeon_generator/src/config/output_config.dart';
import 'package:test/test.dart';

void main() {
  group('OutputConfig', () {
    test('fromOptions should return null if path is null', () {
      final config = OutputConfig.fromOptions(null, extension: 'dart');

      expect(config, isNull);
    });

    test('fromOptions should return OutputConfig with correct values', () {
      final config = OutputConfig.fromOptions(
        'path/to/output',
        extension: 'dart',
        pascalCase: true,
        append: '_generated',
      );

      expect(config, isNotNull);
      expect(config?.path, 'path/to/output');
      expect(config?.extension, 'dart');
      expect(config?.pascalCase, isTrue);
      expect(config?.append, '_generated');
    });

    test('fromOptions should use default values for optional parameters', () {
      final config = OutputConfig.fromOptions(
        'path/to/output',
        extension: 'dart',
      );

      expect(config, isNotNull);
      expect(config?.path, 'path/to/output');
      expect(config?.extension, 'dart');
      expect(config?.pascalCase, isFalse); // Default value
      expect(config?.append, isNull); // Default value
    });

    test('path should be normalized and trimmed', () {
      final config = OutputConfig.fromOptions(
        '  path/to/output/  ',
        extension: 'dart',
      );

      expect(config, isNotNull);
      expect(config?.path, 'path/to/output');
    });
  });
}
