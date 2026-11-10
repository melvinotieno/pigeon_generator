import 'dart:io';

import 'package:pigeon_generator/src/pigeon_builder.dart';
import 'package:pigeon_generator/src/pigeon_config.dart';
import 'package:test/test.dart';

void main() {
  group('PigeonBuilder', () {
    late Directory tempDir;
    late String originalDir;

    setUp(() async {
      originalDir = Directory.current.path;
      tempDir = await Directory.systemTemp.createTemp('pigeon_builder_test_');
      Directory.current = tempDir;
    });

    tearDown(() async {
      Directory.current = originalDir;
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    group('buildExtensions', () {
      test('keys use posix separators regardless of OS', () async {
        await Directory('pigeons').create();
        await File('pigeons/img_api.dart').writeAsString('''
          import 'package:pigeon/pigeon.dart';

          @HostApi()
          abstract class ImgApi {
            void send();
          }
        ''');

        final config = PigeonConfig.fromMap({});
        final builder = PigeonBuilder(config);

        expect(
          builder.buildExtensions.keys,
          everyElement(isNot(contains('\\'))),
        );
      });

      test('keys start with the inputs folder', () async {
        await Directory('pigeons').create();
        await File('pigeons/img_api.dart').writeAsString('''
          import 'package:pigeon/pigeon.dart';

          @HostApi()
          abstract class ImgApi {
            void send();
          }
        ''');

        final config = PigeonConfig.fromMap({});
        final builder = PigeonBuilder(config);

        expect(
          builder.buildExtensions.keys,
          everyElement(startsWith('pigeons/')),
        );
      });

      test('returns empty map when inputs directory does not exist', () {
        final config = PigeonConfig.fromMap({'inputs': 'nonexistent'});
        final builder = PigeonBuilder(config);

        expect(builder.buildExtensions, isEmpty);
      });
    });
  });
}
