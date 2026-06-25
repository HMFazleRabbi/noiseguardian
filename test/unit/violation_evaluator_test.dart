import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/data/services/violation_evaluator.dart';
import 'package:noise_guardian/domain/models/violation_result.dart';
import 'package:noise_guardian/domain/models/zone_type.dart';

void main() {
  const evaluator = ViolationEvaluator();

  group('ViolationEvaluator', () {
    test('below day threshold is not a violation', () {
      final result = evaluator.evaluate(
        laeq: 54,
        lcPeak: 70,
        zone: ZoneType.residential,
        timestamp: DateTime(2026, 6, 25, 14),
      );
      expect(result.isViolation, isFalse);
      expect(result.violationType, ViolationType.none);
    });

    test('above day threshold flags exceedsDayLimit', () {
      final result = evaluator.evaluate(
        laeq: 56,
        lcPeak: 70,
        zone: ZoneType.residential,
        timestamp: DateTime(2026, 6, 25, 14),
      );
      expect(result.isViolation, isTrue);
      expect(result.violationType, ViolationType.exceedsDayLimit);
      expect(result.appliedThresholdDb, 55);
    });

    test('above night threshold at 22:00 flags exceedsNightLimit', () {
      final result = evaluator.evaluate(
        laeq: 50,
        lcPeak: 70,
        zone: ZoneType.residential,
        timestamp: DateTime(2026, 6, 25, 22),
      );
      expect(result.isViolation, isTrue);
      expect(result.violationType, ViolationType.exceedsNightLimit);
      expect(result.appliedThresholdDb, 48);
    });

    test('restricted hour at 23:00 flags restrictedHour', () {
      final result = evaluator.evaluate(
        laeq: 50,
        lcPeak: 70,
        zone: ZoneType.residential,
        timestamp: DateTime(2026, 6, 25, 23),
      );
      expect(result.isViolation, isTrue);
      expect(result.violationType, ViolationType.restrictedHour);
    });

    test('silent zone uses stricter threshold', () {
      final result = evaluator.evaluate(
        laeq: 51,
        lcPeak: 70,
        zone: ZoneType.silent,
        timestamp: DateTime(2026, 6, 25, 12),
      );
      expect(result.isViolation, isTrue);
      expect(result.appliedThresholdDb, 50);
    });
  });
}
