import 'dart:typed_data';

import 'package:noise_guardian/domain/models/evidence_packet.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Exports an evidence packet as a shareable PDF report.
class PdfExportService {
  const PdfExportService();

  Future<Uint8List> exportEvidencePdf(EvidencePacket packet) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'NoiseGuardian Evidence Report',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Text('LAeq: ${packet.metrics.laeqDb.toStringAsFixed(1)} dB(A)'),
            pw.Text('Noise class: ${packet.metrics.noiseClass}'),
            pw.Text('Violation: ${packet.metrics.isViolation}'),
            pw.SizedBox(height: 12),
            pw.Text(
              'Location: '
              '${packet.metadata.lat.toStringAsFixed(4)}, '
              '${packet.metadata.lon.toStringAsFixed(4)}',
            ),
            pw.Text('Zone: ${packet.metadata.zoneType}'),
            pw.Text('Timestamp: ${packet.metadata.timestampIso}'),
            pw.SizedBox(height: 12),
            pw.Text('Hash SHA-256: ${packet.security.hashSha256}'),
          ],
        ),
      ),
    );

    return doc.save();
  }
}
