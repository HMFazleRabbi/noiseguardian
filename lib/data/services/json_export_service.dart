import 'dart:convert';

import 'package:noise_guardian/domain/models/evidence_packet.dart';

/// Serializes evidence packets to shareable JSON.
class JsonExportService {
  const JsonExportService();

  String exportEvidenceJson(EvidencePacket packet) {
    return const JsonEncoder.withIndent('  ').convert(packet.toJson());
  }
}
