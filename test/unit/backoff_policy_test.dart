import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/core/net/backoff_policy.dart';

void main() {
  group('BackoffPolicy', () {
    const policy = BackoffPolicy(maxAttempts: 5);

    test('delay schedule is 1s, 2s, 4s, 8s', () {
      expect(policy.delayFor(0), const Duration(seconds: 1));
      expect(policy.delayFor(1), const Duration(seconds: 2));
      expect(policy.delayFor(2), const Duration(seconds: 4));
      expect(policy.delayFor(3), const Duration(seconds: 8));
    });

    test('delay is capped at 5 minutes', () {
      expect(policy.delayFor(20), const Duration(minutes: 5));
    });

    test('shouldRetry honors maxAttempts', () {
      expect(policy.shouldRetry(0), isTrue);
      expect(policy.shouldRetry(4), isTrue);
      expect(policy.shouldRetry(5), isFalse);
    });
  });
}
