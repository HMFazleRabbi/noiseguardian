import 'dart:io';

import 'package:noise_guardian/core/audio/feature_math.dart';
import 'package:record/record.dart';

/// Result of an audio capture session.
class AudioCaptureResult {
  const AudioCaptureResult({
    required this.filePath,
    required this.samples,
    required this.sampleRateHz,
    required this.durationSeconds,
  });

  final String filePath;
  final List<double> samples;
  final int sampleRateHz;
  final double durationSeconds;
}

/// Records PCM audio for evidence capture (Module C).
abstract class AudioCaptureService {
  Future<AudioCaptureResult> record({
    int sampleRateHz = 44100,
    int durationSeconds = 15,
  });

  Future<bool> hasPermission();
}

/// Stub that returns synthetic tone samples without hardware.
class StubAudioCaptureService implements AudioCaptureService {
  StubAudioCaptureService({this.frequencyHz = 1000});

  final double frequencyHz;

  @override
  Future<bool> hasPermission() async => true;

  @override
  Future<AudioCaptureResult> record({
    int sampleRateHz = 44100,
    int durationSeconds = 15,
  }) async {
    final samples = generateTone(
      frequencyHz: frequencyHz,
      sampleRateHz: sampleRateHz,
      durationSeconds: durationSeconds.toDouble(),
    );
    return AudioCaptureResult(
      filePath: '/tmp/stub_capture.wav',
      samples: samples,
      sampleRateHz: sampleRateHz,
      durationSeconds: durationSeconds.toDouble(),
    );
  }
}

/// Production audio capture using the `record` package.
class RecordAudioCaptureService implements AudioCaptureService {
  RecordAudioCaptureService({AudioRecorder? recorder})
      : _recorder = recorder ?? AudioRecorder();

  static const int defaultSampleRate = 44100;

  final AudioRecorder _recorder;

  @override
  Future<bool> hasPermission() => _recorder.hasPermission();

  @override
  Future<AudioCaptureResult> record({
    int sampleRateHz = defaultSampleRate,
    int durationSeconds = 15,
  }) async {
    final hasMic = await hasPermission();
    if (!hasMic) {
      throw StateError('Microphone permission not granted');
    }

    final tempDir = Directory.systemTemp;
    final filePath =
        '${tempDir.path}/ng_capture_${DateTime.now().millisecondsSinceEpoch}.wav';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: defaultSampleRate,
        numChannels: 1,
        bitRate: 705600,
      ),
      path: filePath,
    );

    await Future<void>.delayed(Duration(seconds: durationSeconds));
    final recordedPath = await _recorder.stop();
    final path = recordedPath ?? filePath;

    final bytes = await File(path).readAsBytes();
    final samples = decodePcm16Wav(bytes);

    return AudioCaptureResult(
      filePath: path,
      samples: samples,
      sampleRateHz: sampleRateHz,
      durationSeconds: durationSeconds.toDouble(),
    );
  }
}
