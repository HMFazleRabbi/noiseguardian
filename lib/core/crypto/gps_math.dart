import 'dart:convert';

import 'package:crypto/crypto.dart';

/// SHA-256 hex digest of exact lat/lon for integrity verification.
String gpsHash(double lat, double lon) {
  final payload = '${lat.toStringAsFixed(8)},${lon.toStringAsFixed(8)}';
  return sha256.convert(utf8.encode(payload)).toString();
}
