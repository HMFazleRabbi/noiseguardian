import 'package:noise_guardian/domain/models/evidence_packet.dart';

/// A locally persisted evidence packet (MVP Stage 4).
class SavedReport {
  const SavedReport({
    required this.id,
    required this.savedAt,
    required this.packet,
  });

  final String id;
  final DateTime savedAt;
  final EvidencePacket packet;
}
