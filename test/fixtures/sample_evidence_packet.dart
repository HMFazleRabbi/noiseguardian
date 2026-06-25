import 'package:noise_guardian/domain/models/evidence_packet.dart';

EvidencePacket sampleEvidencePacket({
  double laeqDb = 58.2,
  double latObfuscated = 23.81,
  double lonObfuscated = 90.41,
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
    metadata: EvidenceMetadata(
      lat: 23.8103,
      lon: 90.4125,
      latObfuscated: latObfuscated,
      lonObfuscated: lonObfuscated,
      gpsAccuracyM: 12.0,
      gpsDop: 1.2,
      gpsHash: 'abc123',
      timestampIso: '2026-06-25T10:00:00.000Z',
      timestampToken: 'local-token-1',
      deviceIdHash: 'device-hash',
      appVersion: '0.5.0-stage5',
      zoneType: 'residential',
    ),
    security: const EvidenceSecurity(
      hashSha256: 'hash123',
      signatureEcdsa: 'sig123',
    ),
  );
}
