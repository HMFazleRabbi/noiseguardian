/// Timestamp abstraction — RFC 3161 TSA deferred to Stage 5.
abstract class TimestampService {
  const TimestampService();

  /// Current UTC time as ISO-8601 string.
  String nowIso();

  /// Monotonic counter token for ordering (local until TSA wired).
  String nowToken();

  /// True when [timestamp] falls in the night window (22:00–06:00 local).
  bool isNight(DateTime timestamp);
}

/// Local ISO-8601 + monotonic token implementation for Stage 4.
class LocalTimestampService implements TimestampService {
  const LocalTimestampService();

  static int _counter = 0;

  @override
  String nowIso() => DateTime.now().toUtc().toIso8601String();

  @override
  String nowToken() {
    _counter += 1;
    return 'local-${DateTime.now().microsecondsSinceEpoch}-$_counter';
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
