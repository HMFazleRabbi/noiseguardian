import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/data/services/calibration_service.dart';
import 'package:noise_guardian/data/services/debug_log_service.dart';
import 'package:noise_guardian/data/services/sync_service.dart';
import 'package:noise_guardian/di/service_locator.dart';
import '../fakes/fake_calibration_service.dart';
import '../fakes/fake_sync_service.dart';

void main() {
  group('ServiceLocator', () {
    tearDown(() async {
      await resetDependencies();
    });

    test('registers and resolves stub services by default', () {
      configureDependencies();

      expect(getIt<CalibrationService>(), isA<StubCalibrationService>());
      expect(getIt<SyncService>(), isA<StubSyncService>());
      expect(getIt<DebugLogService>(), isA<NoopDebugLogService>());
    });

    test('registers and resolves fake calibration service', () async {
      final fake = FakeCalibrationService(correctionFactor: 2.5);
      configureDependencies(calibrationService: fake);

      final resolved = getIt<CalibrationService>();
      expect(resolved, same(fake));
      expect(await resolved.getCorrectionFactor(), 2.5);
    });

    test('registers and resolves fake sync service', () async {
      final fake = FakeSyncService(syncResult: true);
      configureDependencies(syncService: fake);

      final resolved = getIt<SyncService>();
      expect(resolved, same(fake));
      expect(await resolved.syncPending(), isTrue);
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
