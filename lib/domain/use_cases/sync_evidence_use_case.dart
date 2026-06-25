import 'package:noise_guardian/data/services/sync_service.dart';
import 'package:noise_guardian/domain/models/sync_summary.dart';

/// Orchestrates portal sync for ViewModels (design doc §8).
class SyncEvidenceUseCase {
  const SyncEvidenceUseCase({required SyncService syncService})
      : _syncService = syncService;

  final SyncService _syncService;

  Future<SyncSummary> execute() => _syncService.syncPending();
}
