/// Statutory zone classification for noise limits (design doc §4.1).
enum ZoneType {
  silent,
  academic,
  residential,
}

extension ZoneTypeJson on ZoneType {
  String get wireName {
    switch (this) {
      case ZoneType.silent:
        return 'silent';
      case ZoneType.academic:
        return 'academic';
      case ZoneType.residential:
        return 'residential';
    }
  }

  static ZoneType fromWireName(String value) {
    return ZoneType.values.firstWhere(
      (z) => z.wireName == value,
      orElse: () => ZoneType.residential,
    );
  }
}
