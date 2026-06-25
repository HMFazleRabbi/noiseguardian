import 'dart:math';

/// IEC 61672-1 correction factor from reference pink-noise power levels.
double computeCorrectionFactor({
  required double lRef,
  required double pMeasured,
  required double pRef,
}) {
  if (pMeasured <= 0 || pRef <= 0) {
    throw ArgumentError('Power levels must be positive');
  }
  return lRef - 20 * log(pMeasured / pRef) / ln10;
}

/// Applies device correction [correctionFactor] (Cd) to a raw dB reading.
double applyCorrection({
  required double rawDb,
  required double correctionFactor,
}) {
  return rawDb + correctionFactor;
}
