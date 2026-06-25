import 'package:noise_guardian/domain/models/sync_summary.dart';

/// DoE portal sync (Module E).
abstract class SyncService {
  Future<SyncSummary> syncPending();
}

/// No-op sync when portal URL is not configured.
class DisabledSyncService implements SyncService {
  const DisabledSyncService();

  @override
  Future<SyncSummary> syncPending() async => SyncSummary.empty;
}
