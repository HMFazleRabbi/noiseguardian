import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/core/audio/calibration_math.dart';

void main() {
  group('CalibrationMath.computeCorrectionFactor', () {
    final fixtures = <Map<String, double>>[
      {'lRef': 94, 'pMeasured': 1.0, 'pRef': 1.0, 'expectedCd': 94},
      {'lRef': 94, 'pMeasured': 0.5, 'pRef': 1.0, 'expectedCd': 94 - 20 * log(0.5) / ln10},
      {'lRef': 114, 'pMeasured': 10.0, 'pRef': 1.0, 'expectedCd': 114 - 20 * log(10) / ln10},
      {'lRef': 94, 'pMeasured': 0.25, 'pRef': 0.5, 'expectedCd': 94 - 20 * log(0.5) / ln10},
    ];

    for (final fixture in fixtures) {
      test(
        'Cd for Lref=${fixture['lRef']}, Pm=${fixture['pMeasured']}, Pref=${fixture['pRef']}',
        () {
          final cd = computeCorrectionFactor(
            lRef: fixture['lRef']!,
            pMeasured: fixture['pMeasured']!,
            pRef: fixture['pRef']!,
          );
          expect(cd, closeTo(fixture['expectedCd']!, 1e-9));
        },
      );
    }

    test('throws when power levels are non-positive', () {
      expect(
        () => computeCorrectionFactor(lRef: 94, pMeasured: 0, pRef: 1),
        throwsArgumentError,
      );
      expect(
        () => computeCorrectionFactor(lRef: 94, pMeasured: 1, pRef: -1),
        throwsArgumentError,
      );
    });
  });

  group('CalibrationMath.applyCorrection', () {
    test('adds Cd to raw dB reading', () {
      expect(applyCorrection(rawDb: 70, correctionFactor: 5), 75);
      expect(applyCorrection(rawDb: 80.5, correctionFactor: -2.5), 78);
    });
  });
}
