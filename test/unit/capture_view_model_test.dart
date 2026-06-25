import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/core/audio/feature_math.dart';
import 'package:noise_guardian/data/services/audio_capture_service.dart';
import 'package:noise_guardian/domain/models/guard_state.dart';
import 'package:noise_guardian/domain/models/noise_class.dart';
import 'package:noise_guardian/ui/features/capture/view_models/capture_view_model.dart';

import '../fakes/fake_capture_services.dart';

void main() {
  group('CaptureViewModel', () {
    test('records even when guard is unsteady (advisory only)', () async {
      final guard = FakeSensorGuardService(initialState: GuardState.unsteady);
      final capture = FakeAudioCaptureService();
      final vm = CaptureViewModel(
        sensorGuard: guard,
        audioCapture: capture,
      );

      await vm.initialize();
      await vm.record();

      expect(capture.recordCallCount, 1);
      expect(vm.guardState, GuardState.unsteady);
      expect(vm.errorMessage, isNull);
    });

    test('full flow produces classification result and purges audio', () async {
      final samples = generateTone(
        frequencyHz: 100,
        sampleRateHz: 44100,
        durationSeconds: 2,
      );
      final tempPath = 'test_capture.wav';
      final capture = FakeAudioCaptureService(
        result: AudioCaptureResult(
          filePath: tempPath,
          samples: samples,
          sampleRateHz: 44100,
          durationSeconds: 2,
        ),
      );
      final vm = CaptureViewModel(
        sensorGuard: FakeSensorGuardService(),
        audioCapture: capture,
        classifier: FakeTfliteClassifier(
          result: fakeClassification(NoiseClass.generator),
        ),
      );

      await vm.initialize();
      await vm.record(durationSeconds: 2);

      expect(capture.recordCallCount, 1);
      expect(vm.lastResult?.label, NoiseClass.generator);
      expect(vm.lastLaeq, isNotNull);
      expect(vm.errorMessage, isNull);
    });
  });
}
