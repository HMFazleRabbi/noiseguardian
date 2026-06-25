import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/core/audio/feature_math.dart';
import 'package:noise_guardian/data/services/feature_extractor.dart';
import 'package:noise_guardian/domain/models/audio_features.dart';

void main() {
  const sampleRate = 44100;
  const duration = 2.0;
  late FeatureExtractor extractor;

  setUp(() {
    extractor = const FeatureExtractor();
  });

  group('FeatureExtractor', () {
    test('feature vector length matches kFeatureLength', () {
      final samples = generateTone(
        frequencyHz: 1000,
        sampleRateHz: sampleRate,
        durationSeconds: duration,
      );
      final features = extractor.extract(
        samples: samples,
        sampleRateHz: sampleRate,
      );
      expect(features.toVector().length, AudioFeatures.kFeatureLength);
    });

    test('100 Hz tone has higher low-freq energy ratio than 4 kHz tone', () {
      final lowTone = extractor.extract(
        samples: generateTone(
          frequencyHz: 100,
          sampleRateHz: sampleRate,
          durationSeconds: duration,
        ),
        sampleRateHz: sampleRate,
      );
      final highTone = extractor.extract(
        samples: generateTone(
          frequencyHz: 4000,
          sampleRateHz: sampleRate,
          durationSeconds: duration,
        ),
        sampleRateHz: sampleRate,
      );
      expect(
        lowTone.lowFreqEnergyRatio,
        greaterThan(highTone.lowFreqEnergyRatio),
      );
    });

    test('impulsive samples have higher impulsiveness than pure tone', () {
      final tone = extractor.extract(
        samples: generateTone(
          frequencyHz: 1000,
          sampleRateHz: sampleRate,
          durationSeconds: duration,
        ),
        sampleRateHz: sampleRate,
      );
      final impulsive = extractor.extract(
        samples: generateImpulsiveSamples(
          sampleRateHz: sampleRate,
          durationSeconds: duration,
        ),
        sampleRateHz: sampleRate,
      );
      expect(impulsive.impulsiveness, greaterThan(tone.impulsiveness));
    });
  });
}
