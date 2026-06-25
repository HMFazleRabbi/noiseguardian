/// Result of a sync batch operation.
class SyncSummary {
  const SyncSummary({
    required this.attempted,
    required this.succeeded,
    required this.failed,
  });

  static const empty = SyncSummary(attempted: 0, succeeded: 0, failed: 0);

  final int attempted;
  final int succeeded;
  final int failed;

  double get successRate =>
      attempted == 0 ? 0.0 : succeeded / attempted;
}
