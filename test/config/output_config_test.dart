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

  group('StringExtension', () {
    group('pascalCase', () {
      test('should convert snake_case and kebab-case to PascalCase', () {
        expect('hello_world'.pascalCase, equals('HelloWorld'));
        expect('hello-world'.pascalCase, equals('HelloWorld'));
        expect('my_variable_name'.pascalCase, equals('MyVariableName'));
        expect('my-variable-name'.pascalCase, equals('MyVariableName'));
      });

      test('should convert single word to PascalCase', () {
        expect('hello'.pascalCase, equals('Hello'));
        expect('a'.pascalCase, equals('A'));
      });

      test('should remove leading and trailing underscores and hyphens', () {
        expect('_hello_world_'.pascalCase, equals('HelloWorld'));
        expect('-hello-world-'.pascalCase, equals('HelloWorld'));
        expect('_-hello_world-_'.pascalCase, equals('HelloWorld'));
        expect('___'.pascalCase, equals(''));
        expect('---'.pascalCase, equals(''));
      });

      test('should handle mixed separators', () {
        expect('hello_world-test'.pascalCase, equals('HelloWorldTest'));
        expect('my-var_name'.pascalCase, equals('MyVarName'));
      });

      test('should handle edge cases', () {
        expect(''.pascalCase, equals(''));
        expect('HelloWorld'.pascalCase, equals('HelloWorld'));
        expect('helloWorld'.pascalCase, equals('HelloWorld'));
        expect('123'.pascalCase, equals('123'));
      });
    });

    group('let', () {
      test('should apply basic transformations', () {
        expect('hello'.let((s) => s.toUpperCase()), equals('HELLO'));
        expect('test'.let((s) => '$s!'), equals('test!'));
        expect('hello_world'.let((s) => s.pascalCase), equals('HelloWorld'));
      });

      test('should handle chaining', () {
        final result = 'hello'
            .let((s) => s.toUpperCase())
            .let((s) => '${s}_WORLD')
            .let((s) => s.toLowerCase());

        expect(result, equals('hello_world'));
      });

      test('should handle empty string', () {
        expect(''.let((s) => s.isEmpty ? 'was empty' : s), equals('was empty'));
      });

      test('should handle null string', () {
        String? nullString;

        expect(
          () => nullString!.let((s) => s.toUpperCase()),
          throwsA(isA<TypeError>()),
        );

        nullString = null;
        final result = nullString?.let((s) => s.toUpperCase());
        expect(result, isNull);
      });
    });
  });
}
