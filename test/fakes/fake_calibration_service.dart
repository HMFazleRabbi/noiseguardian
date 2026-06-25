import 'package:noise_guardian/core/audio/calibration_math.dart' as math;
import 'package:noise_guardian/data/services/calibration_service.dart';

class FakeCalibrationService implements CalibrationService {
  FakeCalibrationService({this.correctionFactor});

  double? correctionFactor;

  @override
  Future<double?> getCorrectionFactor() async => correctionFactor;

  @override
  double computeCorrectionFactor({
    required double lRef,
    required double pMeasured,
    required double pRef,
  }) {
    return math.computeCorrectionFactor(
      lRef: lRef,
      pMeasured: pMeasured,
      pRef: pRef,
    );
  }

  @override
  Future<double> saveCalibrationFromPowers({
    required double lRef,
    required double pMeasured,
    required double pRef,
  }) async {
    correctionFactor = computeCorrectionFactor(
      lRef: lRef,
      pMeasured: pMeasured,
      pRef: pRef,
    );
    return correctionFactor!;
  }

  @override
  double applyCorrection(double rawDb) {
    return rawDb + (correctionFactor ?? 0);
  }

  @override
  Future<void> playReferencePinkNoise() async {}

  @override
  Future<void> stopReferencePinkNoise() async {}
}
