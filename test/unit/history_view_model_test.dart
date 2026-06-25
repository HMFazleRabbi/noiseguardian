import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/domain/models/queue_status.dart';
import 'package:noise_guardian/domain/models/sync_receipt.dart';
import 'package:noise_guardian/domain/models/sync_summary.dart';
import 'package:noise_guardian/domain/use_cases/sync_evidence_use_case.dart';
import 'package:noise_guardian/ui/features/history/view_models/history_view_model.dart';
import '../fakes/fake_evidence_queue_repository.dart';
import '../fakes/fake_sync_service.dart';
import '../fixtures/evidence_packet_fixtures.dart';

void main() {
  group('HistoryViewModel', () {
    test('load exposes queued items', () async {
      final queue = FakeEvidenceQueueRepository();
      await queue.enqueue(sampleEvidencePacket());
      final vm = HistoryViewModel(
        queue: queue,
        syncEvidence: SyncEvidenceUseCase(
          syncService: FakeSyncService(),
        ),
      );

      await vm.load();

      expect(vm.items, hasLength(1));
      expect(vm.items.single.status, QueueStatus.pending);
    });

    test('sync refreshes items with receipt', () async {
      final queue = FakeEvidenceQueueRepository();
      final id = await queue.enqueue(sampleEvidencePacket());
      final sync = FakeSyncService(
        summary: const SyncSummary(attempted: 1, succeeded: 1, failed: 0),
      );
      final vm = HistoryViewModel(
        queue: queue,
        syncEvidence: SyncEvidenceUseCase(syncService: sync),
      );
      await queue.markSynced(
        id,
        const SyncReceipt(
          receiptId: 'DOE-001',
          serverSignatureEcdsa: 'sig',
        ),
      );

      await vm.sync();

      expect(sync.syncCallCount, 1);
      expect(vm.lastSyncSummary?.succeeded, 1);
    });
  });
}
