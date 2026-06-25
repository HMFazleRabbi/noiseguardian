/// Fixed-length feature vector for classifier input (Module C).
///
/// Layout: 13 MFCC means + 13 delta means + 13 delta-delta means + 6 scalars.
/// Provisional until a real TFLite model defines tensor shape.
class AudioFeatures {
  const AudioFeatures({
    required this.mfccMeans,
    required this.deltaMeans,
    required this.deltaDeltaMeans,
    required this.spectralCentroid,
    required this.spectralRolloff95,
    required this.spectralFlux,
    required this.zeroCrossingRate,
    required this.lowFreqEnergyRatio,
    required this.impulsiveness,
  });

  static const int mfccCount = 13;
  static const int scalarCount = 6;
  static const int kFeatureLength = mfccCount * 3 + scalarCount;

  final List<double> mfccMeans;
  final List<double> deltaMeans;
  final List<double> deltaDeltaMeans;
  final double spectralCentroid;
  final double spectralRolloff95;
  final double spectralFlux;
  final double zeroCrossingRate;
  final double lowFreqEnergyRatio;
  final double impulsiveness;

  List<double> toVector() {
    return [
      ...mfccMeans,
      ...deltaMeans,
      ...deltaDeltaMeans,
      spectralCentroid,
      spectralRolloff95,
      spectralFlux,
      zeroCrossingRate,
      lowFreqEnergyRatio,
      impulsiveness,
    ];
  }
}
