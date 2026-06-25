import 'package:geolocator/geolocator.dart';
import 'package:noise_guardian/data/services/gps_service.dart';

/// Real device GPS via [geolocator].
class GeolocatorGpsService implements GpsService {
  const GeolocatorGpsService();

  @override
  Future<GpsFix> getCurrentPosition() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final requested = await Geolocator.requestPermission();
      if (requested == LocationPermission.denied ||
          requested == LocationPermission.deniedForever) {
        throw const GpsPermissionDeniedException();
      }
    } else if (permission == LocationPermission.deniedForever) {
      throw const GpsPermissionDeniedException();
    }

    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw const GpsServiceDisabledException();
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    return GpsFix(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracyM: position.accuracy,
      dop: 1.0,
    );
  }
}

class GpsPermissionDeniedException implements Exception {
  const GpsPermissionDeniedException();

  @override
  String toString() => 'GPS permission denied';
}

class GpsServiceDisabledException implements Exception {
  const GpsServiceDisabledException();

  @override
  String toString() => 'GPS service disabled';
}
