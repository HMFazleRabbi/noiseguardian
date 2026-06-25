import 'package:noise_guardian/data/services/timestamp_service.dart';

class FakeTimestampService implements TimestampService {
  FakeTimestampService({
    this.fixedIso = '2026-06-25T10:00:00.000Z',
    this.fixedToken = 'test-token-1',
    this.nightOverride,
  });

  final String fixedIso;
  final String fixedToken;
  final bool? nightOverride;
  int _counter = 0;

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
  String nowIso() => fixedIso;

  @override
  String nowToken() {
    _counter += 1;
    return '$fixedToken-$_counter';
  }
}
