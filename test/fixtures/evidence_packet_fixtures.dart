import 'package:noise_guardian/domain/models/evidence_packet.dart';

EvidencePacket sampleEvidencePacket({
  double laeqDb = 58.0,
  double lat = 23.810331,
  double lon = 90.412521,
  double latObf = 23.81,
  double lonObf = 90.41,
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
      latObfuscated: latObf,
      lonObfuscated: lonObf,
      gpsAccuracyM: 10,
      gpsDop: 1.2,
      gpsHash: 'hash123',
      timestampIso: '2026-06-25T10:00:00.000Z',
      timestampToken: 'token-1',
      deviceIdHash: 'device-hash',
      appVersion: '0.5.0-stage5',
      zoneType: 'residential',
    ),
    security: const EvidenceSecurity(
      hashSha256: 'abc',
      signatureEcdsa: 'sig',
    ),
  );
}
