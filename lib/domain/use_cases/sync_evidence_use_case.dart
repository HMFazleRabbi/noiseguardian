import 'package:noise_guardian/data/repositories/app_settings_repository.dart';
import 'package:noise_guardian/data/services/connectivity_service.dart';
import 'package:noise_guardian/data/services/debug_log_service.dart';
import 'package:noise_guardian/data/services/sync_service.dart';
import 'package:noise_guardian/domain/models/sync_summary.dart';

/// Orchestrates portal sync for ViewModels (design doc §8).
class SyncEvidenceUseCase {
  const SyncEvidenceUseCase({
    required SyncService syncService,
    AppSettingsRepository? settings,
    ConnectivityService? connectivity,
    DebugLogService? debugLog,
  })  : _syncService = syncService,
        _settings = settings,
        _connectivity = connectivity,
        _debugLog = debugLog;

  final SyncService _syncService;
  final AppSettingsRepository? _settings;
  final ConnectivityService? _connectivity;
  final DebugLogService? _debugLog;

  Future<SyncSummary> execute() async {
    if (_settings?.lowDataMode == true && _connectivity != null) {
      final onWifi = await _connectivity.isOnWifi();
      if (!onWifi) {
        await _debugLog?.info(
          'sync',
          'Low-data mode: sync skipped (not on WiFi)',
        );
        return SyncSummary.empty;
      }
    }
    return _syncService.syncPending();
  }
}
