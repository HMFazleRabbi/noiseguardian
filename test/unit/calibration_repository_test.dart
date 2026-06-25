import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/data/repositories/calibration_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('CalibrationRepository', () {
    late CalibrationRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repository = CalibrationRepository(prefs);
    });

    test('returns null when Cd not stored', () async {
      expect(await repository.loadCorrectionFactor(), isNull);
    });

    test('persists and loads Cd', () async {
      await repository.saveCorrectionFactor(12.34);
      expect(await repository.loadCorrectionFactor(), 12.34);
    });

    test('clears stored Cd', () async {
      await repository.saveCorrectionFactor(5);
      await repository.clearCorrectionFactor();
      expect(await repository.loadCorrectionFactor(), isNull);
    });
  });
}
