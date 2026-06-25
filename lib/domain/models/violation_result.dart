import 'package:noise_guardian/domain/models/zone_type.dart';

/// Violation classification for statutory noise limits.
enum ViolationType {
  none,
  exceedsDayLimit,
  exceedsNightLimit,
  restrictedHour,
}

extension ViolationTypeJson on ViolationType {
  String? get wireName {
    switch (this) {
      case ViolationType.none:
        return null;
      case ViolationType.exceedsDayLimit:
        return 'exceeds_day_limit';
      case ViolationType.exceedsNightLimit:
        return 'exceeds_night_limit';
      case ViolationType.restrictedHour:
        return 'restricted_hour';
    }
  }

  static ViolationType fromWireName(String? value) {
    if (value == null) {
      return ViolationType.none;
    }
    return ViolationType.values.firstWhere(
      (v) => v.wireName == value,
      orElse: () => ViolationType.none,
    );
  }
}

/// Output of [ViolationEvaluator].
class ViolationResult {
  const ViolationResult({
    required this.isViolation,
    required this.violationType,
    required this.zoneType,
    required this.appliedThresholdDb,
    required this.measuredLaeqDb,
  });

  final bool isViolation;
  final ViolationType violationType;
  final ZoneType zoneType;
  final double appliedThresholdDb;
  final double measuredLaeqDb;
}
