import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/core/crypto/gps_math.dart';
import 'package:noise_guardian/data/services/violation_evaluator.dart';
import 'package:noise_guardian/domain/models/zone_type.dart';
import 'package:noise_guardian/domain/use_cases/build_evidence_packet_use_case.dart';
import '../fakes/fake_gps_service.dart';
import '../fakes/fake_timestamp_service.dart';

void main() {
  group('BuildEvidencePacketUseCase', () {
    late FakeGpsService gps;
    late BuildEvidencePacketUseCase useCase;

    setUp(() {
      gps = FakeGpsService();
      useCase = BuildEvidencePacketUseCase(
        violationEvaluator: const ViolationEvaluator(),
        timestampService: FakeTimestampService(),
        gpsService: gps,
        deviceInstallId: 'test-install-id',
        clock: () => DateTime(2026, 6, 25, 14),
      );
    });

    test('produces packet with SHA-256 hash only', () async {
      final packet = await useCase.execute(
        laeqDb: 58,
        lcPeakDb: 72,
        noiseClass: 'construction',
        zoneType: ZoneType.residential,
      );

      expect(packet.security.hashSha256, isNotEmpty);
      expect(packet.security.hashSha256, packet.computeHashSha256());
      expect(packet.metadata.appVersion, '2.0.0-mvp');
    });

    test('metadata includes exact coords and gps_hash', () async {
      final packet = await useCase.execute(
        laeqDb: 58,
        lcPeakDb: 72,
        noiseClass: 'construction',
        zoneType: ZoneType.residential,
      );

      expect(packet.metadata.lat, gps.fix.latitude);
      expect(packet.metadata.lon, gps.fix.longitude);
      expect(packet.metadata.gpsHash, gpsHash(gps.fix.latitude, gps.fix.longitude));
    });
  });
}
