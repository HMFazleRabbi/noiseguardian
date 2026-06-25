import 'package:noise_guardian/data/models/queued_evidence.dart';
import 'package:noise_guardian/data/repositories/evidence_queue_repository.dart';
import 'package:noise_guardian/domain/models/evidence_packet.dart';
import 'package:noise_guardian/domain/models/queue_status.dart';
import 'package:noise_guardian/domain/models/sync_receipt.dart';

class FakeEvidenceQueueRepository implements EvidenceQueueRepository {
  final List<QueuedEvidence> items = [];
  var nextId = 1;

  @override
  Future<void> init() async {}

  @override
  Future<int> enqueue(EvidencePacket packet) async {
    final id = nextId++;
    final now = DateTime.now();
    items.add(
      QueuedEvidence(
        id: id,
        packet: packet,
        status: QueueStatus.pending,
        attempts: 0,
        createdAt: now,
        updatedAt: now,
      ),
    );
    return id;
  }

  @override
  Future<List<QueuedEvidence>> pending() async {
    return items.where((i) => i.status == QueueStatus.pending).toList();
  }

  @override
  Future<List<QueuedEvidence>> all() async => List.of(items);

  @override
  Future<QueuedEvidence?> getById(int id) async {
    for (final item in items) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<void> markSyncing(int id) async {
    _update(id, (item) => item.copyWith(status: QueueStatus.syncing));
  }

  @override
  Future<void> markSynced(int id, SyncReceipt receipt) async {
    _update(
      id,
      (item) => item.copyWith(
        status: QueueStatus.synced,
        receiptId: receipt.receiptId,
        serverSignature: receipt.serverSignatureEcdsa,
      ),
    );
  }

  @override
  Future<void> markFailed(int id) async {
    _update(id, (item) => item.copyWith(status: QueueStatus.failed));
  }

  @override
  Future<void> incrementAttempts(int id) async {
    _update(id, (item) => item.copyWith(attempts: item.attempts + 1));
  }

  @override
  Future<List<EvidencePacket>> syncedPackets() async {
    return items
        .where((i) => i.status == QueueStatus.synced)
        .map((i) => i.packet)
        .toList();
  }

  void _update(int id, QueuedEvidence Function(QueuedEvidence item) transform) {
    for (var i = 0; i < items.length; i++) {
      if (items[i].id == id) {
        items[i] = transform(items[i]);
        return;
      }
    }
    throw StateError('Queue row not found: $id');
  }
}
