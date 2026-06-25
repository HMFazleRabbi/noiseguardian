import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/data/services/json_export_service.dart';
import '../fixtures/sample_evidence_packet.dart';

void main() {
  group('JsonExportService', () {
    test('exportEvidenceJson round-trips packet fields', () {
      const service = JsonExportService();
      final packet = sampleEvidencePacket();
      final json = service.exportEvidenceJson(packet);
      final decoded = jsonDecode(json) as Map<String, dynamic>;

      expect(decoded['metrics']['laeq_db'], packet.metrics.laeqDb);
      expect(decoded['security']['hash_sha256'], packet.security.hashSha256);
      expect(json, isNot(contains('signature_ecdsa')));
    });
  });
}
