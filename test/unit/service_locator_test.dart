import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/core/locale/app_locale_notifier.dart';
import 'package:noise_guardian/data/repositories/app_settings_repository.dart';
import 'package:noise_guardian/data/repositories/consent_repository.dart';
import 'package:noise_guardian/data/repositories/evidence_queue_repository.dart';
import 'package:noise_guardian/data/services/calibration_service.dart';
import 'package:noise_guardian/data/services/connectivity_service.dart';
import 'package:noise_guardian/data/services/debug_log_service.dart';
import 'package:noise_guardian/data/services/encryption_service.dart';
import 'package:noise_guardian/data/services/geolocator_gps_service.dart';
import 'package:noise_guardian/data/services/gps_service.dart';
import 'package:noise_guardian/data/services/http_sync_service.dart';
import 'package:noise_guardian/data/services/local_mock_doe_sync_service.dart';
import 'package:noise_guardian/data/services/pdf_export_service.dart';
import 'package:noise_guardian/data/services/signing_service.dart';
import 'package:noise_guardian/data/services/sync_service.dart';
import 'package:noise_guardian/data/services/timestamp_service.dart';
import 'package:noise_guardian/data/services/violation_evaluator.dart';
import 'package:noise_guardian/data/services/zone_threshold_service.dart';
import 'package:noise_guardian/di/service_locator.dart';
import 'package:noise_guardian/domain/use_cases/build_evidence_packet_use_case.dart';
import 'package:noise_guardian/domain/models/sync_summary.dart';
import 'package:noise_guardian/domain/use_cases/sync_evidence_use_case.dart';
import 'package:noise_guardian/ui/features/history/view_models/history_view_model.dart';
import 'package:noise_guardian/ui/features/settings/view_models/settings_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../fakes/fake_calibration_service.dart';
import '../fakes/fake_evidence_queue_repository.dart';
import '../fakes/fake_sync_service.dart';

void main() {
  group('ServiceLocator', () {
    tearDown(() async {
      await resetDependencies();
    });

    test('registers and resolves stub services by default', () {
      configureDependencies(deviceInstallId: 'test-device');

      expect(getIt<CalibrationService>(), isA<StubCalibrationService>());
      expect(getIt<SyncService>(), isA<LocalMockDoeSyncService>());
      expect(getIt<DebugLogService>(), isA<NoopDebugLogService>());
      expect(getIt<ConnectivityService>(), isA<AlwaysWifiConnectivityService>());
      expect(getIt<PdfExportService>(), isA<PdfExportService>());
      expect(getIt<AppLocaleNotifier>(), isA<AppLocaleNotifier>());
      expect(getIt<ZoneThresholdService>(), isA<ZoneThresholdService>());
      expect(getIt<ViolationEvaluator>(), isA<ViolationEvaluator>());
      expect(getIt<TimestampService>(), isA<LocalTimestampService>());
      expect(getIt<GpsService>(), isA<GeolocatorGpsService>());
      expect(getIt<SigningService>(), isA<EcdsaSigningService>());
      expect(getIt<EncryptionService>(), isA<AesEncryptionService>());
      expect(getIt<BuildEvidencePacketUseCase>(), isA<BuildEvidencePacketUseCase>());
    });

    test('registers Stage 5 services when queue provided', () {
      final queue = FakeEvidenceQueueRepository();
      configureDependencies(
        deviceInstallId: 'test-device',
        evidenceQueueRepository: queue,
      );

      expect(getIt<EvidenceQueueRepository>(), same(queue));
      expect(getIt<SyncEvidenceUseCase>(), isA<SyncEvidenceUseCase>());
      expect(getIt<SyncService>(), isA<LocalMockDoeSyncService>());
      expect(getIt<HistoryViewModel>(), isA<HistoryViewModel>());
    });

    test('uses LocalMockDoeSyncService when useMockDoe is true', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      configureDependencies(
        useMockDoe: true,
        appSettingsRepository: AppSettingsRepository(prefs),
        evidenceQueueRepository: FakeEvidenceQueueRepository(),
      );

      expect(getIt<SyncService>(), isA<LocalMockDoeSyncService>());
    });

    test('uses HttpSyncService when useMockDoe false and portal URL set', () {
      configureDependencies(
        useMockDoe: false,
        doePortalBaseUrl: 'https://doe.example.gov.bd',
        evidenceQueueRepository: FakeEvidenceQueueRepository(),
      );

      expect(getIt<SyncService>(), isA<HttpSyncService>());
    });

    test('registers SettingsViewModel when prefs repos provided', () async {
      SharedPreferences.setMockInitialValues({'pdpo_has_consented': true});
      final prefs = await SharedPreferences.getInstance();
      configureDependencies(
        consentRepository: ConsentRepository(prefs),
        appSettingsRepository: AppSettingsRepository(prefs),
        evidenceQueueRepository: FakeEvidenceQueueRepository(),
      );

      expect(getIt<SettingsViewModel>(), isA<SettingsViewModel>());
    });

    test('registers and resolves fake calibration service', () async {
      final fake = FakeCalibrationService(correctionFactor: 2.5);
      configureDependencies(calibrationService: fake);

      final resolved = getIt<CalibrationService>();
      expect(resolved, same(fake));
      expect(await resolved.getCorrectionFactor(), 2.5);
    });

    test('registers and resolves fake sync service', () async {
      final fake = FakeSyncService(
        summary: const SyncSummary(attempted: 1, succeeded: 1, failed: 0),
      );
      configureDependencies(syncService: fake);

      final resolved = getIt<SyncService>();
      expect(resolved, same(fake));
      final result = await resolved.syncPending();
      expect(result.succeeded, 1);
    });

    test('resetDependencies clears registrations', () async {
      configureDependencies();
      expect(getIt.isRegistered<CalibrationService>(), isTrue);

      await resetDependencies();
      expect(getIt.isRegistered<CalibrationService>(), isFalse);
      expect(getIt.isRegistered<SyncService>(), isFalse);
      expect(getIt.isRegistered<DebugLogService>(), isFalse);
    });
  });
}
