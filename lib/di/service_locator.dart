import 'package:get_it/get_it.dart';
import 'package:noise_guardian/data/repositories/app_settings_repository.dart';
import 'package:noise_guardian/data/repositories/calibration_repository.dart';
import 'package:noise_guardian/data/repositories/consent_repository.dart';
import 'package:noise_guardian/data/repositories/report_repository.dart';
import 'package:noise_guardian/data/services/audio_capture_service.dart';
import 'package:noise_guardian/data/services/audio_purge_service.dart';
import 'package:noise_guardian/data/services/calibration_service.dart';
import 'package:noise_guardian/data/services/debug_log_service.dart';
import 'package:noise_guardian/data/services/encryption_service.dart';
import 'package:noise_guardian/data/services/feature_extractor.dart';
import 'package:noise_guardian/data/services/geolocator_gps_service.dart';
import 'package:noise_guardian/data/services/gps_service.dart';
import 'package:noise_guardian/data/services/key_store.dart';
import 'package:noise_guardian/data/services/laeq_service.dart';
import 'package:noise_guardian/data/services/pdf_export_service.dart';
import 'package:noise_guardian/data/services/sensor_guard_service.dart';
import 'package:noise_guardian/data/services/signing_service.dart';
import 'package:noise_guardian/data/services/tflite_classifier.dart';
import 'package:noise_guardian/data/services/timestamp_service.dart';
import 'package:noise_guardian/data/services/violation_evaluator.dart';
import 'package:noise_guardian/data/services/zone_threshold_service.dart';
import 'package:noise_guardian/domain/use_cases/build_evidence_packet_use_case.dart';
import 'package:noise_guardian/ui/features/capture/view_models/capture_view_model.dart';
import 'package:noise_guardian/ui/features/reports/view_models/reports_view_model.dart';
import 'package:noise_guardian/ui/features/settings/view_models/settings_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt getIt = GetIt.instance;

const String _deviceInstallIdKey = 'device_install_id';

/// Registers application dependencies. Pass fakes in tests via overrides.
void configureDependencies({
  CalibrationService? calibrationService,
  CalibrationRepository? calibrationRepository,
  ConsentRepository? consentRepository,
  AppSettingsRepository? appSettingsRepository,
  ReportRepository? reportRepository,
  LaeqService? laeqService,
  PdfExportService? pdfExportService,
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
  String? deviceInstallId,
  bool hasConsented = true,
}) {
  _unregisterStageServices();

  if (calibrationRepository != null) {
    getIt.registerLazySingleton<CalibrationRepository>(() => calibrationRepository);
  }
  if (consentRepository != null) {
    getIt.registerLazySingleton<ConsentRepository>(() => consentRepository);
  }
  if (appSettingsRepository != null) {
    getIt.registerLazySingleton<AppSettingsRepository>(() => appSettingsRepository);
  }

  getIt.registerLazySingleton<ReportRepository>(
    () => reportRepository ?? InMemoryReportRepository(),
  );

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
  getIt.registerLazySingleton<PdfExportService>(
    () => pdfExportService ?? const PdfExportService(),
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
      reportRepository: getIt<ReportRepository>(),
      debugLog: getIt<DebugLogService>(),
      zoneThreshold: getIt<ZoneThresholdService>(),
      timestampService: getIt<TimestampService>(),
    ),
  );
  getIt.registerFactory<ReportsViewModel>(
    () => ReportsViewModel(
      reports: getIt<ReportRepository>(),
      pdfExport: getIt<PdfExportService>(),
    ),
  );
  if (getIt.isRegistered<ConsentRepository>()) {
    getIt.registerFactory<SettingsViewModel>(
      () => SettingsViewModel(
        consent: getIt<ConsentRepository>(),
        reports: getIt<ReportRepository>(),
        pdfExport: getIt<PdfExportService>(),
      ),
    );
  }
}

/// Production bootstrap — loads SharedPreferences then registers services.
Future<void> configureDependenciesAsync({
  CalibrationService? calibrationService,
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
  ReportRepository? reportRepository,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final repository = CalibrationRepository(prefs);
  final consentRepository = ConsentRepository(prefs);
  final appSettingsRepository = AppSettingsRepository(prefs);

  var deviceInstallId = prefs.getString(_deviceInstallIdKey);
  if (deviceInstallId == null || deviceInstallId.isEmpty) {
    deviceInstallId =
        'ng-${DateTime.now().microsecondsSinceEpoch}-${prefs.hashCode}';
    await prefs.setString(_deviceInstallIdKey, deviceInstallId);
  }

  final reports = reportRepository ?? FileReportRepository();
  await reports.init();

  configureDependencies(
    calibrationService: calibrationService,
    calibrationRepository: repository,
    consentRepository: consentRepository,
    appSettingsRepository: appSettingsRepository,
    reportRepository: reports,
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
    deviceInstallId: deviceInstallId,
  );
}

Future<void> resetDependencies() async {
  if (getIt.isRegistered<DebugLogService>()) {
    await getIt<DebugLogService>().dispose();
  }
  _unregisterStageServices();
}

void _unregisterStageServices() {
  _unregisterIfNeeded<CalibrationService>();
  _unregisterIfNeeded<CalibrationRepository>();
  _unregisterIfNeeded<ConsentRepository>();
  _unregisterIfNeeded<AppSettingsRepository>();
  _unregisterIfNeeded<ReportRepository>();
  _unregisterIfNeeded<LaeqService>();
  _unregisterIfNeeded<PdfExportService>();
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
  _unregisterIfNeeded<CaptureViewModel>();
  _unregisterIfNeeded<ReportsViewModel>();
  _unregisterIfNeeded<SettingsViewModel>();
}

void _unregisterIfNeeded<T extends Object>() {
  if (getIt.isRegistered<T>()) {
    getIt.unregister<T>();
  }
}
