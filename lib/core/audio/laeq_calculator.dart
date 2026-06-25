import 'dart:math';

import 'package:noise_guardian/core/audio/a_weighting.dart';

/// Reference sound pressure (20 µPa).
const double referencePressurePa = 20e-6;

/// Computes A-weighted equivalent level LAeq over [integrationMs].
double computeLaeq({
  required List<double> samples,
  required int sampleRateHz,
  required int integrationMs,
}) {
  if (samples.isEmpty) {
    throw ArgumentError('samples must not be empty');
  }
  if (sampleRateHz <= 0 || integrationMs <= 0) {
    throw ArgumentError('sampleRateHz and integrationMs must be positive');
  }

  final windowSamples = min(
    samples.length,
    (sampleRateHz * integrationMs / 1000).round(),
  );
  final window = samples.sublist(samples.length - windowSamples);

  var sumSquares = 0.0;
  for (final sample in window) {
    sumSquares += sample * sample;
  }
  final rms = sqrt(sumSquares / window.length);
  if (rms <= 0) {
    return double.negativeInfinity;
  }

  final flatDb = 20 * log(rms / referencePressurePa) / ln10;
  final dominantHz = _estimateDominantFrequency(window, sampleRateHz);
  return flatDb + aWeightingDb(dominantHz);
}

double _estimateDominantFrequency(List<double> samples, int sampleRateHz) {
  if (samples.length < 2) {
    return 1000;
  }

  var crossings = 0;
  for (var i = 1; i < samples.length; i++) {
    final previous = samples[i - 1];
    final current = samples[i];
    if ((previous >= 0 && current < 0) || (previous < 0 && current >= 0)) {
      crossings++;
    }
  }

  final durationSeconds = samples.length / sampleRateHz;
  if (durationSeconds <= 0 || crossings == 0) {
    return 1000;
  }
  return crossings / (2 * durationSeconds);
}

/// C-weighted peak level (LCpeak) — flat peak approximation for Stage 2.
double computeLcPeak({
  required List<double> samples,
  required int sampleRateHz,
}) {
  if (samples.isEmpty) {
    throw ArgumentError('samples must not be empty');
  }
  if (sampleRateHz <= 0) {
    throw ArgumentError('sampleRateHz must be positive');
  }

  var peak = 0.0;
  for (final sample in samples) {
    final abs = sample.abs();
    if (abs > peak) {
      peak = abs;
    }
  }
  if (peak <= 0) {
    return double.negativeInfinity;
  }
  return 20 * log(peak / referencePressurePa) / ln10;
}
