import 'package:noise_guardian/core/audio/feature_math.dart';
import 'package:noise_guardian/domain/models/audio_features.dart';

/// Extracts acoustic fingerprint features from PCM samples (Module C).
class FeatureExtractor {
  const FeatureExtractor();

  AudioFeatures extract({
    required List<double> samples,
    required int sampleRateHz,
  }) {
    return extractAudioFeatures(samples: samples, sampleRateHz: sampleRateHz);
  }
}
