/// GPS fix with accuracy and dilution-of-precision.
class GpsFix {
  const GpsFix({
    required this.latitude,
    required this.longitude,
    required this.accuracyM,
    required this.dop,
  });

  final double latitude;
  final double longitude;
  final double accuracyM;
  final double dop;
}

/// GPS acquisition abstraction.
abstract class GpsService {
  const GpsService();

  Future<GpsFix> getCurrentPosition();
}

/// Returns a fixed Dhaka coordinate for tests and offline dev.
class StubGpsService implements GpsService {
  const StubGpsService({
    this.latitude = 23.8103,
    this.longitude = 90.4125,
    this.accuracyM = 12.0,
    this.dop = 1.2,
  });

  final double latitude;
  final double longitude;
  final double accuracyM;
  final double dop;

  @override
  Future<GpsFix> getCurrentPosition() async {
    return GpsFix(
      latitude: latitude,
      longitude: longitude,
      accuracyM: accuracyM,
      dop: dop,
    );
  }
}
