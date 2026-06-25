import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/data/services/sensor_guard_service.dart';
import 'package:noise_guardian/domain/models/guard_state.dart';

void main() {
  group('evaluateGuardState', () {
    test('returns ok for normal handheld profile', () {
      final accel = List.generate(
        20,
        (_) => const AccelSample(x: 0.2, y: 9.5, z: 1.0),
      );
      expect(
        evaluateGuardState(accelSamples: accel),
        GuardState.ok,
      );
    });

    test('returns unsteady for excessive handling vibration', () {
      final accel = List.generate(20, (i) {
        final wobble = (i.isEven ? 3.0 : -3.0);
        return AccelSample(x: wobble, y: 9.0 + wobble, z: wobble);
      });
      expect(
        evaluateGuardState(accelSamples: accel),
        GuardState.unsteady,
      );
    });

    test('returns ok when samples are empty (advisory only, no block)', () {
      expect(
        evaluateGuardState(accelSamples: []),
        GuardState.ok,
      );
    });
  });
}
