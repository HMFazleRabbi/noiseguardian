import 'package:get_it/get_it.dart';
import 'package:noise_guardian/data/services/calibration_service.dart';
import 'package:noise_guardian/data/services/debug_log_service.dart';
import 'package:noise_guardian/data/services/sync_service.dart';

final GetIt getIt = GetIt.instance;

/// Registers application dependencies. Pass fakes in tests via [overrides].
void configureDependencies({
  CalibrationService? calibrationService,
  SyncService? syncService,
  DebugLogService? debugLogService,
}) {
  _unregisterIfNeeded<CalibrationService>();
  _unregisterIfNeeded<SyncService>();
  _unregisterIfNeeded<DebugLogService>();

  getIt.registerLazySingleton<CalibrationService>(
    () => calibrationService ?? StubCalibrationService(),
  );
  getIt.registerLazySingleton<SyncService>(
    () => syncService ?? StubSyncService(),
  );
  getIt.registerLazySingleton<DebugLogService>(
    () => debugLogService ?? NoopDebugLogService(),
  );
}

Future<void> resetDependencies() async {
  if (getIt.isRegistered<DebugLogService>()) {
    await getIt<DebugLogService>().dispose();
  }
  _unregisterIfNeeded<CalibrationService>();
  _unregisterIfNeeded<SyncService>();
  _unregisterIfNeeded<DebugLogService>();
}

void _unregisterIfNeeded<T extends Object>() {
  if (getIt.isRegistered<T>()) {
    getIt.unregister<T>();
  }
}
