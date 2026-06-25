import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/data/services/connectivity_service.dart';
import 'package:noise_guardian/data/services/local_mock_doe_sync_service.dart';
import 'package:noise_guardian/domain/models/queue_status.dart';
import 'package:noise_guardian/domain/models/sync_summary.dart';
import 'package:noise_guardian/domain/use_cases/sync_evidence_use_case.dart';
import '../fakes/fake_app_settings_repository.dart';
import '../fakes/fake_evidence_queue_repository.dart';
import '../fixtures/sample_evidence_packet.dart';

void main() {
  group('SyncEvidenceUseCase low-data gate', () {
    test('blocks sync on cellular when lowDataMode enabled', () async {
      final queue = FakeEvidenceQueueRepository();
      await queue.init();
      await queue.enqueue(sampleEvidencePacket());

      final settings = FakeAppSettingsRepository(lowDataMode: true);
      final sync = LocalMockDoeSyncService(queue: queue);
      final useCase = SyncEvidenceUseCase(
        syncService: sync,
        settings: settings,
        connectivity: const CellularOnlyConnectivityService(),
      );

      final summary = await useCase.execute();

      expect(summary, SyncSummary.empty);
      expect((await queue.all()).single.status, QueueStatus.pending);
    });

    test('allows sync on WiFi when lowDataMode enabled', () async {
      final queue = FakeEvidenceQueueRepository();
      await queue.init();
      await queue.enqueue(sampleEvidencePacket());

      final settings = FakeAppSettingsRepository(lowDataMode: true);
      final sync = LocalMockDoeSyncService(queue: queue);
      final useCase = SyncEvidenceUseCase(
        syncService: sync,
        settings: settings,
        connectivity: const AlwaysWifiConnectivityService(),
      );

      final summary = await useCase.execute();

      expect(summary.succeeded, 1);
    });
  });
}
