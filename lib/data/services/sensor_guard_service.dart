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

/// Evaluates device posture from accelerometer variance (advisory only).
GuardState evaluateGuardState({
  required List<AccelSample> accelSamples,
}) {
  if (accelSamples.length < 5) {
    return GuardState.ok;
  }

  final magnitudes = accelSamples.map((s) => s.magnitude).toList();
  final meanMag = _mean(magnitudes);
  final variance = _variance(magnitudes, meanMag);

  // Excessive handling vibration → advisory banner; capture is never blocked.
  if (variance > 2.0) {
    return GuardState.unsteady;
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

/// Production sensor guard using device accelerometer only.
class SensorsPlusGuardService implements SensorGuardService {
  SensorsPlusGuardService();

  static const int _windowSize = 20;

  final _accelBuffer = <AccelSample>[];
  final _controller = StreamController<GuardState>.broadcast();

  StreamSubscription<AccelerometerEvent>? _accelSub;

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
  }

  void _evaluate() {
    if (_accelBuffer.length < 5) {
      return;
    }
    final state = evaluateGuardState(accelSamples: _accelBuffer);
    if (state != currentState) {
      currentState = state;
      _controller.add(state);
    }
  }

  @override
  Future<void> stopMonitoring() async {
    await _accelSub?.cancel();
    _accelBuffer.clear();
  }
}
