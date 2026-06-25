/// Offline queue row lifecycle (design doc §9.6).
enum QueueStatus {
  pending,
  syncing,
  synced,
  failed;

  String get wireName => name;

  static QueueStatus fromWire(String value) {
    return QueueStatus.values.firstWhere(
      (s) => s.wireName == value,
      orElse: () => throw ArgumentError('Unknown queue status: $value'),
    );
  }
}
