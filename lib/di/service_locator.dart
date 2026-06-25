import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:noise_guardian/data/repositories/calibration_repository.dart';
import 'package:noise_guardian/data/repositories/evidence_queue_repository.dart';
import 'package:noise_guardian/data/services/audio_capture_service.dart';
import 'package:noise_guardian/data/services/audio_purge_service.dart';
import 'package:noise_guardian/data/services/calibration_service.dart';
import 'package:noise_guardian/data/services/debug_log_service.dart';
import 'package:noise_guardian/data/services/encryption_service.dart';
import 'package:noise_guardian/data/services/feature_extractor.dart';
import 'package:noise_guardian/data/services/geolocator_gps_service.dart';
import 'package:noise_guardian/data/services/gps_service.dart';
import 'package:noise_guardian/data/services/heatmap_aggregation_service.dart';
import 'package:noise_guardian/data/services/http_sync_service.dart';
import 'package:noise_guardian/data/services/key_store.dart';
import 'package:noise_guardian/data/services/laeq_service.dart';
import 'package:noise_guardian/data/services/sensor_guard_service.dart';
import 'package:noise_guardian/data/services/signing_service.dart';
import 'package:noise_guardian/data/services/sync_service.dart';
import 'package:noise_guardian/data/services/tflite_classifier.dart';
import 'package:noise_guardian/data/services/timestamp_service.dart';
import 'package:noise_guardian/data/services/violation_evaluator.dart';
import 'package:noise_guardian/data/services/zone_threshold_service.dart';
import 'package:noise_guardian/domain/use_cases/build_evidence_packet_use_case.dart';
import 'package:noise_guardian/domain/use_cases/sync_evidence_use_case.dart';
import 'package:noise_guardian/ui/features/capture/view_models/capture_view_model.dart';
import 'package:noise_guardian/ui/features/heatmap/view_models/heatmap_view_model.dart';
import 'package:noise_guardian/ui/features/history/view_models/history_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt getIt = GetIt.instance;

const String _deviceInstallIdKey = 'device_install_id';

/// DoE portal base URL — empty disables outbound sync until configured.
const String kDoePortalBaseUrl = '';

/// Registers application dependencies. Pass fakes in tests via overrides.
void configureDependencies({
  CalibrationService? calibrationService,
  CalibrationRepository? calibrationRepository,
  LaeqService? laeqService,
  SyncService? syncService,
  DebugLogService? debugLogService,
  SensorGuardService? sensorGuardService,
  AudioCaptureService? audioCaptureService,
  FeatureExtractor? featureExtractor,
  TfliteClassifier? tfliteClassifier,
  AudioPurgeService? audioPurgeService,
  ZoneThresholdService? zoneThresholdService,
  ViolationEvaluator? violationEvaluator,
  TimestampService? timestampService,
  GpsService? gpsService,
  SigningService? signingService,
  EncryptionService? encryptionService,
  KeyStore? keyStore,
  BuildEvidencePacketUseCase? buildEvidencePacketUseCase,
  EvidenceQueueRepository? evidenceQueueRepository,
  HeatmapAggregationService? heatmapAggregationService,
  SyncEvidenceUseCase? syncEvidenceUseCase,
  http.Client? httpClient,
  String? doePortalBaseUrl,
  String? deviceInstallId,
}) {
  _unregisterStageServices();

  if (calibrationRepository != null) {
    getIt.registerLazySingleton<CalibrationRepository>(() => calibrationRepository);
  }

  getIt.registerLazySingleton<CalibrationService>(
    () {
      if (calibrationService != null) {
        return calibrationService;
      }
      if (calibrationRepository != null) {
        return CalibrationServiceImpl(repository: calibrationRepository);
      }
      return const StubCalibrationService();
    },
  );
  getIt.registerLazySingleton<LaeqService>(
    () => laeqService ?? const LaeqService(),
  );
  getIt.registerLazySingleton<DebugLogService>(
    () => debugLogService ?? NoopDebugLogService(),
  );
  getIt.registerLazySingleton<SensorGuardService>(
    () => sensorGuardService ?? SensorsPlusGuardService(),
  );
  getIt.registerLazySingleton<AudioCaptureService>(
    () => audioCaptureService ?? RecordAudioCaptureService(),
  );
  getIt.registerLazySingleton<FeatureExtractor>(
    () => featureExtractor ?? const FeatureExtractor(),
  );
  getIt.registerLazySingleton<TfliteClassifier>(
    () => tfliteClassifier ?? const HeuristicClassifier(),
  );
  getIt.registerLazySingleton<AudioPurgeService>(
    () => audioPurgeService ?? const AudioPurgeService(),
  );

  getIt.registerLazySingleton<TimestampService>(
    () => timestampService ?? const LocalTimestampService(),
  );
  getIt.registerLazySingleton<ZoneThresholdService>(
    () => zoneThresholdService ?? const ZoneThresholdService(),
  );
  getIt.registerLazySingleton<ViolationEvaluator>(
    () =>
        violationEvaluator ??
        ViolationEvaluator(
          thresholdService: getIt<ZoneThresholdService>(),
          timestampService: getIt<TimestampService>(),
        ),
  );
  getIt.registerLazySingleton<KeyStore>(
    () => keyStore ?? FlutterSecureKeyStore(),
  );
  getIt.registerLazySingleton<GpsService>(
    () => gpsService ?? const GeolocatorGpsService(),
  );
  getIt.registerLazySingleton<SigningService>(
    () => signingService ?? EcdsaSigningService(keyStore: getIt<KeyStore>()),
  );
  getIt.registerLazySingleton<EncryptionService>(
    () => encryptionService ?? AesEncryptionService(keyStore: getIt<KeyStore>()),
  );
  getIt.registerLazySingleton<BuildEvidencePacketUseCase>(
    () =>
        buildEvidencePacketUseCase ??
        BuildEvidencePacketUseCase(
          violationEvaluator: getIt<ViolationEvaluator>(),
          timestampService: getIt<TimestampService>(),
          gpsService: getIt<GpsService>(),
          signingService: getIt<SigningService>(),
          deviceInstallId: deviceInstallId ?? 'uninitialized-install-id',
        ),
  );

  getIt.registerLazySingleton<EvidenceQueueRepository>(
    () {
      if (evidenceQueueRepository != null) {
        return evidenceQueueRepository;
      }
      return InMemoryEvidenceQueueRepository(
        encryption: getIt<EncryptionService>(),
      );
    },
  );

  getIt.registerLazySingleton<http.Client>(
    () => httpClient ?? http.Client(),
  );
  getIt.registerLazySingleton<HeatmapAggregationService>(
    () => heatmapAggregationService ?? const HeatmapAggregationService(),
  );
  getIt.registerLazySingleton<SyncService>(
    () {
      if (syncService != null) {
        return syncService;
      }
      return HttpSyncService(
        client: getIt<http.Client>(),
        queue: getIt<EvidenceQueueRepository>(),
        baseUrl: doePortalBaseUrl ?? kDoePortalBaseUrl,
      );
    },
  );
  getIt.registerLazySingleton<SyncEvidenceUseCase>(
    () =>
        syncEvidenceUseCase ??
        SyncEvidenceUseCase(syncService: getIt<SyncService>()),
  );

  getIt.registerFactory<CaptureViewModel>(
    () => CaptureViewModel(
      sensorGuard: getIt<SensorGuardService>(),
      audioCapture: getIt<AudioCaptureService>(),
      featureExtractor: getIt<FeatureExtractor>(),
      classifier: getIt<TfliteClassifier>(),
      purgeService: getIt<AudioPurgeService>(),
      laeqService: getIt<LaeqService>(),
      calibrationService: getIt<CalibrationService>(),
      buildEvidencePacket: getIt<BuildEvidencePacketUseCase>(),
      evidenceQueue: getIt<EvidenceQueueRepository>(),
      debugLog: getIt<DebugLogService>(),
    ),
  );
  getIt.registerFactory<HistoryViewModel>(
    () => HistoryViewModel(
      queue: getIt<EvidenceQueueRepository>(),
      syncEvidence: getIt<SyncEvidenceUseCase>(),
    ),
  );
  getIt.registerFactory<HeatmapViewModel>(
    () => HeatmapViewModel(
      queue: getIt<EvidenceQueueRepository>(),
      aggregation: getIt<HeatmapAggregationService>(),
    ),
  );
}

/// Production bootstrap — loads SharedPreferences then registers services.
Future<void> configureDependenciesAsync({
  CalibrationService? calibrationService,
  SyncService? syncService,
  DebugLogService? debugLogService,
  SensorGuardService? sensorGuardService,
  AudioCaptureService? audioCaptureService,
  FeatureExtractor? featureExtractor,
  TfliteClassifier? tfliteClassifier,
  AudioPurgeService? audioPurgeService,
  ZoneThresholdService? zoneThresholdService,
  ViolationEvaluator? violationEvaluator,
  TimestampService? timestampService,
  GpsService? gpsService,
  SigningService? signingService,
  EncryptionService? encryptionService,
  KeyStore? keyStore,
  BuildEvidencePacketUseCase? buildEvidencePacketUseCase,
  EvidenceQueueRepository? evidenceQueueRepository,
  HeatmapAggregationService? heatmapAggregationService,
  SyncEvidenceUseCase? syncEvidenceUseCase,
  http.Client? httpClient,
  String? doePortalBaseUrl,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final repository = CalibrationRepository(prefs);

  var deviceInstallId = prefs.getString(_deviceInstallIdKey);
  if (deviceInstallId == null || deviceInstallId.isEmpty) {
    deviceInstallId =
        'ng-${DateTime.now().microsecondsSinceEpoch}-${prefs.hashCode}';
    await prefs.setString(_deviceInstallIdKey, deviceInstallId);
  }

  final queue = evidenceQueueRepository ??
      SqfliteEvidenceQueueRepository(
        encryption: encryptionService ?? AesEncryptionService(
          keyStore: keyStore ?? FlutterSecureKeyStore(),
        ),
      );
  await queue.init();

  configureDependencies(
    calibrationService: calibrationService,
    calibrationRepository: repository,
    syncService: syncService,
    debugLogService: debugLogService,
    sensorGuardService: sensorGuardService,
    audioCaptureService: audioCaptureService,
    featureExtractor: featureExtractor,
    tfliteClassifier: tfliteClassifier,
    audioPurgeService: audioPurgeService,
    zoneThresholdService: zoneThresholdService,
    violationEvaluator: violationEvaluator,
    timestampService: timestampService,
    gpsService: gpsService,
    signingService: signingService,
    encryptionService: encryptionService,
    keyStore: keyStore,
    buildEvidencePacketUseCase: buildEvidencePacketUseCase,
    evidenceQueueRepository: queue,
    heatmapAggregationService: heatmapAggregationService,
    syncEvidenceUseCase: syncEvidenceUseCase,
    httpClient: httpClient,
    doePortalBaseUrl: doePortalBaseUrl,
    deviceInstallId: deviceInstallId,
  );
}

Future<void> resetDependencies() async {
  if (getIt.isRegistered<DebugLogService>()) {
    await getIt<DebugLogService>().dispose();
  }
  if (getIt.isRegistered<http.Client>()) {
    getIt<http.Client>().close();
  }
  _unregisterStageServices();
}

void _unregisterStageServices() {
  _unregisterIfNeeded<CalibrationService>();
  _unregisterIfNeeded<CalibrationRepository>();
  _unregisterIfNeeded<LaeqService>();
  _unregisterIfNeeded<SyncService>();
  _unregisterIfNeeded<DebugLogService>();
  _unregisterIfNeeded<SensorGuardService>();
  _unregisterIfNeeded<AudioCaptureService>();
  _unregisterIfNeeded<FeatureExtractor>();
  _unregisterIfNeeded<TfliteClassifier>();
  _unregisterIfNeeded<AudioPurgeService>();
  _unregisterIfNeeded<ZoneThresholdService>();
  _unregisterIfNeeded<ViolationEvaluator>();
  _unregisterIfNeeded<TimestampService>();
  _unregisterIfNeeded<KeyStore>();
  _unregisterIfNeeded<GpsService>();
  _unregisterIfNeeded<SigningService>();
  _unregisterIfNeeded<EncryptionService>();
  _unregisterIfNeeded<BuildEvidencePacketUseCase>();
  _unregisterIfNeeded<EvidenceQueueRepository>();
  _unregisterIfNeeded<http.Client>();
  _unregisterIfNeeded<HeatmapAggregationService>();
  _unregisterIfNeeded<SyncEvidenceUseCase>();
  _unregisterIfNeeded<CaptureViewModel>();
  _unregisterIfNeeded<HistoryViewModel>();
  _unregisterIfNeeded<HeatmapViewModel>();
}

void _unregisterIfNeeded<T extends Object>() {
  if (getIt.isRegistered<T>()) {
    getIt.unregister<T>();
  }
}
