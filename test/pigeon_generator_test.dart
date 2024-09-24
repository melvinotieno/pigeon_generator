import 'package:build/build.dart';
import 'package:pigeon_generator/pigeon_generator.dart';
import 'package:pigeon_generator/src/pigeon_builder.dart';
import 'package:test/test.dart';

void main() {
  group('Pigeon Generator Tests', () {
    test('pigeonBuilder function returns PigeonBuilder', () {
      final builder = pigeonBuilder(BuilderOptions({}));
      expect(builder, isA<PigeonBuilder>());
    });

    test('returns PigeonBuilder with correct PigeonConfig', () {
      final options = BuilderOptions({
        'dart': {'test_out': true},
        'kotlin': true,
        'swift': true,
        'ast': true,
        'debug_generators': true,
      });

      final builder = pigeonBuilder(options) as PigeonBuilder;
      final config = builder.pigeonConfig;

      expect(config.dart?.out, isNotNull);
      expect(config.dart?.testOut, isNotNull);
      expect(config.cpp?.headerOut, isNull);
      expect(config.cpp?.sourceOut, isNull);
      expect(config.gobject?.headerOut, isNull);
      expect(config.gobject?.sourceOut, isNull);
      expect(config.kotlin?.out, isNull); // There's no build.gradle file
      expect(config.java?.out, isNull);
      expect(config.swift?.out, isNotNull);
      expect(config.objc?.headerOut, isNull);
      expect(config.objc?.sourceOut, isNull);
      expect(config.ast?.out, isNotNull);
      expect(config.debugGenerators, isTrue);
    });
  });
}
