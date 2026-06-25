import 'dart:async';
import 'dart:math';

import 'package:noise_guardian/domain/models/guard_state.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// A single accelerometer reading (m/s²).
class AccelSample {
  const AccelSample({required this.x, required this.y, required this.z});

  final double x;
  final double y;
  final double z;

  double get magnitude => sqrt(x * x + y * y + z * z);
}

/// A single gyroscope reading (rad/s).
class GyroSample {
  const GyroSample({required this.x, required this.y, required this.z});

  final double x;
  final double y;
  final double z;

  double get magnitude => sqrt(x * x + y * y + z * z);
}

/// Evaluates device posture from accelerometer and gyroscope samples.
GuardState evaluateGuardState({
  required List<AccelSample> accelSamples,
  required List<GyroSample> gyroSamples,
}) {
  if (accelSamples.isEmpty) {
    return GuardState.obscured;
  }

  final magnitudes = accelSamples.map((s) => s.magnitude).toList();
  final meanMag = _mean(magnitudes);
  final variance = _variance(magnitudes, meanMag);

  final avgGyro = gyroSamples.isEmpty
      ? 0.0
      : _mean(gyroSamples.map((s) => s.magnitude).toList());

  final avgZ = _mean(accelSamples.map((s) => s.z.abs()).toList());
  final avgX = _mean(accelSamples.map((s) => s.x.abs()).toList());
  final avgY = _mean(accelSamples.map((s) => s.y.abs()).toList());

  // Pocketed: phone flat, z-axis dominant, very low motion.
  if (avgZ > avgX * 1.5 && avgZ > avgY * 1.5 && variance < 0.05) {
    return GuardState.pocketed;
  }

  // Muffled: near-zero motion and gyro, device likely covered.
  if (variance < 0.02 && avgGyro < 0.1) {
    return GuardState.muffled;
  }

  // Obscured: excessive handling vibration.
  if (variance > 2.0 || avgGyro > 3.0) {
    return GuardState.obscured;
  }

  return GuardState.ok;
}

double _mean(List<double> values) =>
    values.isEmpty ? 0 : values.reduce((a, b) => a + b) / values.length;

double _variance(List<double> values, double mean) {
  if (values.isEmpty) {
    return 0;
  }
  var sum = 0.0;
  for (final v in values) {
    final d = v - mean;
    sum += d * d;
  }
  return sum / values.length;
}

/// Context-aware safeguard during audio capture (Module B).
abstract class SensorGuardService {
  Stream<GuardState> get guardStateStream;
  GuardState get currentState;
  Future<void> startMonitoring();
  Future<void> stopMonitoring();
}

/// Stub that always reports [GuardState.ok].
class StubSensorGuardService implements SensorGuardService {
  StubSensorGuardService({this.initialState = GuardState.ok});

  final GuardState initialState;
  final _controller = StreamController<GuardState>.broadcast();

  @override
  GuardState currentState = GuardState.ok;

  @override
  Stream<GuardState> get guardStateStream => _controller.stream;

  @override
  Future<void> startMonitoring() async {
    currentState = initialState;
    _controller.add(currentState);
  }

  @override
  Future<void> stopMonitoring() async {}

  void emit(GuardState state) {
    currentState = state;
    _controller.add(state);
  }
}

/// Production sensor guard using device accelerometer and gyroscope.
class SensorsPlusGuardService implements SensorGuardService {
  SensorsPlusGuardService();

  static const int _windowSize = 20;

  final _accelBuffer = <AccelSample>[];
  final _gyroBuffer = <GyroSample>[];
  final _controller = StreamController<GuardState>.broadcast();

  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<GyroscopeEvent>? _gyroSub;

  @override
  GuardState currentState = GuardState.ok;

  @override
  Stream<GuardState> get guardStateStream => _controller.stream;

  @override
  Future<void> startMonitoring() async {
    _accelSub = accelerometerEventStream().listen((event) {
      _accelBuffer.add(AccelSample(x: event.x, y: event.y, z: event.z));
      if (_accelBuffer.length > _windowSize) {
        _accelBuffer.removeAt(0);
      }
      _evaluate();
    });
    _gyroSub = gyroscopeEventStream().listen((event) {
      _gyroBuffer.add(GyroSample(x: event.x, y: event.y, z: event.z));
      if (_gyroBuffer.length > _windowSize) {
        _gyroBuffer.removeAt(0);
      }
      _evaluate();
    });
  }

  void _evaluate() {
    if (_accelBuffer.length < 5) {
      return;
    }
    final state = evaluateGuardState(
      accelSamples: _accelBuffer,
      gyroSamples: _gyroBuffer,
    );
    if (state != currentState) {
      currentState = state;
      _controller.add(state);
    }
  }

  @override
  Future<void> stopMonitoring() async {
    await _accelSub?.cancel();
    await _gyroSub?.cancel();
    _accelBuffer.clear();
    _gyroBuffer.clear();
  }
}
