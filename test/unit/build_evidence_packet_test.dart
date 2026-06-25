import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/core/crypto/gps_math.dart';
import 'package:noise_guardian/data/services/signing_service.dart';
import 'package:noise_guardian/data/services/violation_evaluator.dart';
import 'package:noise_guardian/domain/models/zone_type.dart';
import 'package:noise_guardian/domain/use_cases/build_evidence_packet_use_case.dart';
import '../fakes/fake_gps_service.dart';
import '../fakes/fake_key_store.dart';
import '../fakes/fake_timestamp_service.dart';

void main() {
  group('BuildEvidencePacketUseCase', () {
    late FakeGpsService gps;
    late EcdsaSigningService signing;
    late BuildEvidencePacketUseCase useCase;

    setUp(() {
      gps = FakeGpsService();
      signing = EcdsaSigningService(keyStore: FakeKeyStore());
      useCase = BuildEvidencePacketUseCase(
        violationEvaluator: const ViolationEvaluator(),
        timestampService: FakeTimestampService(),
        gpsService: gps,
        signingService: signing,
        deviceInstallId: 'test-install-id',
        clock: () => DateTime(2026, 6, 25, 14),
      );
    });

    test('produces packet with hash and verifiable signature', () async {
      final packet = await useCase.execute(
        laeqDb: 58,
        lcPeakDb: 72,
        noiseClass: 'construction',
        zoneType: ZoneType.residential,
      );

      expect(packet.security.hashSha256, isNotEmpty);
      expect(packet.security.signatureEcdsa, isNotEmpty);
      expect(packet.security.hashSha256, packet.computeHashSha256());

      final pub = await signing.exportPublicKeyHex();
      final ok = await signing.verify(
        packet.canonicalPayload(),
        packet.security.signatureEcdsa,
        pub,
      );
      expect(ok, isTrue);
    });

    test('metadata includes obfuscated coords and exact only via hash', () async {
      final packet = await useCase.execute(
        laeqDb: 58,
        lcPeakDb: 72,
        noiseClass: 'construction',
        zoneType: ZoneType.residential,
      );

      expect(packet.metadata.latObfuscated, obfuscateCoordinate(gps.fix.latitude));
      expect(packet.metadata.lonObfuscated, obfuscateCoordinate(gps.fix.longitude));
      expect(packet.metadata.gpsHash, gpsHash(gps.fix.latitude, gps.fix.longitude));
      expect(packet.metadata.lat, gps.fix.latitude);
      expect(packet.metadata.latObfuscated, isNot(equals(packet.metadata.lat)));
    });
  });
}
