import 'package:noise_guardian/data/services/sync_service.dart';
import 'package:noise_guardian/domain/models/sync_summary.dart';

class FakeSyncService implements SyncService {
  FakeSyncService({this.summary = SyncSummary.empty});

  SyncSummary summary;
  int syncCallCount = 0;

  @override
  Future<SyncSummary> syncPending() async {
    syncCallCount++;
    return summary;
  }
}
