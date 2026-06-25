import 'dart:math' as math;

/// Exponential backoff schedule for sync retries (design doc §9.6).
class BackoffPolicy {
  const BackoffPolicy({
    this.maxAttempts = 5,
    this.baseDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(minutes: 5),
  });

  final int maxAttempts;
  final Duration baseDelay;
  final Duration maxDelay;

  /// Returns delay for the given zero-based attempt: 1s, 2s, 4s, 8s, … capped.
  Duration delayFor(int attempt) {
    if (attempt < 0) {
      throw ArgumentError.value(attempt, 'attempt', 'must be non-negative');
    }
    final multiplier = math.pow(2, attempt).toInt();
    final delayMs = baseDelay.inMilliseconds * multiplier;
    final cappedMs = math.min(delayMs, maxDelay.inMilliseconds);
    return Duration(milliseconds: cappedMs);
  }

  bool shouldRetry(int attempt) => attempt < maxAttempts;
}
