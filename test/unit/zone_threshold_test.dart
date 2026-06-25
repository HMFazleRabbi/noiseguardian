import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/data/services/zone_threshold_service.dart';
import 'package:noise_guardian/domain/models/zone_type.dart';

void main() {
  const service = ZoneThresholdService();

  group('ZoneThresholdService', () {
    test('residential day limit is 55 dB', () {
      expect(service.limitFor(ZoneType.residential, isNight: false), 55.0);
    });

    test('residential night limit is 48 dB', () {
      expect(service.limitFor(ZoneType.residential, isNight: true), 48.0);
    });

    test('silent zone has stricter day limit than residential', () {
      final silent = service.limitFor(ZoneType.silent, isNight: false);
      final residential = service.limitFor(ZoneType.residential, isNight: false);
      expect(silent, lessThan(residential));
    });

    test('academic night limit is stricter than day', () {
      final day = service.limitFor(ZoneType.academic, isNight: false);
      final night = service.limitFor(ZoneType.academic, isNight: true);
      expect(night, lessThan(day));
    });
  });
}
