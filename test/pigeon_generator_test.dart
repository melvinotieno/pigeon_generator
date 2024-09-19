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

    test('returns PigeonBuilder with correct platform outputs', () {
      final options = BuilderOptions({
        'platforms': ['windows', 'linux', 'android:kotlin', 'ios'],
        'ast': true,
        'dart_test': true,
        'debug_generators': true,
      });

      final builder = pigeonBuilder(options) as PigeonBuilder;
      final config = builder.pigeonConfig;

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
}
