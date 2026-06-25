import 'package:audioplayers/audioplayers.dart';
import 'package:noise_guardian/core/audio/calibration_math.dart' as math;
import 'package:noise_guardian/core/logging/app_log.dart';
import 'package:noise_guardian/data/repositories/calibration_repository.dart';
import 'package:record/record.dart';

/// Device calibration for MEMS microphone correction (Module A).
abstract class CalibrationService {
  Future<double?> getCorrectionFactor();

  double computeCorrectionFactor({
    required double lRef,
    required double pMeasured,
    required double pRef,
  });

  Future<double> saveCalibrationFromPowers({
    required double lRef,
    required double pMeasured,
    required double pRef,
  });

  double applyCorrection(double rawDb);

  Future<void> playReferencePinkNoise();

  Future<void> stopReferencePinkNoise();
}

/// Default no-op implementation for tests and pre-Stage-2 bootstrap.
class StubCalibrationService implements CalibrationService {
  const StubCalibrationService();

  @override
  Future<double?> getCorrectionFactor() async => null;

  @override
  double computeCorrectionFactor({
    required double lRef,
    required double pMeasured,
    required double pRef,
  }) {
    return math.computeCorrectionFactor(
      lRef: lRef,
      pMeasured: pMeasured,
      pRef: pRef,
    );
  }

  @override
  Future<double> saveCalibrationFromPowers({
    required double lRef,
    required double pMeasured,
    required double pRef,
  }) async {
    return computeCorrectionFactor(
      lRef: lRef,
      pMeasured: pMeasured,
      pRef: pRef,
    );
  }

  @override
  double applyCorrection(double rawDb) => rawDb;

  @override
  Future<void> playReferencePinkNoise() async {}

  @override
  Future<void> stopReferencePinkNoise() async {}
}

/// Production calibration service with persistence and pink-noise playback.
class CalibrationServiceImpl implements CalibrationService {
  CalibrationServiceImpl({
    required CalibrationRepository repository,
    AudioPlayer? audioPlayer,
    AudioRecorder? audioRecorder,
  })  : _repository = repository,
        _audioPlayer = audioPlayer,
        _audioRecorder = audioRecorder;

  static const double defaultLRef = 94;
  static const double defaultPref = 1.0;
  static const String pinkNoiseAsset = 'sounds/pink_noise.wav';

  final CalibrationRepository _repository;
  final AudioPlayer? _audioPlayer;
  final AudioRecorder? _audioRecorder;

  double? _cachedCd;

  @override
  Future<double?> getCorrectionFactor() async {
    _cachedCd ??= await _repository.loadCorrectionFactor();
    return _cachedCd;
  }

  @override
  double computeCorrectionFactor({
    required double lRef,
    required double pMeasured,
    required double pRef,
  }) {
    return math.computeCorrectionFactor(
      lRef: lRef,
      pMeasured: pMeasured,
      pRef: pRef,
    );
  }

  @override
  Future<double> saveCalibrationFromPowers({
    required double lRef,
    required double pMeasured,
    required double pRef,
  }) async {
    final cd = computeCorrectionFactor(
      lRef: lRef,
      pMeasured: pMeasured,
      pRef: pRef,
    );
    await _repository.saveCorrectionFactor(cd);
    _cachedCd = cd;
    await appLogInfo(
      'calibration',
      'Cd saved',
      data: {'cd': cd, 'lRef': lRef, 'pMeasured': pMeasured, 'pRef': pRef},
    );
    return cd;
  }

  @override
  double applyCorrection(double rawDb) {
    final cd = _cachedCd;
    if (cd == null) {
      return rawDb;
    }
    return math.applyCorrection(rawDb: rawDb, correctionFactor: cd);
  }

  @override
  Future<void> playReferencePinkNoise() async {
    final player = _audioPlayer ?? AudioPlayer();
    await appLogInfo('calibration', 'Playing reference pink noise');
    await player.setReleaseMode(ReleaseMode.loop);
    await player.play(AssetSource(pinkNoiseAsset));
  }

  @override
  Future<void> stopReferencePinkNoise() async {
    await _audioPlayer?.stop();
    await appLogInfo('calibration', 'Stopped reference pink noise');
  }

  Future<bool> hasMicrophonePermission() async {
    final recorder = _audioRecorder ?? AudioRecorder();
    return recorder.hasPermission();
  }
}
