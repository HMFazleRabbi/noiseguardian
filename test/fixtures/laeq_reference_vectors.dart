import 'dart:math';

import 'package:noise_guardian/core/audio/a_weighting.dart';

/// Reference vectors for LAeq validation (analytical A-weighted levels for pure tones).
class LaeqReferenceVector {
  const LaeqReferenceVector({
    required this.frequencyHz,
    required this.peakPressurePa,
    required this.durationSeconds,
    required this.sampleRateHz,
    required this.expectedLaeqDb,
  });

  final double frequencyHz;
  final double peakPressurePa;
  final double durationSeconds;
  final int sampleRateHz;
  final double expectedLaeqDb;

  List<double> generateSamples() {
    final sampleCount = (durationSeconds * sampleRateHz).round();
    final omega = 2 * pi * frequencyHz / sampleRateHz;
    return List<double>.generate(
      sampleCount,
      (index) => peakPressurePa * sin(omega * index),
    );
  }
}

/// IEC 61672 A-weighting curve (approximate) in dB at common test frequencies.
double aWeightDbAt(double frequencyHz) {
  return aWeightingDb(frequencyHz);
}

double analyticalLaeqForTone({
  required double peakPressurePa,
  required double frequencyHz,
}) {
  const p0 = 20e-6;
  final rms = peakPressurePa / sqrt(2);
  final flatDb = 20 * log(rms / p0) / ln10;
  return flatDb + aWeightDbAt(frequencyHz);
}

/// Vectors used in LAeq MAE gate (≤ 1.8 dB(A)).
final laeqReferenceVectors = <LaeqReferenceVector>[
  LaeqReferenceVector(
    frequencyHz: 1000,
    peakPressurePa: 0.2,
    durationSeconds: 1.0,
    sampleRateHz: 44100,
    expectedLaeqDb: analyticalLaeqForTone(peakPressurePa: 0.2, frequencyHz: 1000),
  ),
  LaeqReferenceVector(
    frequencyHz: 500,
    peakPressurePa: 0.05,
    durationSeconds: 1.0,
    sampleRateHz: 44100,
    expectedLaeqDb: analyticalLaeqForTone(peakPressurePa: 0.05, frequencyHz: 500),
  ),
  LaeqReferenceVector(
    frequencyHz: 100,
    peakPressurePa: 0.5,
    durationSeconds: 1.0,
    sampleRateHz: 44100,
    expectedLaeqDb: analyticalLaeqForTone(peakPressurePa: 0.5, frequencyHz: 100),
  ),
  LaeqReferenceVector(
    frequencyHz: 4000,
    peakPressurePa: 0.02,
    durationSeconds: 1.0,
    sampleRateHz: 44100,
    expectedLaeqDb: analyticalLaeqForTone(peakPressurePa: 0.02, frequencyHz: 4000),
  ),
  LaeqReferenceVector(
    frequencyHz: 2000,
    peakPressurePa: 0.1,
    durationSeconds: 0.5,
    sampleRateHz: 44100,
    expectedLaeqDb: analyticalLaeqForTone(peakPressurePa: 0.1, frequencyHz: 2000),
  ),
];
