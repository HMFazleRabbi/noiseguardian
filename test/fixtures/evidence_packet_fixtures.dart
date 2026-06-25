import 'package:noise_guardian/domain/models/evidence_packet.dart';

EvidencePacket sampleEvidencePacket({
  double laeqDb = 58.0,
  double lat = 23.810331,
  double lon = 90.412521,
  bool isViolation = true,
}) {
  return EvidencePacket(
    metrics: EvidenceMetrics(
      laeqDb: laeqDb,
      lcPeakDb: 72.0,
      noiseClass: 'generator',
      isViolation: isViolation,
      violationType: 'exceeds_day_limit',
    ),
    metadata: EvidenceMetadata(
      lat: lat,
      lon: lon,
      gpsAccuracyM: 10,
      gpsHash: 'hash123',
      timestampIso: '2026-06-25T10:00:00.000Z',
      deviceIdHash: 'device-hash',
      appVersion: '2.0.0-mvp',
      zoneType: 'residential',
    ),
    security: const EvidenceSecurity(
      hashSha256: 'abc',
    ),
  );
}
