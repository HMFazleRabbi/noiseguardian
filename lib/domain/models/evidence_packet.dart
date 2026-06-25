import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:noise_guardian/core/crypto/canonical_json.dart';

/// Acoustic metrics block (design doc §11).
class EvidenceMetrics {
  const EvidenceMetrics({
    required this.laeqDb,
    required this.lcPeakDb,
    required this.noiseClass,
    required this.isViolation,
    this.violationType,
  });

  final double laeqDb;
  final double lcPeakDb;
  final String noiseClass;
  final bool isViolation;
  final String? violationType;

  Map<String, dynamic> toJson() => {
        'laeq_db': laeqDb,
        'lc_peak_db': lcPeakDb,
        'noise_class': noiseClass,
        'is_violation': isViolation,
        if (violationType != null) 'violation_type': violationType,
      };

  factory EvidenceMetrics.fromJson(Map<String, dynamic> json) {
    return EvidenceMetrics(
      laeqDb: (json['laeq_db'] as num).toDouble(),
      lcPeakDb: (json['lc_peak_db'] as num).toDouble(),
      noiseClass: json['noise_class'] as String,
      isViolation: json['is_violation'] as bool,
      violationType: json['violation_type'] as String?,
    );
  }
}

/// Location, timestamp, and device metadata (design doc §11).
class EvidenceMetadata {
  const EvidenceMetadata({
    required this.lat,
    required this.lon,
    required this.latObfuscated,
    required this.lonObfuscated,
    required this.gpsAccuracyM,
    required this.gpsDop,
    required this.gpsHash,
    required this.timestampIso,
    required this.timestampToken,
    required this.deviceIdHash,
    required this.appVersion,
    required this.zoneType,
  });

  final double lat;
  final double lon;
  final double latObfuscated;
  final double lonObfuscated;
  final double gpsAccuracyM;
  final double gpsDop;
  final String gpsHash;
  final String timestampIso;
  final String timestampToken;
  final String deviceIdHash;
  final String appVersion;
  final String zoneType;

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lon': lon,
        'lat_obfuscated': latObfuscated,
        'lon_obfuscated': lonObfuscated,
        'gps_accuracy_m': gpsAccuracyM,
        'gps_dop': gpsDop,
        'gps_hash': gpsHash,
        'timestamp_iso': timestampIso,
        'timestamp_token': timestampToken,
        'device_id_hash': deviceIdHash,
        'app_version': appVersion,
        'zone_type': zoneType,
      };

  factory EvidenceMetadata.fromJson(Map<String, dynamic> json) {
    return EvidenceMetadata(
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      latObfuscated: (json['lat_obfuscated'] as num).toDouble(),
      lonObfuscated: (json['lon_obfuscated'] as num).toDouble(),
      gpsAccuracyM: (json['gps_accuracy_m'] as num).toDouble(),
      gpsDop: (json['gps_dop'] as num).toDouble(),
      gpsHash: json['gps_hash'] as String,
      timestampIso: json['timestamp_iso'] as String,
      timestampToken: json['timestamp_token'] as String,
      deviceIdHash: json['device_id_hash'] as String,
      appVersion: json['app_version'] as String,
      zoneType: json['zone_type'] as String,
    );
  }
}

/// Cryptographic integrity block (design doc §11).
class EvidenceSecurity {
  const EvidenceSecurity({
    required this.hashSha256,
    required this.signatureEcdsa,
    this.serverSignatureEcdsa,
  });

  final String hashSha256;
  final String signatureEcdsa;
  final String? serverSignatureEcdsa;

  Map<String, dynamic> toJson() => {
        'hash_sha256': hashSha256,
        'signature_ecdsa': signatureEcdsa,
        if (serverSignatureEcdsa != null)
          'server_signature_ecdsa': serverSignatureEcdsa,
      };

  factory EvidenceSecurity.fromJson(Map<String, dynamic> json) {
    return EvidenceSecurity(
      hashSha256: json['hash_sha256'] as String,
      signatureEcdsa: json['signature_ecdsa'] as String,
      serverSignatureEcdsa: json['server_signature_ecdsa'] as String?,
    );
  }
}

/// Immutable evidence packet for sync queue (design doc §11).
class EvidencePacket {
  const EvidencePacket({
    required this.metrics,
    required this.metadata,
    required this.security,
  });

  final EvidenceMetrics metrics;
  final EvidenceMetadata metadata;
  final EvidenceSecurity security;

  /// Deterministic JSON of metrics + metadata for hashing (sorted keys).
  String canonicalPayload() {
    return canonicalJsonEncode({
      'metrics': metrics.toJson(),
      'metadata': metadata.toJson(),
    });
  }

  /// SHA-256 hex digest of [canonicalPayload].
  String computeHashSha256() {
    final bytes = utf8.encode(canonicalPayload());
    return sha256.convert(bytes).toString();
  }

  Map<String, dynamic> toJson() => {
        'metrics': metrics.toJson(),
        'metadata': metadata.toJson(),
        'security': security.toJson(),
      };

  factory EvidencePacket.fromJson(Map<String, dynamic> json) {
    return EvidencePacket(
      metrics: EvidenceMetrics.fromJson(
        Map<String, dynamic>.from(json['metrics'] as Map),
      ),
      metadata: EvidenceMetadata.fromJson(
        Map<String, dynamic>.from(json['metadata'] as Map),
      ),
      security: EvidenceSecurity.fromJson(
        Map<String, dynamic>.from(json['security'] as Map),
      ),
    );
  }
}
