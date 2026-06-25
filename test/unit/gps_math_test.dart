import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/core/crypto/gps_math.dart';

void main() {
  group('gps_math', () {
    test('obfuscation reduces precision to 2 decimals', () {
      expect(obfuscateCoordinate(23.810331), 23.81);
      expect(obfuscateCoordinate(90.412521), 90.41);
    });

    test('gps_hash is stable for same coordinates', () {
      const lat = 23.810331;
      const lon = 90.412521;
      expect(gpsHash(lat, lon), gpsHash(lat, lon));
    });

    test('obfuscated coords differ from exact', () {
      const lat = 23.810331;
      const lon = 90.412521;
      expect(obfuscateCoordinate(lat), isNot(lat));
      expect(obfuscateCoordinate(lon), isNot(lon));
    });
  });
}
