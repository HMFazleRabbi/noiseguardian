import 'dart:convert';

import 'package:noise_guardian/data/models/queued_evidence.dart';
import 'package:noise_guardian/data/services/encryption_service.dart';
import 'package:noise_guardian/domain/models/evidence_packet.dart';
import 'package:noise_guardian/domain/models/queue_status.dart';
import 'package:noise_guardian/domain/models/sync_receipt.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Offline-first encrypted evidence queue (design doc §9.6).
abstract class EvidenceQueueRepository {
  Future<void> init();
  Future<int> enqueue(EvidencePacket packet);
  Future<List<QueuedEvidence>> pending();
  Future<List<QueuedEvidence>> all();
  Future<QueuedEvidence?> getById(int id);
  Future<void> markSyncing(int id);
  Future<void> markSynced(int id, SyncReceipt receipt);
  Future<void> markFailed(int id);
  Future<void> incrementAttempts(int id);
  Future<List<EvidencePacket>> syncedPackets();
}

class InMemoryEvidenceQueueRepository implements EvidenceQueueRepository {
  InMemoryEvidenceQueueRepository({required EncryptionService encryption})
      : _encryption = encryption;

  final EncryptionService _encryption;
  final List<QueuedEvidence> _rows = [];
  int _nextId = 1;
  final Map<int, String> _encryptedBlobs = {};

  @override
  Future<void> init() async {}

  @override
  Future<int> enqueue(EvidencePacket packet) async {
    final id = _nextId++;
    final now = DateTime.now();
    final plaintext = QueuedEvidence.packetToJson(packet);
    _encryptedBlobs[id] = await _encryption.encrypt(plaintext);
    _rows.add(
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
  Future<List<QueuedEvidence>> pending() async =>
      _rows.where((r) => r.status == QueueStatus.pending).toList();

  @override
  Future<List<QueuedEvidence>> all() async => List.unmodifiable(_rows);

  @override
  Future<QueuedEvidence?> getById(int id) async {
    try {
      return _rows.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> markSyncing(int id) async => _update(id, QueueStatus.syncing);

  @override
  Future<void> markSynced(int id, SyncReceipt receipt) async {
    final index = _rows.indexWhere((r) => r.id == id);
    if (index < 0) {
      return;
    }
    _rows[index] = _rows[index].copyWith(
      status: QueueStatus.synced,
      receiptId: receipt.receiptId,
      serverSignature: receipt.serverSignatureEcdsa,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> markFailed(int id) async => _update(id, QueueStatus.failed);

  @override
  Future<void> incrementAttempts(int id) async {
    final index = _rows.indexWhere((r) => r.id == id);
    if (index < 0) {
      return;
    }
    _rows[index] = _rows[index].copyWith(
      attempts: _rows[index].attempts + 1,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<List<EvidencePacket>> syncedPackets() async {
    return _rows
        .where((r) => r.status == QueueStatus.synced)
        .map((r) => r.packet)
        .toList();
  }

  String? encryptedBlobFor(int id) => _encryptedBlobs[id];

  void _update(int id, QueueStatus status) {
    final index = _rows.indexWhere((r) => r.id == id);
    if (index < 0) {
      return;
    }
    _rows[index] = _rows[index].copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );
  }
}

class SqfliteEvidenceQueueRepository implements EvidenceQueueRepository {
  SqfliteEvidenceQueueRepository({required EncryptionService encryption})
      : _encryption = encryption;

  final EncryptionService _encryption;
  Database? _db;

  static const String _table = 'evidence_queue';

  @override
  Future<void> init() async {
    if (_db != null) {
      return;
    }
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'evidence_queue.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            encrypted_packet TEXT NOT NULL,
            status TEXT NOT NULL,
            attempts INTEGER NOT NULL DEFAULT 0,
            receipt_id TEXT,
            server_signature TEXT,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Database get _database {
    final db = _db;
    if (db == null) {
      throw StateError('EvidenceQueueRepository not initialized');
    }
    return db;
  }

  @override
  Future<int> enqueue(EvidencePacket packet) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final encrypted = await _encryption.encrypt(QueuedEvidence.packetToJson(packet));
    return _database.insert(
      _table,
      {
        'encrypted_packet': encrypted,
        'status': QueueStatus.pending.wireName,
        'attempts': 0,
        'created_at': now,
        'updated_at': now,
      },
    );
  }

  @override
  Future<List<QueuedEvidence>> pending() async {
    final rows = await _database.query(
      _table,
      where: 'status = ?',
      whereArgs: [QueueStatus.pending.wireName],
      orderBy: 'created_at ASC',
    );
    return _rowsToQueued(rows);
  }

  @override
  Future<List<QueuedEvidence>> all() async {
    final rows = await _database.query(_table, orderBy: 'created_at DESC');
    return _rowsToQueued(rows);
  }

  @override
  Future<QueuedEvidence?> getById(int id) async {
    final rows = await _database.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    final list = await _rowsToQueued(rows);
    return list.first;
  }

  @override
  Future<void> markSyncing(int id) async => _setStatus(id, QueueStatus.syncing);

  @override
  Future<void> markSynced(int id, SyncReceipt receipt) async {
    await _database.update(
      _table,
      {
        'status': QueueStatus.synced.wireName,
        'receipt_id': receipt.receiptId,
        'server_signature': receipt.serverSignatureEcdsa,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> markFailed(int id) async => _setStatus(id, QueueStatus.failed);

  @override
  Future<void> incrementAttempts(int id) async {
    await _database.rawUpdate(
      'UPDATE $_table SET attempts = attempts + 1, updated_at = ? WHERE id = ?',
      [DateTime.now().millisecondsSinceEpoch, id],
    );
  }

  @override
  Future<List<EvidencePacket>> syncedPackets() async {
    final rows = await _database.query(
      _table,
      where: 'status = ?',
      whereArgs: [QueueStatus.synced.wireName],
    );
    final queued = await _rowsToQueued(rows);
    return queued.map((q) => q.packet).toList();
  }

  Future<void> _setStatus(int id, QueueStatus status) async {
    await _database.update(
      _table,
      {
        'status': status.wireName,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<QueuedEvidence>> _rowsToQueued(List<Map<String, Object?>> rows) async {
    final result = <QueuedEvidence>[];
    for (final row in rows) {
      final encrypted = row['encrypted_packet'] as String;
      final plaintext = await _encryption.decrypt(encrypted);
      final packet = EvidencePacket.fromJson(
        jsonDecode(plaintext) as Map<String, dynamic>,
      );
      result.add(
        QueuedEvidence.fromRow(
          Map<String, dynamic>.from(row),
          packet,
        ),
      );
    }
    return result;
  }
}
