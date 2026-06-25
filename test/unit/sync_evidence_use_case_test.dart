import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/data/services/local_mock_doe_sync_service.dart';
import 'package:noise_guardian/domain/models/queue_status.dart';
import 'package:noise_guardian/domain/use_cases/sync_evidence_use_case.dart';
import '../fakes/fake_evidence_queue_repository.dart';
import '../fixtures/sample_evidence_packet.dart';

void main() {
  group('SyncEvidenceUseCase', () {
    test('delegates to syncService.syncPending', () async {
      final queue = FakeEvidenceQueueRepository();
      await queue.init();
      await queue.enqueue(sampleEvidencePacket());

      final sync = LocalMockDoeSyncService(queue: queue);
      final useCase = SyncEvidenceUseCase(syncService: sync);

      final summary = await useCase.execute();

      expect(summary.succeeded, 1);
      expect((await queue.all()).single.status, QueueStatus.synced);
    });
  });
}
