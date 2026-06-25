import 'dart:convert';

import 'package:noise_guardian/domain/models/evidence_packet.dart';
import 'package:noise_guardian/domain/models/queue_status.dart';

/// A queued evidence row with sync metadata.
class QueuedEvidence {
  const QueuedEvidence({
    required this.id,
    required this.packet,
    required this.status,
    required this.attempts,
    required this.createdAt,
    required this.updatedAt,
    this.receiptId,
    this.serverSignature,
  });

  final int id;
  final EvidencePacket packet;
  final QueueStatus status;
  final int attempts;
  final String? receiptId;
  final String? serverSignature;
  final DateTime createdAt;
  final DateTime updatedAt;

  QueuedEvidence copyWith({
    QueueStatus? status,
    int? attempts,
    String? receiptId,
    String? serverSignature,
    DateTime? updatedAt,
  }) {
    return QueuedEvidence(
      id: id,
      packet: packet,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      receiptId: receiptId ?? this.receiptId,
      serverSignature: serverSignature ?? this.serverSignature,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static String packetToJson(EvidencePacket packet) =>
      jsonEncode(packet.toJson());

  static QueuedEvidence fromRow(
    Map<String, Object?> row,
    EvidencePacket packet,
  ) {
    return QueuedEvidence(
      id: row['id']! as int,
      packet: packet,
      status: QueueStatus.fromWire(row['status']! as String),
      attempts: row['attempts']! as int,
      receiptId: row['receipt_id'] as String?,
      serverSignature: row['server_signature'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at']! as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row['updated_at']! as int),
    );
  }
}
