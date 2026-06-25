import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/data/repositories/app_settings_repository.dart';
import 'package:noise_guardian/data/repositories/consent_repository.dart';
import 'package:noise_guardian/data/repositories/report_repository.dart';
import 'package:noise_guardian/data/services/calibration_service.dart';
import 'package:noise_guardian/data/services/debug_log_service.dart';
import 'package:noise_guardian/data/services/geolocator_gps_service.dart';
import 'package:noise_guardian/data/services/gps_service.dart';
import 'package:noise_guardian/data/services/pdf_export_service.dart';
import 'package:noise_guardian/data/services/timestamp_service.dart';
import 'package:noise_guardian/data/services/violation_evaluator.dart';
import 'package:noise_guardian/data/services/zone_threshold_service.dart';
import 'package:noise_guardian/di/service_locator.dart';
import 'package:noise_guardian/domain/use_cases/build_evidence_packet_use_case.dart';
import 'package:noise_guardian/ui/features/reports/view_models/reports_view_model.dart';
import 'package:noise_guardian/ui/features/settings/view_models/settings_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../fakes/fake_calibration_service.dart';
import '../fakes/fake_report_repository.dart';

void main() {
  group('ServiceLocator', () {
    tearDown(() async {
      await resetDependencies();
    });

    test('registers and resolves stub services by default', () {
      configureDependencies(deviceInstallId: 'test-device');

      expect(getIt<CalibrationService>(), isA<StubCalibrationService>());
      expect(getIt<DebugLogService>(), isA<NoopDebugLogService>());
      expect(getIt<PdfExportService>(), isA<PdfExportService>());
      expect(getIt<ReportRepository>(), isA<InMemoryReportRepository>());
      expect(getIt<ZoneThresholdService>(), isA<ZoneThresholdService>());
      expect(getIt<ViolationEvaluator>(), isA<ViolationEvaluator>());
      expect(getIt<TimestampService>(), isA<LocalTimestampService>());
      expect(getIt<GpsService>(), isA<GeolocatorGpsService>());
      expect(getIt<BuildEvidencePacketUseCase>(), isA<BuildEvidencePacketUseCase>());
    });

    test('registers ReportsViewModel when report repo provided', () {
      final reports = FakeReportRepository();
      configureDependencies(
        deviceInstallId: 'test-device',
        reportRepository: reports,
      );

      expect(getIt<ReportRepository>(), same(reports));
      expect(getIt<ReportsViewModel>(), isA<ReportsViewModel>());
    });

    test('registers SettingsViewModel when consent repo provided', () async {
      SharedPreferences.setMockInitialValues({'pdpo_has_consented': true});
      final prefs = await SharedPreferences.getInstance();
      configureDependencies(
        consentRepository: ConsentRepository(prefs),
        reportRepository: FakeReportRepository(),
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

    test('resetDependencies clears registrations', () async {
      configureDependencies();
      expect(getIt.isRegistered<CalibrationService>(), isTrue);

      await resetDependencies();
      expect(getIt.isRegistered<CalibrationService>(), isFalse);
      expect(getIt.isRegistered<ReportRepository>(), isFalse);
      expect(getIt.isRegistered<DebugLogService>(), isFalse);
    });
  });
}
