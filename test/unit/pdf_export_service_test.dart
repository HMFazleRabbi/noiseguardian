import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/data/services/pdf_export_service.dart';
import '../fixtures/sample_evidence_packet.dart';

void main() {
  group('PdfExportService', () {
    test('generates non-empty PDF bytes', () async {
      const service = PdfExportService();
      final packet = sampleEvidencePacket();

      final bytes = await service.exportEvidencePdf(packet);

      expect(bytes, isNotEmpty);
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    });
  });
}
