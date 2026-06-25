import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Rounds coordinates to ~1.1 km precision (2 decimal places).
double obfuscateCoordinate(double coordinate) {
  return (coordinate * 100).roundToDouble() / 100;
}

/// SHA-256 hex digest of exact lat/lon for server-side geofence verification.
String gpsHash(double lat, double lon) {
  final payload = '${lat.toStringAsFixed(8)},${lon.toStringAsFixed(8)}';
  return sha256.convert(utf8.encode(payload)).toString();
}
