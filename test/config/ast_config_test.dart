import 'package:pigeon_generator/src/config/ast_config.dart';
import 'package:test/test.dart';

void main() {
  group('AstConfig', () {
    group('fromMap', () {
      test('should return empty config when map is false', () {
        final config = AstConfig.fromMap(false);

        expect(config.out, isNull);
      });

      test('should return empty config when map is null', () {
        final config = AstConfig.fromMap(null);

        expect(config.out, isNull);
      });

      test('should return default config when map is true', () {
        final config = AstConfig.fromMap(true);

        expect(config.out, isNotNull);
      });

      test('should create config with provided values', () {
        final config = AstConfig.fromMap({'out': 'custom/ast'});

        expect(config.out, isNotNull);
        expect(config.out!.path, 'custom/ast');
        expect(config.out!.extension, 'ast');
      });
    });
  });
}
