import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/data/services/tflite_classifier.dart';
import 'package:noise_guardian/domain/models/audio_features.dart';
import 'package:noise_guardian/domain/models/noise_class.dart';

AudioFeatures _features({
  double lowFreq = 0.2,
  double impulsive = 2.0,
  double centroid = 1000,
  double flux = 0.02,
}) {
  return AudioFeatures(
    mfccMeans: List<double>.filled(13, 0),
    deltaMeans: List<double>.filled(13, 0),
    deltaDeltaMeans: List<double>.filled(13, 0),
    spectralCentroid: centroid,
    spectralRolloff95: centroid * 1.5,
    spectralFlux: flux,
    zeroCrossingRate: 0.1,
    lowFreqEnergyRatio: lowFreq,
    impulsiveness: impulsive,
  );
}

void main() {
  const classifier = HeuristicClassifier();

  group('HeuristicClassifier', () {
    test('classifies high low-freq ratio as generator', () {
      final result = classifier.classify(_features(lowFreq: 0.7));
      expect(result.label, NoiseClass.generator);
    });

    test('classifies high impulsiveness as piling', () {
      final result = classifier.classify(_features(impulsive: 15.0));
      expect(result.label, NoiseClass.piling);
    });

    test('classifies high centroid + flux as crusher', () {
      final result = classifier.classify(
        _features(centroid: 4000, flux: 0.1, lowFreq: 0.1, impulsive: 2),
      );
      expect(result.label, NoiseClass.crusher);
    });

    test('classifies balanced profile as ambient', () {
      final result = classifier.classify(_features());
      expect(result.label, NoiseClass.ambient);
    });
  });
}
