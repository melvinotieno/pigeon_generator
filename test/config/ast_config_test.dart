import 'package:pigeon_generator/src/config/ast_config.dart';
import 'package:test/test.dart';

void main() {
  group('AstConfig', () {
    group('fromMap', () {
      test('should return null values when disabled', () {
        // Tests for null value
        AstConfig config = AstConfig.fromMap(null);

        expect(config.out, isNull);

        // Tests for false value
        config = AstConfig.fromMap(false);

        expect(config.out, isNull);
      });

      test('should return config with provided values', () {
        final map = {'out': 'path/to/ast'};

        // Tests without base folder path
        AstConfig config = AstConfig.fromMap(map);

        expect(config.out?.path, equals('path/to/ast'));
        expect(config.out?.extension, equals('ast'));
        expect(config.out?.pascalCase, isFalse);
        expect(config.out?.append, isNull);

        // Tests with base folder path
        config = AstConfig.fromMap(map, 'my_project');

        expect(config.out?.path, equals('path/to/ast'));
        expect(config.out?.extension, equals('ast'));
        expect(config.out?.pascalCase, isFalse);
        expect(config.out?.append, isNull);
      });

      test('should return default values for any other type', () {
        // Tests without base folder path
        AstConfig config = AstConfig.fromMap(true);

        expect(config.out?.path, equals('ast'));
        expect(config.out?.extension, equals('ast'));
        expect(config.out?.pascalCase, isFalse);
        expect(config.out?.append, isNull);

        // Tests with base folder path
        config = AstConfig.fromMap(true, 'my_project');

        expect(config.out?.path, equals('ast/my_project'));
        expect(config.out?.extension, equals('ast'));
        expect(config.out?.pascalCase, isFalse);
        expect(config.out?.append, isNull);
      });
    });
  });
}
