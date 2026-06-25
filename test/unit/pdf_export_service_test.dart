import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/data/models/queued_evidence.dart';
import 'package:noise_guardian/data/services/pdf_export_service.dart';
import 'package:noise_guardian/domain/models/queue_status.dart';
import '../fixtures/sample_evidence_packet.dart';

void main() {
  group('PdfExportService', () {
    test('generates non-empty PDF bytes', () async {
      const service = PdfExportService();
      final evidence = QueuedEvidence(
        id: 1,
        packet: sampleEvidencePacket(),
        status: QueueStatus.synced,
        attempts: 0,
        receiptId: 'DOE-DHK-20260626-0001',
        serverSignature: 'mock-sig',
        createdAt: DateTime(2026, 6, 26),
        updatedAt: DateTime(2026, 6, 26),
      );

      final bytes = await service.exportEvidencePdf(evidence);

      expect(bytes, isNotEmpty);
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    });
  });
}
