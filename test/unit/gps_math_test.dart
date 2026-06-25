import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/core/crypto/gps_math.dart';

void main() {
  group('gps_math', () {
    test('gps_hash is stable for same coordinates', () {
      const lat = 23.810331;
      const lon = 90.412521;
      expect(gpsHash(lat, lon), gpsHash(lat, lon));
    });

    test('gps_hash differs for different coordinates', () {
      expect(gpsHash(23.810331, 90.412521), isNot(gpsHash(23.810332, 90.412521)));
    });
  });
}
