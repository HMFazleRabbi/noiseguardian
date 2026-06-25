/// Timestamp abstraction — local ISO-8601 device time (MVP Stage 5).
abstract class TimestampService {
  const TimestampService();

  /// Current time as ISO-8601 string (UTC).
  String nowIso([DateTime? timestamp]);

  /// True when [timestamp] falls in the night window (22:00–06:00 local).
  bool isNight(DateTime timestamp);
}

/// Local ISO-8601 implementation.
class LocalTimestampService implements TimestampService {
  const LocalTimestampService();

  @override
  String nowIso([DateTime? timestamp]) {
    return (timestamp ?? DateTime.now()).toUtc().toIso8601String();
  }

  @override
  bool isNight(DateTime timestamp) {
    final hour = timestamp.hour;
    return hour >= ViolationEvaluatorNightWindow.startHour ||
        hour < ViolationEvaluatorNightWindow.endHour;
  }
}

/// Shared night-window constants (avoid circular import with evaluator).
abstract final class ViolationEvaluatorNightWindow {
  static const int startHour = 22;
  static const int endHour = 6;
}
