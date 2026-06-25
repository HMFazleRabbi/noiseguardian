import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:noise_guardian/core/crypto/gps_math.dart';
import 'package:noise_guardian/data/services/gps_service.dart';
import 'package:noise_guardian/data/services/timestamp_service.dart';
import 'package:noise_guardian/data/services/violation_evaluator.dart';
import 'package:noise_guardian/domain/models/evidence_packet.dart';
import 'package:noise_guardian/domain/models/violation_result.dart';
import 'package:noise_guardian/domain/models/zone_type.dart';

/// Application version stamped on evidence packets.
const String kEvidenceAppVersion = '2.0.0-mvp';

/// Assembles [EvidencePacket] with SHA-256 integrity hash.
class BuildEvidencePacketUseCase {
  BuildEvidencePacketUseCase({
    required ViolationEvaluator violationEvaluator,
    required TimestampService timestampService,
    required GpsService gpsService,
    required String deviceInstallId,
    DateTime Function()? clock,
  })  : _violationEvaluator = violationEvaluator,
        _timestampService = timestampService,
        _gpsService = gpsService,
        _deviceInstallId = deviceInstallId,
        _clock = clock ?? DateTime.now;

  final ViolationEvaluator _violationEvaluator;
  final TimestampService _timestampService;
  final GpsService _gpsService;
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
      gpsAccuracyM: fix.accuracyM,
      gpsHash: gpsHash(fix.latitude, fix.longitude),
      timestampIso: _timestampService.nowIso(timestamp),
      deviceIdHash: _deviceIdHash(_deviceInstallId),
      appVersion: kEvidenceAppVersion,
      zoneType: zoneType.wireName,
    );

    final unsigned = EvidencePacket(
      metrics: metrics,
      metadata: metadata,
      security: const EvidenceSecurity(hashSha256: ''),
    );

    final hashSha256 = unsigned.computeHashSha256();

    return EvidencePacket(
      metrics: metrics,
      metadata: metadata,
      security: EvidenceSecurity(hashSha256: hashSha256),
    );
  }

  String _deviceIdHash(String installId) {
    return sha256.convert(utf8.encode(installId)).toString();
  }
}
