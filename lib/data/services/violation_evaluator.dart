import 'package:noise_guardian/data/services/timestamp_service.dart';
import 'package:noise_guardian/data/services/zone_threshold_service.dart';
import 'package:noise_guardian/domain/models/violation_result.dart';
import 'package:noise_guardian/domain/models/zone_type.dart';

/// Evaluates LAeq against zone thresholds and restricted-hour rules.
class ViolationEvaluator {
  const ViolationEvaluator({
    this.thresholdService = const ZoneThresholdService(),
    this.timestampService = const LocalTimestampService(),
  });

  final ZoneThresholdService thresholdService;
  final TimestampService timestampService;

  /// Night window for Bangladesh (22:00–06:00 local).
  static const int nightStartHour = ViolationEvaluatorNightWindow.startHour;
  static const int nightEndHour = ViolationEvaluatorNightWindow.endHour;

  ViolationResult evaluate({
    required double laeq,
    required double lcPeak,
    required ZoneType zone,
    required DateTime timestamp,
  }) {
    final isNight = timestampService.isNight(timestamp);
    final threshold = thresholdService.limitFor(zone, isNight: isNight);

    if (laeq <= threshold) {
      return ViolationResult(
        isViolation: false,
        violationType: ViolationType.none,
        zoneType: zone,
        appliedThresholdDb: threshold,
        measuredLaeqDb: laeq,
      );
    }

    if (isNight && _isRestrictedHour(timestamp)) {
      return ViolationResult(
        isViolation: true,
        violationType: ViolationType.restrictedHour,
        zoneType: zone,
        appliedThresholdDb: threshold,
        measuredLaeqDb: laeq,
      );
    }

    return ViolationResult(
      isViolation: true,
      violationType:
          isNight ? ViolationType.exceedsNightLimit : ViolationType.exceedsDayLimit,
      zoneType: zone,
      appliedThresholdDb: threshold,
      measuredLaeqDb: laeq,
    );
  }

  /// Restricted construction/noise ban window (23:00–05:00 local).
  static const int restrictedStartHour = 23;
  static const int restrictedEndHour = 5;

  bool _isRestrictedHour(DateTime timestamp) {
    final hour = timestamp.hour;
    return hour >= restrictedStartHour || hour < restrictedEndHour;
  }
}
