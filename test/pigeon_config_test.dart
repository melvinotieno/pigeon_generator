import 'package:pigeon_generator/src/pigeon_config.dart';
import 'package:test/test.dart';

void main() {
  group('PigeonOutput', () {
    test('should return null if config map is null', () {
      final output = PigeonOutput.fromConfig(null, extension: 'dart');

      expect(output, isNull);
    });

    test('should create PigeonOutput from config map', () {
      final config = <String, dynamic>{'out': 'path/to/output'};

      final output = PigeonOutput.fromConfig(
        config['out'] as String?,
        extension: 'dart',
      );

      expect(output?.path, isNotNull);
      expect(output?.path, config['out']);
      expect(output?.extension, 'dart');
      expect(output?.pascalCase, isFalse);
      expect(output?.append, isNull);
    });
  });

  group('PigeonAstConfig', () {
    test('should return null if config is null', () {
      final config = PigeonAstConfig.fromConfig(null);

      expect(config, isNull);
    });

    test('should return default config if config is true', () {
      final config = PigeonAstConfig.fromConfig(true);

      expect(config?.out?.path, isNotNull);
      expect(config?.out?.path, 'output/pigeons');
      expect(config?.out?.extension, isNotNull);
      expect(config?.out?.extension, 'ast');
    });

    test('should create PigeonAstConfig from config map', () {
      final config = <String, dynamic>{'out': 'path/to/output'};

      final output = PigeonAstConfig.fromConfig(config);

      expect(output?.out?.path, isNotNull);
      expect(output?.out?.path, config['out']);
      expect(output?.out?.extension, isNotNull);
      expect(output?.out?.extension, 'ast');
    });
  });

  group('PigeonObjcConfig', () {
    test('should return null if config is null', () {
      final config = PigeonObjcConfig.fromConfig(null);

      expect(config, isNull);
    });

    test('should return default config if config is true', () {
      final config = PigeonObjcConfig.fromConfig(true);

      expect(config?.headerOut?.path, isNotNull);
      expect(config?.headerOut?.path, 'macos/Runner/Pigeons');
      expect(config?.headerOut?.extension, isNotNull);
      expect(config?.headerOut?.extension, 'h');
      expect(config?.sourceOut?.path, isNotNull);
      expect(config?.sourceOut?.path, 'macos/Runner/Pigeons');
      expect(config?.sourceOut?.extension, isNotNull);
      expect(config?.sourceOut?.extension, 'm');
    });

    test('should create PigeonObjcConfig from config map', () {
      final config = <String, dynamic>{
        'header_out': 'path/to/header',
        'source_out': 'path/to/source',
        'options': <String, dynamic>{
          'prefix': 'Prefix',
          'copyright_header': ['Copyright header'],
        }
      };

      final output = PigeonObjcConfig.fromConfig(config);

      expect(output?.headerOut?.path, isNotNull);
      expect(output?.headerOut?.path, config['header_out']);
      expect(output?.headerOut?.extension, isNotNull);
      expect(output?.headerOut?.extension, 'h');
      expect(output?.sourceOut?.path, isNotNull);
      expect(output?.sourceOut?.path, config['source_out']);
      expect(output?.sourceOut?.extension, isNotNull);
      expect(output?.sourceOut?.extension, 'm');
      expect(output?.options?.prefix, isNotNull);
      expect(output?.options?.prefix, config['options']!['prefix']);
    });

    test('should add header_out if not specified but source_out is', () {
      final config = <String, dynamic>{
        'source_out': 'path/to/source',
      };

      final output = PigeonObjcConfig.fromConfig(config);

      expect(output?.headerOut?.path, isNotNull);
      expect(output?.headerOut?.path, config['source_out']);
      expect(output?.headerOut?.extension, isNotNull);
      expect(output?.headerOut?.extension, 'h');
    });
  });
}
