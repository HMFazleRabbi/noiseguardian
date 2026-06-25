/// Device calibration for MEMS microphone correction (Module A).
abstract class CalibrationService {
  Future<double?> getCorrectionFactor();
}

/// Default no-op implementation until Stage 2.
class StubCalibrationService implements CalibrationService {
  const StubCalibrationService();

  @override
  Future<double?> getCorrectionFactor() async => null;
}
