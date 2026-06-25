import 'package:noise_guardian/data/services/calibration_service.dart';

class FakeCalibrationService implements CalibrationService {
  FakeCalibrationService({this.correctionFactor});

  double? correctionFactor;

  @override
  Future<double?> getCorrectionFactor() async => correctionFactor;
}
