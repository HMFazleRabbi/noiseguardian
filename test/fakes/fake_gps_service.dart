import 'package:noise_guardian/data/services/gps_service.dart';

class FakeGpsService implements GpsService {
  FakeGpsService({
    this.fix = const GpsFix(
      latitude: 23.810331,
      longitude: 90.412521,
      accuracyM: 8.5,
      dop: 1.1,
    ),
  });

  GpsFix fix;

  @override
  Future<GpsFix> getCurrentPosition() async => fix;
}
