import 'dart:io';

import 'package:pigeon/pigeon.dart';
import 'package:pigeon_generator/src/pigeon_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('PigeonExtension Tests', () {
    test(
      'loadConfig throws exception when both pigeon.yml and pigeon.yaml exist',
      () {
        final ymlFile = File('pigeon.yml');
        final yamlFile = File('pigeon.yaml');

        ymlFile.createSync();
        yamlFile.createSync();

        expect(
          () => PigeonExtension.loadConfig({}),
          throwsA(isA<FileSystemException>()),
        );

        ymlFile.deleteSync();
        yamlFile.deleteSync();
      },
    );

    test('loadConfig loads configuration from pigeon.yml', () {
      final ymlFile = File('pigeon.yml');
      ymlFile.writeAsStringSync('dart:\n  out: lib');

      final config = PigeonExtension.loadConfig({});
      expect(config.dart?.out, 'lib');

      ymlFile.deleteSync();
    });

    test('loadConfig loads configuration from pigeon.yaml', () {
      final yamlFile = File('pigeon.yaml');
      yamlFile.writeAsStringSync('dart:\n  out: lib');

      final config = PigeonExtension.loadConfig({});
      expect(config.dart?.out, 'lib');

      yamlFile.deleteSync();
    });

    test('loadConfig provides default configuration when no files exist', () {
      final platformOutputs = {
        'cpp': true,
        'gobject': true,
        'kotlin': true,
        'java': false,
        'swift': true,
        'objc': false,
      };

      final config = PigeonExtension.loadConfig(
        platformOutputs,
        ast: true,
        dartTest: true,
        debugGenerators: true,
      );

      expect(config.dart?.out, 'lib');
      expect(config.dart?.out, isNotNull);
      expect(config.dart?.testOut, isNotNull);
      expect(config.cpp?.headerOut, isNotNull);
      expect(config.cpp?.sourceOut, isNotNull);
      expect(config.gobject?.headerOut, isNotNull);
      expect(config.gobject?.sourceOut, isNotNull);
      expect(config.kotlin?.out, isNotNull);
      expect(config.java?.out, isNull);
      expect(config.swift?.out, isNotNull);
      expect(config.objc?.headerOut, isNull);
      expect(config.objc?.sourceOut, isNull);
      expect(config.ast?.out, isNotNull);
      expect(config.debugGenerators, isTrue);
    });
  });

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
