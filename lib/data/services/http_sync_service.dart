import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:noise_guardian/core/net/backoff_policy.dart';
import 'package:noise_guardian/data/repositories/evidence_queue_repository.dart';
import 'package:noise_guardian/data/services/sync_service.dart';
import 'package:noise_guardian/domain/models/sync_receipt.dart';
import 'package:noise_guardian/domain/models/sync_summary.dart';

/// HTTP sync to DoE REST API with exponential backoff (design doc §9.6).
class HttpSyncService implements SyncService {
  HttpSyncService({
    required http.Client client,
    required EvidenceQueueRepository queue,
    required String baseUrl,
    BackoffPolicy backoff = const BackoffPolicy(),
    Future<void> Function(Duration delay)? sleep,
  })  : _client = client,
        _queue = queue,
        _baseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl,
        _backoff = backoff,
        _sleep = sleep ?? ((duration) => Future<void>.delayed(duration));

  final http.Client _client;
  final EvidenceQueueRepository _queue;
  final String _baseUrl;
  final BackoffPolicy _backoff;
  final Future<void> Function(Duration delay) _sleep;

  bool get isEnabled => _baseUrl.isNotEmpty;

  @override
  Future<SyncSummary> syncPending() async {
    if (!isEnabled) {
      return SyncSummary.empty;
    }

    final pending = await _queue.pending();
    var succeeded = 0;
    var failed = 0;

    for (final item in pending) {
      await _queue.markSyncing(item.id);
      final ok = await _syncOne(item.id, item.packet.toJson());
      if (ok) {
        succeeded++;
      } else {
        failed++;
      }
    }

    return SyncSummary(
      attempted: pending.length,
      succeeded: succeeded,
      failed: failed,
    );
  }

  Future<bool> _syncOne(int id, Map<String, dynamic> body) async {
    var attempt = 0;

    while (true) {
      final response = await _client.post(
        Uri.parse('$_baseUrl/api/v1/evidence'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        final receipt = SyncReceipt.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
        await _queue.markSynced(id, receipt);
        return true;
      }

      if (response.statusCode >= 400 && response.statusCode < 500) {
        await _queue.markFailed(id);
        return false;
      }

      if (response.statusCode >= 500) {
        if (!_backoff.shouldRetry(attempt)) {
          await _queue.markFailed(id);
          return false;
        }
        await _queue.incrementAttempts(id);
        await _sleep(_backoff.delayFor(attempt));
        attempt++;
        continue;
      }

      await _queue.markFailed(id);
      return false;
    }
  }
}
