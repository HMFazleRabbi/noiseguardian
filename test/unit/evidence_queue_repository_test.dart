import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/data/repositories/evidence_queue_repository.dart';
import 'package:noise_guardian/data/services/encryption_service.dart';
import 'package:noise_guardian/domain/models/queue_status.dart';
import 'package:noise_guardian/domain/models/sync_receipt.dart';

import '../fixtures/sample_evidence_packet.dart';

void main() {
  group('InMemoryEvidenceQueueRepository', () {
    late InMemoryEncryptionService encryption;
    late InMemoryEvidenceQueueRepository repo;

    setUp(() {
      encryption = InMemoryEncryptionService();
      repo = InMemoryEvidenceQueueRepository(encryption: encryption);
    });

    test('enqueue stores encrypted blob not plaintext JSON', () async {
      final packet = sampleEvidencePacket();
      final id = await repo.enqueue(packet);
      final blob = repo.encryptedBlobFor(id)!;
      final plaintext = jsonEncode(packet.toJson());

      expect(blob, isNot(contains('"laeq_db"')));
      expect(blob, isNot(equals(plaintext)));
    });

    test('decrypt round-trip is lossless', () async {
      final packet = sampleEvidencePacket(laeqDb: 61.5);
      final id = await repo.enqueue(packet);
      final row = await repo.getById(id);

      expect(row!.packet.metrics.laeqDb, 61.5);
      expect(row.status, QueueStatus.pending);
    });

    test('pending and status transitions', () async {
      final id = await repo.enqueue(sampleEvidencePacket());
      expect((await repo.pending()).length, 1);

      await repo.markSyncing(id);
      expect((await repo.pending()).length, 0);

      await repo.markSynced(
        id,
        const SyncReceipt(
          receiptId: 'DOE-001',
          serverSignatureEcdsa: 'srv-sig',
        ),
      );
      final synced = await repo.getById(id);
      expect(synced!.status, QueueStatus.synced);
      expect(synced.receiptId, 'DOE-001');
    });

    test('markFailed and incrementAttempts', () async {
      final id = await repo.enqueue(sampleEvidencePacket());
      await repo.incrementAttempts(id);
      await repo.markFailed(id);
      final row = await repo.getById(id);
      expect(row!.attempts, 1);
      expect(row.status, QueueStatus.failed);
    });
  });
}
