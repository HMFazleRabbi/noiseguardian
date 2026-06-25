import 'package:noise_guardian/domain/models/noise_class.dart';

/// Output of on-device acoustic classification (Module C).
class ClassificationResult {
  const ClassificationResult({
    required this.label,
    required this.confidence,
    required this.scores,
  });

  final NoiseClass label;
  final double confidence;
  final Map<NoiseClass, double> scores;
}
