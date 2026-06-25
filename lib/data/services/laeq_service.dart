import 'package:noise_guardian/core/audio/calibration_math.dart' as math;
import 'package:noise_guardian/core/audio/laeq_calculator.dart' as laeq;

/// A-weighted sound level integration service (Module A).
class LaeqService {
  const LaeqService();

  double computeLaeq({
    required List<double> samples,
    required int sampleRateHz,
    int integrationMs = 1000,
  }) {
    return laeq.computeLaeq(
      samples: samples,
      sampleRateHz: sampleRateHz,
      integrationMs: integrationMs,
    );
  }

  double computeLcPeak({
    required List<double> samples,
    required int sampleRateHz,
  }) {
    return laeq.computeLcPeak(samples: samples, sampleRateHz: sampleRateHz);
  }

  double applyCorrection({
    required double rawDb,
    required double correctionFactor,
  }) {
    return math.applyCorrection(rawDb: rawDb, correctionFactor: correctionFactor);
  }
}
