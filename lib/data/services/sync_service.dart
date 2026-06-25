/// DoE portal sync (Module E). Stub until Stage 5.
abstract class SyncService {
  Future<bool> syncPending();
}

class StubSyncService implements SyncService {
  const StubSyncService();

  @override
  Future<bool> syncPending() async => false;
}
