import 'package:noise_guardian/domain/models/evidence_packet.dart';

EvidencePacket sampleEvidencePacket({
  double laeqDb = 58.2,
  bool isViolation = true,
  String noiseClass = 'construction',
}) {
  return EvidencePacket(
    metrics: EvidenceMetrics(
      laeqDb: laeqDb,
      lcPeakDb: laeqDb + 6,
      noiseClass: noiseClass,
      isViolation: isViolation,
      violationType: isViolation ? 'exceeds_day_limit' : null,
    ),
    metadata: const EvidenceMetadata(
      lat: 23.8103,
      lon: 90.4125,
      gpsAccuracyM: 12.0,
      gpsHash: 'abc123',
      timestampIso: '2026-06-25T10:00:00.000Z',
      deviceIdHash: 'device-hash',
      appVersion: '2.0.0-mvp',
      zoneType: 'residential',
    ),
    security: const EvidenceSecurity(
      hashSha256: 'hash123',
    ),
  );
}
