import 'package:noise_guardian/data/services/timestamp_service.dart';

class FakeTimestampService implements TimestampService {
  FakeTimestampService({
    this.fixedIso = '2026-06-25T10:00:00.000Z',
    this.nightOverride,
  });

  final String fixedIso;
  final bool? nightOverride;

  @override
  bool isNight(DateTime timestamp) {
    if (nightOverride != null) {
      return nightOverride!;
    }
    final hour = timestamp.hour;
    return hour >= ViolationEvaluatorNightWindow.startHour ||
        hour < ViolationEvaluatorNightWindow.endHour;
  }

  @override
  String nowIso([DateTime? timestamp]) {
    if (timestamp != null) {
      return timestamp.toUtc().toIso8601String();
    }
    return fixedIso;
  }
}
