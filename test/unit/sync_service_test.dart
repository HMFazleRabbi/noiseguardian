import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:noise_guardian/core/net/backoff_policy.dart';
import 'package:noise_guardian/data/services/http_sync_service.dart';
import 'package:noise_guardian/domain/models/queue_status.dart';
import '../fakes/fake_evidence_queue_repository.dart';
import '../fixtures/evidence_packet_fixtures.dart';

void main() {
  group('HttpSyncService', () {
    late FakeEvidenceQueueRepository queue;

    setUp(() async {
      queue = FakeEvidenceQueueRepository();
      await queue.init();
    });

    test('201 persists receipt and marks synced', () async {
      await queue.enqueue(sampleEvidencePacket());
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'receipt_id': 'DOE-DHK-2026-001',
            'server_signature': 'server-sig',
          }),
          201,
        );
      });
      final service = HttpSyncService(
        client: client,
        queue: queue,
        baseUrl: 'https://doe.example.com',
      );

      final summary = await service.syncPending();

      expect(summary.attempted, 1);
      expect(summary.succeeded, 1);
      expect(summary.successRate, 1.0);
      final rows = await queue.all();
      expect(rows.single.status, QueueStatus.synced);
      expect(rows.single.receiptId, 'DOE-DHK-2026-001');
    });

    test('5xx retries then marks failed', () async {
      await queue.enqueue(sampleEvidencePacket());
      var calls = 0;
      final client = MockClient((request) async {
        calls++;
        return http.Response('error', 503);
      });
      final service = HttpSyncService(
        client: client,
        queue: queue,
        baseUrl: 'https://doe.example.com',
        backoff: const BackoffPolicy(maxAttempts: 1),
        sleep: (_) async {},
      );

      final summary = await service.syncPending();

      expect(calls, 2);
      expect(summary.failed, 1);
      final row = (await queue.all()).single;
      expect(row.status, QueueStatus.failed);
      expect(row.attempts, greaterThanOrEqualTo(1));
    });

    test('4xx marks failed without retry', () async {
      await queue.enqueue(sampleEvidencePacket());
      var calls = 0;
      final client = MockClient((request) async {
        calls++;
        return http.Response('bad request', 400);
      });
      final service = HttpSyncService(
        client: client,
        queue: queue,
        baseUrl: 'https://doe.example.com',
      );

      await service.syncPending();

      expect(calls, 1);
      expect((await queue.all()).single.status, QueueStatus.failed);
    });

    test('empty baseUrl returns zero attempted', () async {
      await queue.enqueue(sampleEvidencePacket());
      final service = HttpSyncService(
        client: MockClient((_) async => http.Response('', 201)),
        queue: queue,
        baseUrl: '',
      );
      final summary = await service.syncPending();
      expect(summary.attempted, 0);
    });
  });
}
