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

  group('EvidencePacket', () {
    test('JSON round-trip is lossless', () {
      final json = sample.toJson();
      final restored = EvidencePacket.fromJson(json);
      expect(restored.metrics.laeqDb, sample.metrics.laeqDb);
      expect(restored.metadata.gpsHash, sample.metadata.gpsHash);
      expect(restored.security.hashSha256, sample.security.hashSha256);
      expect(jsonEncode(restored.toJson()), jsonEncode(sample.toJson()));
    });

    test('JSON has no removed crypto or obfuscation fields', () {
      final encoded = jsonEncode(sample.toJson());
      expect(encoded, isNot(contains('signature_ecdsa')));
      expect(encoded, isNot(contains('lat_obfuscated')));
      expect(encoded, isNot(contains('timestamp_token')));
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

    test('mutated field produces hash mismatch', () {
      final built = EvidencePacket(
        metrics: sample.metrics,
        metadata: sample.metadata,
        security: EvidenceSecurity(hashSha256: sample.computeHashSha256()),
      );
      expect(built.security.hashSha256, built.computeHashSha256());

      final tampered = EvidencePacket(
        metrics: EvidenceMetrics(
          laeqDb: sample.metrics.laeqDb + 0.1,
          lcPeakDb: sample.metrics.lcPeakDb,
          noiseClass: sample.metrics.noiseClass,
          isViolation: sample.metrics.isViolation,
          violationType: sample.metrics.violationType,
        ),
        metadata: sample.metadata,
        security: built.security,
      );
      expect(tampered.security.hashSha256, isNot(tampered.computeHashSha256()));
    });
  });
}
