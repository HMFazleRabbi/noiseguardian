import 'package:noise_guardian/data/services/audio_capture_service.dart';
import 'package:noise_guardian/data/services/sensor_guard_service.dart';
import 'package:noise_guardian/domain/models/guard_state.dart';
import 'package:noise_guardian/data/services/tflite_classifier.dart';
import 'package:noise_guardian/domain/models/audio_features.dart';
import 'package:noise_guardian/domain/models/classification_result.dart';
import 'package:noise_guardian/domain/models/noise_class.dart';

class FakeSensorGuardService extends StubSensorGuardService {
  FakeSensorGuardService({super.initialState = GuardState.ok});
}

class FakeAudioCaptureService implements AudioCaptureService {
  FakeAudioCaptureService({this.result, this.permissionGranted = true});

  AudioCaptureResult? result;
  bool permissionGranted;
  int recordCallCount = 0;

  @override
  Future<bool> hasPermission() async => permissionGranted;

  @override
  Future<AudioCaptureResult> record({
    int sampleRateHz = 44100,
    int durationSeconds = 15,
  }) async {
    recordCallCount++;
    if (result == null) {
      return StubAudioCaptureService().record(
        sampleRateHz: sampleRateHz,
        durationSeconds: durationSeconds,
      );
    }
    return result!;
  }
}

class FakeTfliteClassifier implements TfliteClassifier {
  FakeTfliteClassifier({required this.result});

  final ClassificationResult result;

  @override
  ClassificationResult classify(AudioFeatures features) => result;
}

ClassificationResult fakeClassification(NoiseClass label) {
  return ClassificationResult(
    label: label,
    confidence: 0.9,
    scores: {
      for (final c in NoiseClass.values) c: c == label ? 0.9 : 0.03,
    },
  );
}
