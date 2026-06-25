import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/data/repositories/calibration_repository.dart';
import 'package:noise_guardian/data/services/calibration_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('CalibrationServiceImpl', () {
    late CalibrationRepository repository;
    late CalibrationServiceImpl service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repository = CalibrationRepository(prefs);
      service = CalibrationServiceImpl(repository: repository);
    });

    test('computeCorrectionFactor matches design formula', () {
      final cd = service.computeCorrectionFactor(
        lRef: 94,
        pMeasured: 0.5,
        pRef: 1.0,
      );
      expect(cd, closeTo(100.02059991327919, 1e-6));
    });

    test('getCorrectionFactor returns persisted Cd', () async {
      await repository.saveCorrectionFactor(7.5);
      expect(await service.getCorrectionFactor(), 7.5);
    });

    test('saveCalibration persists Cd from power measurement', () async {
      final cd = await service.saveCalibrationFromPowers(
        lRef: 94,
        pMeasured: 0.5,
        pRef: 1.0,
      );
      expect(cd, closeTo(100.02059991327919, 1e-6));
      expect(await service.getCorrectionFactor(), closeTo(100.02059991327919, 1e-6));
    });

    test('applyCorrection uses stored Cd when available', () async {
      await repository.saveCorrectionFactor(4);
      await service.getCorrectionFactor();
      expect(service.applyCorrection(60), 64);
    });

    test('applyCorrection returns raw when Cd not set', () {
      expect(service.applyCorrection(60), 60);
    });
  });
}
