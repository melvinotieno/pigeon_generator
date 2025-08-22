import 'package:pigeon_generator/src/config/objc_config.dart';
import 'package:test/test.dart';

void main() {
  group('ObjcConfig', () {
    group('fromMap', () {
      test('should return null values when disabled', () {
        // Tests for null value
        ObjcConfig config = ObjcConfig.fromMap(null);

        expect(config.headerOut, isNull);
        expect(config.sourceOut, isNull);
        expect(config.getOptions('test_file'), isNull);

        // Tests for false value
        config = ObjcConfig.fromMap(false);

        expect(config.headerOut, isNull);
        expect(config.sourceOut, isNull);
        expect(config.getOptions('test_file'), isNull);
      });

      test('should create config with provided values', () {
        final map = <String, dynamic>{
          'header_out': 'path/to/header',
          'source_out': 'path/to/source',
        };

        // Tests without base folder path
        ObjcConfig config = ObjcConfig.fromMap(map);

        expect(config.headerOut?.path, equals('path/to/header'));
        expect(config.headerOut?.extension, equals('h'));
        expect(config.headerOut?.pascalCase, isFalse);
        expect(config.headerOut?.append, isNull);
        expect(config.sourceOut?.path, equals('path/to/source'));
        expect(config.sourceOut?.extension, equals('m'));
        expect(config.sourceOut?.pascalCase, isFalse);
        expect(config.sourceOut?.append, isNull);

        // Tests with base folder path
        config = ObjcConfig.fromMap(map, 'my_project');

        expect(config.headerOut?.path, equals('path/to/header'));
        expect(config.headerOut?.extension, equals('h'));
        expect(config.headerOut?.pascalCase, isFalse);
        expect(config.headerOut?.append, isNull);
        expect(config.sourceOut?.path, equals('path/to/source'));
        expect(config.sourceOut?.extension, equals('m'));
        expect(config.sourceOut?.pascalCase, isFalse);
        expect(config.sourceOut?.append, isNull);
      });

      test('should return default values for any other type', () {
        // Tests without base folder path
        ObjcConfig config = ObjcConfig.fromMap(true);

        expect(config.headerOut?.path, equals('macos/Runner'));
        expect(config.headerOut?.extension, equals('h'));
        expect(config.headerOut?.pascalCase, isFalse);
        expect(config.headerOut?.append, isNull);
        expect(config.sourceOut?.path, equals('macos/Runner'));
        expect(config.sourceOut?.extension, equals('m'));
        expect(config.sourceOut?.pascalCase, isFalse);
        expect(config.sourceOut?.append, isNull);

        // Tests with base folder path
        config = ObjcConfig.fromMap(true, 'project/folder');

        expect(config.headerOut?.path, equals('macos/Runner/Project/Folder'));
        expect(config.headerOut?.extension, equals('h'));
        expect(config.headerOut?.pascalCase, isFalse);
        expect(config.headerOut?.append, isNull);
        expect(config.sourceOut?.path, equals('macos/Runner/Project/Folder'));
        expect(config.sourceOut?.extension, equals('m'));
        expect(config.sourceOut?.pascalCase, isFalse);
        expect(config.sourceOut?.append, isNull);
      });
    });

    group('getOptions', () {
      test('should return options with provided values', () {
        final map = {
          'options': {
            'header_include': 'header/include',
            'prefix': 'my_prefix',
            'copyright_header': ['Copyright Header'],
          },
        };

        final config = ObjcConfig.fromMap(map);
        final options = config.getOptions('file');

        expect(options?.headerIncludePath, equals('header/include/file.h'));
        expect(options?.prefix, equals('my_prefix'));
        expect(options?.copyrightHeader, contains('Copyright Header'));
      });
    });
  });
}
