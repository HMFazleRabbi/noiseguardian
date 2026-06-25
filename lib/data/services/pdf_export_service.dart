import 'dart:typed_data';

import 'package:noise_guardian/data/models/queued_evidence.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Exports a queued evidence row as a shareable PDF receipt (design doc §12).
class PdfExportService {
  const PdfExportService();

  Future<Uint8List> exportEvidencePdf(QueuedEvidence evidence) async {
    final packet = evidence.packet;
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'NoiseGuardian Evidence Receipt',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 16),
            if (evidence.receiptId != null)
              pw.Text('Receipt ID: ${evidence.receiptId}'),
            pw.Text('Status: ${evidence.status.wireName}'),
            pw.SizedBox(height: 12),
            pw.Text('LAeq: ${packet.metrics.laeqDb.toStringAsFixed(1)} dB(A)'),
            pw.Text('Noise class: ${packet.metrics.noiseClass}'),
            pw.Text('Violation: ${packet.metrics.isViolation}'),
            pw.SizedBox(height: 12),
            pw.Text(
              'Location (obfuscated): '
              '${packet.metadata.latObfuscated.toStringAsFixed(4)}, '
              '${packet.metadata.lonObfuscated.toStringAsFixed(4)}',
            ),
            pw.Text('Zone: ${packet.metadata.zoneType}'),
            pw.Text('Timestamp: ${packet.metadata.timestampIso}'),
            pw.SizedBox(height: 12),
            pw.Text('Hash SHA-256: ${packet.security.hashSha256}'),
            pw.Text('Signature ECDSA: ${packet.security.signatureEcdsa}'),
            if (evidence.serverSignature != null)
              pw.Text('Server signature: ${evidence.serverSignature}'),
          ],
        ),
      ),
    );

    return doc.save();
  }
}
