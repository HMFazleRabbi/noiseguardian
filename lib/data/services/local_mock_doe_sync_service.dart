import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:noise_guardian/data/repositories/evidence_queue_repository.dart';
import 'package:noise_guardian/data/services/sync_service.dart';
import 'package:noise_guardian/domain/models/evidence_packet.dart';
import 'package:noise_guardian/domain/models/sync_receipt.dart';
import 'package:noise_guardian/domain/models/sync_summary.dart';

/// In-process Mock DoE portal — validates packets and issues receipts offline.
class LocalMockDoeSyncService implements SyncService {
  LocalMockDoeSyncService({
    required EvidenceQueueRepository queue,
    double failureRate = 0.0,
    Random? random,
    DateTime Function()? now,
  })  : _queue = queue,
        _failureRate = failureRate.clamp(0.0, 1.0),
        _random = random ?? Random(),
        _now = now ?? DateTime.now;

  final EvidenceQueueRepository _queue;
  final double _failureRate;
  final Random _random;
  final DateTime Function() _now;

  static int _receiptCounter = 0;
  static String? _lastReceiptDate;

  @override
  Future<SyncSummary> syncPending() async {
    final pending = await _queue.pending();
    var succeeded = 0;
    var failed = 0;

    for (final item in pending) {
      await _queue.markSyncing(item.id);

      if (!_isValidPacket(item.packet)) {
        await _queue.markFailed(item.id);
        failed++;
        continue;
      }

      if (_failureRate > 0 && _random.nextDouble() < _failureRate) {
        await _queue.markFailed(item.id);
        failed++;
        continue;
      }

      final receipt = _issueReceipt(item.packet);
      await _queue.markSynced(item.id, receipt);
      succeeded++;
    }

    return SyncSummary(
      attempted: pending.length,
      succeeded: succeeded,
      failed: failed,
    );
  }

  static bool _isValidPacket(EvidencePacket packet) {
    final security = packet.security;
    final metadata = packet.metadata;
    if (security.hashSha256.isEmpty || security.signatureEcdsa.isEmpty) {
      return false;
    }
    if (metadata.latObfuscated == 0 && metadata.lonObfuscated == 0) {
      return false;
    }
    return true;
  }

  SyncReceipt _issueReceipt(EvidencePacket packet) {
    final receiptId = _nextReceiptId();
    final serverSignature = _mockServerSignature(receiptId, packet.security.hashSha256);
    return SyncReceipt(
      receiptId: receiptId,
      serverSignatureEcdsa: serverSignature,
    );
  }

  String _nextReceiptId() {
    final today = _formatDate(_now());
    if (_lastReceiptDate != today) {
      _lastReceiptDate = today;
      _receiptCounter = 0;
    }
    _receiptCounter++;
    final seq = _receiptCounter.toString().padLeft(4, '0');
    return '#DOE-DHK-$today-$seq';
  }

  static String _formatDate(DateTime dt) {
    final y = dt.year.toString();
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y$m$d';
  }

  static String _mockServerSignature(String receiptId, String hashSha256) {
    final bytes = utf8.encode('$receiptId:$hashSha256:mock-doe');
    return sha256.convert(bytes).toString();
  }

  /// Visible for tests — resets monotonic receipt counter.
  static void resetReceiptCounterForTests() {
    _receiptCounter = 0;
    _lastReceiptDate = null;
  }
}
