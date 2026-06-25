import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/domain/models/evidence_packet.dart';

void main() {
  final sample = EvidencePacket(
    metrics: const EvidenceMetrics(
      laeqDb: 58.2,
      lcPeakDb: 72.1,
      noiseClass: 'construction',
      isViolation: true,
      violationType: 'exceeds_day_limit',
    ),
    metadata: const EvidenceMetadata(
      lat: 23.8103,
      lon: 90.4125,
      latObfuscated: 23.81,
      lonObfuscated: 90.41,
      gpsAccuracyM: 12.0,
      gpsDop: 1.2,
      gpsHash: 'abc123',
      timestampIso: '2026-06-25T10:00:00.000Z',
      timestampToken: 'local-token-1',
      deviceIdHash: 'device-hash',
      appVersion: '0.4.0-stage4',
      zoneType: 'residential',
    ),
    security: const EvidenceSecurity(
      hashSha256: 'hash123',
      signatureEcdsa: 'sig123',
    ),
  );

  group('EvidencePacket', () {
    test('JSON round-trip is lossless', () {
      final json = sample.toJson();
      final restored = EvidencePacket.fromJson(json);
      expect(restored.metrics.laeqDb, sample.metrics.laeqDb);
      expect(restored.metadata.gpsHash, sample.metadata.gpsHash);
      expect(restored.security.signatureEcdsa, sample.security.signatureEcdsa);
      expect(jsonEncode(restored.toJson()), jsonEncode(sample.toJson()));
    });

    test('canonical payload is deterministic with sorted keys', () {
      final first = sample.canonicalPayload();
      final second = sample.canonicalPayload();
      expect(first, second);
      expect(first.indexOf('"laeq_db"'), lessThan(first.indexOf('"lc_peak_db"')));
      expect(first.indexOf('"metadata"'), lessThan(first.indexOf('"metrics"')));
    });

    test('computeHashSha256 matches canonical payload digest', () {
      final hash = sample.computeHashSha256();
      expect(hash, isNotEmpty);
      expect(hash.length, 64);
    });
  });
}
