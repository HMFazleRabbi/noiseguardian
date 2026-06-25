import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/data/services/local_mock_doe_sync_service.dart';
import 'package:noise_guardian/domain/models/evidence_packet.dart';
import 'package:noise_guardian/domain/models/queue_status.dart';
import '../fakes/fake_evidence_queue_repository.dart';
import '../fixtures/sample_evidence_packet.dart';

void main() {
  group('LocalMockDoeSyncService', () {
    late FakeEvidenceQueueRepository queue;

    setUp(() async {
      LocalMockDoeSyncService.resetReceiptCounterForTests();
      queue = FakeEvidenceQueueRepository();
      await queue.init();
    });

    test('sync marks valid packet synced with receipt format', () async {
      await queue.enqueue(sampleEvidencePacket());
      final service = LocalMockDoeSyncService(
        queue: queue,
        now: () => DateTime(2026, 6, 26),
      );

      final summary = await service.syncPending();

      expect(summary.attempted, 1);
      expect(summary.succeeded, 1);
      expect(summary.successRate, 1.0);
      final row = (await queue.all()).single;
      expect(row.status, QueueStatus.synced);
      expect(row.receiptId, matches(RegExp(r'^#DOE-DHK-20260626-\d{4}$')));
      expect(row.serverSignature, isNotEmpty);
    });

    test('invalid packet marks failed', () async {
      final invalid = EvidencePacket(
        metrics: sampleEvidencePacket().metrics,
        metadata: EvidenceMetadata(
          lat: 23.81,
          lon: 90.41,
          latObfuscated: 0,
          lonObfuscated: 0,
          gpsAccuracyM: 12,
          gpsDop: 1.2,
          gpsHash: 'x',
          timestampIso: '2026-06-26T00:00:00.000Z',
          timestampToken: 't',
          deviceIdHash: 'd',
          appVersion: '1.0',
          zoneType: 'residential',
        ),
        security: const EvidenceSecurity(
          hashSha256: '',
          signatureEcdsa: '',
        ),
      );
      await queue.enqueue(invalid);

      final service = LocalMockDoeSyncService(queue: queue);
      final summary = await service.syncPending();

      expect(summary.failed, 1);
      expect(summary.succeeded, 0);
    });

    test('successRate meets 75% fixture threshold', () async {
      for (var i = 0; i < 4; i++) {
        await queue.enqueue(sampleEvidencePacket(noiseClass: 'traffic'));
      }
      final service = LocalMockDoeSyncService(queue: queue);
      final summary = await service.syncPending();
      expect(summary.successRate, greaterThanOrEqualTo(0.75));
    });
  });
}
