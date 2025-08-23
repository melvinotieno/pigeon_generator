import 'dart:io';

import 'package:pigeon_generator/src/pigeon_config.dart';
import 'package:test/test.dart';

void main() {
  group('PigeonConfig', () {
    late Directory tempDir;
    late String originalDir;

    setUpAll(() async {
      originalDir = Directory.current.path;
      tempDir = await Directory.systemTemp.createTemp('pigeon_config_test_');
      Directory.current = tempDir;
    });

    tearDownAll(() async {
      Directory.current = originalDir;

      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    group('fromMap', () {
      test('should create config with minimal map using defaults', () async {
        await Directory('pigeons').create();
        await File('pigeons/copyright.txt').writeAsString('Copyright © 2024');

        final config = PigeonConfig.fromMap({});

        expect(config.inputs, equals('pigeons'));
        expect(config.outTemplate, equals('name.g.extension'));
        expect(config.copyrightHeader, equals('pigeons/copyright.txt'));
        expect(config.debugGenerators, isNull);
        expect(config.basePath, isNull);
        expect(config.skipOutputs, isNull);
        expect(config.outFolder, isNull);
        expect(config.outTemplate, equals('name.g.extension'));
      });

      test('should create config from map configuration', () {
        final map = {
          'inputs': 'files',
          'copyright_header': 'files/copyright.txt',
          'debug_generators': true,
          'base_path': '/base',
          'out_folder': 'generated',
          'out_template': 'name.generated.extension',
        };

        final config = PigeonConfig.fromMap(map);

        expect(config.inputs, equals('files'));
        expect(config.copyrightHeader, equals('files/copyright.txt'));
        expect(config.debugGenerators, isTrue);
        expect(config.basePath, equals('/base'));
        expect(config.outFolder, equals('generated'));
        expect(config.outTemplate, equals('name.generated.extension'));
      });
    });

    group('getPigeonOptions', () {
      test('should return proper output paths', () async {
        final content = '''
          import 'package:pigeon/pigeon.dart';

          @HostApi()
          abstract class ApiFile {
            @async
            void sendMessage(String message);
          }
        ''';

        await Directory('pigeons').create();
        await File('pigeons/api_file.dart').writeAsString(content);

        final map = {
          'dart': {'test_out': true},
          'swift': true,
        };

        final config = PigeonConfig.fromMap(map);
        final options = config.getPigeonOptions('pigeons/api_file.dart');

        expect(options.dartOut, equals('lib/api_file.g.dart'));
        expect(options.dartTestOut, equals('test/api_file_test.g.dart'));
        expect(options.swiftOut, equals('ios/Runner/ApiFile.g.swift'));
      });
    });
  });
}
