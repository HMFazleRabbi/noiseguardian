import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:noise_guardian/core/crypto/gps_math.dart';
import 'package:noise_guardian/data/services/gps_service.dart';
import 'package:noise_guardian/data/services/signing_service.dart';
import 'package:noise_guardian/data/services/timestamp_service.dart';
import 'package:noise_guardian/data/services/violation_evaluator.dart';
import 'package:noise_guardian/domain/models/evidence_packet.dart';
import 'package:noise_guardian/domain/models/violation_result.dart';
import 'package:noise_guardian/domain/models/zone_type.dart';

/// Application version stamped on evidence packets.
const String kEvidenceAppVersion = '0.4.0-stage4';

/// Assembles signed [EvidencePacket] from capture metrics and services.
class BuildEvidencePacketUseCase {
  BuildEvidencePacketUseCase({
    required ViolationEvaluator violationEvaluator,
    required TimestampService timestampService,
    required GpsService gpsService,
    required SigningService signingService,
    required String deviceInstallId,
    DateTime Function()? clock,
  })  : _violationEvaluator = violationEvaluator,
        _timestampService = timestampService,
        _gpsService = gpsService,
        _signingService = signingService,
        _deviceInstallId = deviceInstallId,
        _clock = clock ?? DateTime.now;

  final ViolationEvaluator _violationEvaluator;
  final TimestampService _timestampService;
  final GpsService _gpsService;
  final SigningService _signingService;
  final String _deviceInstallId;
  final DateTime Function() _clock;

  Future<EvidencePacket> execute({
    required double laeqDb,
    required double lcPeakDb,
    required String noiseClass,
    required ZoneType zoneType,
  }) async {
    final timestamp = _clock().toLocal();
    final violation = _violationEvaluator.evaluate(
      laeq: laeqDb,
      lcPeak: lcPeakDb,
      zone: zoneType,
      timestamp: timestamp,
    );
    final fix = await _gpsService.getCurrentPosition();

    final latObf = obfuscateCoordinate(fix.latitude);
    final lonObf = obfuscateCoordinate(fix.longitude);
    final hash = gpsHash(fix.latitude, fix.longitude);

    final metrics = EvidenceMetrics(
      laeqDb: laeqDb,
      lcPeakDb: lcPeakDb,
      noiseClass: noiseClass,
      isViolation: violation.isViolation,
      violationType: violation.violationType.wireName,
    );

    final metadata = EvidenceMetadata(
      lat: fix.latitude,
      lon: fix.longitude,
      latObfuscated: latObf,
      lonObfuscated: lonObf,
      gpsAccuracyM: fix.accuracyM,
      gpsDop: fix.dop,
      gpsHash: hash,
      timestampIso: timestamp.toUtc().toIso8601String(),
      timestampToken: _timestampService.nowToken(),
      deviceIdHash: _deviceIdHash(_deviceInstallId),
      appVersion: kEvidenceAppVersion,
      zoneType: zoneType.wireName,
    );

    final unsigned = EvidencePacket(
      metrics: metrics,
      metadata: metadata,
      security: const EvidenceSecurity(
        hashSha256: '',
        signatureEcdsa: '',
      ),
    );

    final hashSha256 = unsigned.computeHashSha256();
    final canonical = unsigned.canonicalPayload();
    final signature = await _signingService.sign(canonical);

    return EvidencePacket(
      metrics: metrics,
      metadata: metadata,
      security: EvidenceSecurity(
        hashSha256: hashSha256,
        signatureEcdsa: signature,
      ),
    );
  }

  String _deviceIdHash(String installId) {
    return sha256.convert(utf8.encode(installId)).toString();
  }
}
