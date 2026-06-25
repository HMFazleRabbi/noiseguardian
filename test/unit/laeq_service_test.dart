import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/data/services/laeq_service.dart';

import '../fixtures/laeq_reference_vectors.dart';

void main() {
  late LaeqService service;

  setUp(() {
    service = LaeqService();
  });

  group('LaeqService', () {
    test('LAeq reference vectors within MAE ≤ 1.8 dB(A)', () {
      var totalError = 0.0;

      for (final vector in laeqReferenceVectors) {
        final samples = vector.generateSamples();
        final laeq = service.computeLaeq(
          samples: samples,
          sampleRateHz: vector.sampleRateHz,
          integrationMs: 1000,
        );
        final error = (laeq - vector.expectedLaeqDb).abs();
        totalError += error;
      }

      final mae = totalError / laeqReferenceVectors.length;
      expect(mae, lessThanOrEqualTo(1.8));
    });

    test('125 ms integration window returns a finite level for tone', () {
      final vector = laeqReferenceVectors.first;
      final laeq = service.computeLaeq(
        samples: vector.generateSamples(),
        sampleRateHz: vector.sampleRateHz,
        integrationMs: 125,
      );
      expect(laeq.isFinite, isTrue);
      expect(laeq, greaterThan(0));
    });

    test('applyCorrection adds Cd to LAeq reading', () {
      expect(service.applyCorrection(rawDb: 65, correctionFactor: 3.5), 68.5);
    });

    test('LCpeak returns peak level for impulsive sample block', () {
      final samples = List<double>.filled(4410, 0)
        ..[2205] = 0.5
        ..[2206] = -0.5;
      final lcPeak = service.computeLcPeak(
        samples: samples,
        sampleRateHz: 44100,
      );
      expect(lcPeak, greaterThan(60));
    });
  });
}
