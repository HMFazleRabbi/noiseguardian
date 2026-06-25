import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/data/repositories/evidence_queue_repository.dart';
import 'package:noise_guardian/data/services/encryption_service.dart';
import 'package:noise_guardian/domain/models/sync_receipt.dart';
import 'package:noise_guardian/ui/features/heatmap/view_models/heatmap_view_model.dart';

import '../fixtures/sample_evidence_packet.dart';

void main() {
  group('HeatmapViewModel', () {
    test('load aggregates synced packets only', () async {
      final queue = InMemoryEvidenceQueueRepository(
        encryption: InMemoryEncryptionService(),
      );
      await queue.enqueue(sampleEvidencePacket(laeqDb: 40));
      final syncedId = await queue.enqueue(sampleEvidencePacket(laeqDb: 65));
      await queue.markSynced(
        syncedId,
        const SyncReceipt(receiptId: 'R1', serverSignatureEcdsa: 'sig'),
      );

      final vm = HeatmapViewModel(queue: queue);
      await vm.load();

      expect(vm.cells, hasLength(1));
      expect(vm.cells.first.count, 1);
      expect(vm.cells.first.avgLaeqDb, 65.0);
    });
  });
}
