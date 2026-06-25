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
      final gyro = List.generate(
        20,
        (_) => const GyroSample(x: 0.1, y: 0.1, z: 0.05),
      );
      expect(
        evaluateGuardState(accelSamples: accel, gyroSamples: gyro),
        GuardState.ok,
      );
    });

    test('returns muffled for near-zero motion', () {
      final accel = List.generate(
        20,
        (_) => const AccelSample(x: 0.01, y: 9.81, z: 0.01),
      );
      expect(
        evaluateGuardState(accelSamples: accel, gyroSamples: []),
        GuardState.muffled,
      );
    });

    test('returns pocketed for flat z-dominant orientation', () {
      final accel = List.generate(
        20,
        (_) => const AccelSample(x: 0.1, y: 0.1, z: 9.8),
      );
      expect(
        evaluateGuardState(accelSamples: accel, gyroSamples: []),
        GuardState.pocketed,
      );
    });

    test('returns obscured for excessive vibration', () {
      final accel = List.generate(20, (i) {
        final wobble = (i.isEven ? 3.0 : -3.0);
        return AccelSample(x: wobble, y: 9.0 + wobble, z: wobble);
      });
      final gyro = List.generate(
        20,
        (_) => const GyroSample(x: 5.0, y: 5.0, z: 5.0),
      );
      expect(
        evaluateGuardState(accelSamples: accel, gyroSamples: gyro),
        GuardState.obscured,
      );
    });
  });
}
