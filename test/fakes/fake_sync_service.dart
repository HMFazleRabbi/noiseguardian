import 'package:noise_guardian/data/services/sync_service.dart';

class FakeSyncService implements SyncService {
  FakeSyncService({this.syncResult = false});

  bool syncResult;
  int syncCallCount = 0;

  @override
  Future<bool> syncPending() async {
    syncCallCount++;
    return syncResult;
  }
}
