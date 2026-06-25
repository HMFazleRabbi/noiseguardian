import 'package:noise_guardian/domain/models/audio_features.dart';
import 'package:noise_guardian/domain/models/classification_result.dart';
import 'package:noise_guardian/domain/models/noise_class.dart';

/// On-device acoustic classifier interface (Module C).
///
/// Replace [HeuristicClassifier] with a TFLite implementation when
/// `assets/models/` contains a trained model.
abstract class TfliteClassifier {
  ClassificationResult classify(AudioFeatures features);
}

/// Deterministic heuristic classifier driven by extracted features.
///
/// Thresholds are provisional — reconcile with real model when available.
class HeuristicClassifier implements TfliteClassifier {
  const HeuristicClassifier({
    this.lowFreqThreshold = 0.45,
    this.impulsiveThreshold = 8.0,
    this.centroidThreshold = 2500.0,
    this.fluxThreshold = 0.05,
  });

  final double lowFreqThreshold;
  final double impulsiveThreshold;
  final double centroidThreshold;
  final double fluxThreshold;

  @override
  ClassificationResult classify(AudioFeatures features) {
    final scores = <NoiseClass, double>{
      NoiseClass.generator: _scoreGenerator(features),
      NoiseClass.piling: _scorePiling(features),
      NoiseClass.crusher: _scoreCrusher(features),
      NoiseClass.ambient: _scoreAmbient(features),
    };

    NoiseClass best = NoiseClass.ambient;
    var bestScore = -1.0;
    for (final entry in scores.entries) {
      if (entry.value > bestScore) {
        bestScore = entry.value;
        best = entry.key;
      }
    }

    return ClassificationResult(
      label: best,
      confidence: bestScore,
      scores: scores,
    );
  }

  double _scoreGenerator(AudioFeatures f) {
    if (f.lowFreqEnergyRatio > lowFreqThreshold) {
      return 0.6 + (f.lowFreqEnergyRatio - lowFreqThreshold);
    }
    return f.lowFreqEnergyRatio * 0.5;
  }

  double _scorePiling(AudioFeatures f) {
    if (f.impulsiveness > impulsiveThreshold) {
      return 0.7 + min((f.impulsiveness - impulsiveThreshold) / 10, 0.3);
    }
    return f.impulsiveness / impulsiveThreshold * 0.4;
  }

  double _scoreCrusher(AudioFeatures f) {
    if (f.spectralCentroid > centroidThreshold && f.spectralFlux > fluxThreshold) {
      return 0.65 +
          min((f.spectralCentroid - centroidThreshold) / 5000, 0.25);
    }
    return (f.spectralCentroid / centroidThreshold) * 0.3;
  }

  double _scoreAmbient(AudioFeatures f) {
    return 0.5 +
        (1 - f.lowFreqEnergyRatio) * 0.2 +
        (1 - min(f.impulsiveness / impulsiveThreshold, 1)) * 0.2;
  }
}

double min(double a, double b) => a < b ? a : b;
