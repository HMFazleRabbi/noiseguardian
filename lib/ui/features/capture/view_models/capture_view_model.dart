import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:noise_guardian/core/logging/app_log.dart';
import 'package:noise_guardian/data/repositories/evidence_queue_repository.dart';
import 'package:noise_guardian/data/services/audio_capture_service.dart';
import 'package:noise_guardian/data/services/audio_purge_service.dart';
import 'package:noise_guardian/data/services/calibration_service.dart';
import 'package:noise_guardian/data/services/debug_log_service.dart';
import 'package:noise_guardian/data/services/feature_extractor.dart';
import 'package:noise_guardian/data/services/laeq_service.dart';
import 'package:noise_guardian/data/services/sensor_guard_service.dart';
import 'package:noise_guardian/data/services/tflite_classifier.dart';
import 'package:noise_guardian/data/services/timestamp_service.dart';
import 'package:noise_guardian/data/services/zone_threshold_service.dart';
import 'package:noise_guardian/domain/models/classification_result.dart';
import 'package:noise_guardian/domain/models/evidence_packet.dart';
import 'package:noise_guardian/domain/models/guard_state.dart';
import 'package:noise_guardian/domain/models/zone_type.dart';
import 'package:noise_guardian/domain/use_cases/build_evidence_packet_use_case.dart';

class CaptureViewModel extends ChangeNotifier {
  CaptureViewModel({
    SensorGuardService? sensorGuard,
    AudioCaptureService? audioCapture,
    FeatureExtractor? featureExtractor,
    TfliteClassifier? classifier,
    AudioPurgeService? purgeService,
    LaeqService? laeqService,
    CalibrationService? calibrationService,
    BuildEvidencePacketUseCase? buildEvidencePacket,
    EvidenceQueueRepository? evidenceQueue,
    DebugLogService? debugLog,
    ZoneThresholdService? zoneThreshold,
    TimestampService? timestampService,
    ZoneType zoneType = ZoneType.residential,
  })  : _sensorGuard = sensorGuard ?? StubSensorGuardService(),
        _audioCapture = audioCapture ?? StubAudioCaptureService(),
        _featureExtractor = featureExtractor ?? const FeatureExtractor(),
        _classifier = classifier ?? const HeuristicClassifier(),
        _purgeService = purgeService ?? const AudioPurgeService(),
        _laeqService = laeqService ?? const LaeqService(),
        _calibrationService = calibrationService ?? const StubCalibrationService(),
        _buildEvidencePacket = buildEvidencePacket,
        _evidenceQueue = evidenceQueue,
        _debugLog = debugLog ?? NoopDebugLogService(),
        _zoneThreshold = zoneThreshold ?? const ZoneThresholdService(),
        _timestampService = timestampService ?? const LocalTimestampService(),
        _zoneType = zoneType;

  final SensorGuardService _sensorGuard;
  final AudioCaptureService _audioCapture;
  final FeatureExtractor _featureExtractor;
  final TfliteClassifier _classifier;
  final AudioPurgeService _purgeService;
  final LaeqService _laeqService;
  final CalibrationService _calibrationService;
  final BuildEvidencePacketUseCase? _buildEvidencePacket;
  final EvidenceQueueRepository? _evidenceQueue;
  final DebugLogService _debugLog;
  final ZoneThresholdService _zoneThreshold;
  final TimestampService _timestampService;
  final ZoneType _zoneType;

  StreamSubscription<GuardState>? _guardSub;

  GuardState _guardState = GuardState.ok;
  bool _isRecording = false;
  bool _busy = false;
  double? _lastLaeq;
  ClassificationResult? _lastResult;
  EvidencePacket? _lastEvidencePacket;
  int? _lastQueueId;
  String? _errorMessage;

  GuardState get guardState => _guardState;
  bool get isRecording => _isRecording;
  bool get busy => _busy;
  double? get lastLaeq => _lastLaeq;
  ClassificationResult? get lastResult => _lastResult;
  EvidencePacket? get lastEvidencePacket => _lastEvidencePacket;
  int? get lastQueueId => _lastQueueId;
  String? get errorMessage => _errorMessage;
  bool get canRecord => !_busy;

  double get zoneThresholdDb {
    final isNight = _timestampService.isNight(DateTime.now());
    return _zoneThreshold.limitFor(_zoneType, isNight: isNight);
  }

  Future<void> initialize() async {
    await _sensorGuard.startMonitoring();
    _guardSub = _sensorGuard.guardStateStream.listen((state) {
      _guardState = state;
      notifyListeners();
    });
    _guardState = _sensorGuard.currentState;
    notifyListeners();
  }

  Future<void> record({int durationSeconds = 15}) async {
    _busy = true;
    _isRecording = true;
    _errorMessage = null;
    _lastResult = null;
    _lastLaeq = null;
    _lastEvidencePacket = null;
    _lastQueueId = null;
    notifyListeners();

    try {
      await appLogInfo('capture', 'Recording started', data: {'duration': durationSeconds});

      final capture = await _audioCapture.record(durationSeconds: durationSeconds);

      final rawLaeq = _laeqService.computeLaeq(
        samples: capture.samples,
        sampleRateHz: capture.sampleRateHz,
      );
      await _calibrationService.getCorrectionFactor();
      _lastLaeq = _calibrationService.applyCorrection(rawLaeq);

      final features = _featureExtractor.extract(
        samples: capture.samples,
        sampleRateHz: capture.sampleRateHz,
      );
      _lastResult = _classifier.classify(features);

      await _purgeService.purge(filePath: capture.filePath);

      if (_buildEvidencePacket != null && _lastLaeq != null && _lastResult != null) {
        _lastEvidencePacket = await _buildEvidencePacket.execute(
          laeqDb: _lastLaeq!,
          lcPeakDb: _lastLaeq! + 6,
          noiseClass: _lastResult!.label.name,
          zoneType: _zoneType,
        );
        await _debugLog.info(
          'evidence',
          'Evidence packet built',
          data: {
            'hash': _lastEvidencePacket!.security.hashSha256,
            'violation': _lastEvidencePacket!.metrics.isViolation,
          },
        );
        await appLogInfo(
          'evidence',
          'Packet built',
          data: {
            'hash_sha256': _lastEvidencePacket!.security.hashSha256,
            'gps_obfuscated_lat': _lastEvidencePacket!.metadata.latObfuscated,
            'gps_obfuscated_lon': _lastEvidencePacket!.metadata.lonObfuscated,
          },
        );
        if (_evidenceQueue != null) {
          final packet = _lastEvidencePacket!;
          final queue = _evidenceQueue;
          _lastQueueId = await queue.enqueue(packet);
          await _debugLog.info(
            'queue',
            'Evidence enqueued',
            data: {'queue_id': _lastQueueId},
          );
          await appLogInfo(
            'queue',
            'Packet enqueued',
            data: {'queue_id': _lastQueueId},
          );
        }
      }

      await appLogInfo(
        'capture',
        'Capture complete',
        data: {
          'class': _lastResult!.label.name,
          'confidence': _lastResult!.confidence,
          'laeq': _lastLaeq,
        },
      );
    } catch (error, stack) {
      _errorMessage = error.toString();
      await appLogError(
        'capture',
        'Capture failed',
        error: error,
        stackTrace: stack,
      );
    } finally {
      _isRecording = false;
      _busy = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    unawaited(_guardSub?.cancel());
    unawaited(_sensorGuard.stopMonitoring());
    super.dispose();
  }
}
