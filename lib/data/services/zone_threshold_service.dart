import 'package:noise_guardian/domain/models/zone_type.dart';

/// Statutory day/night dB(A) limits per zone (design doc §4.2).
///
/// Residential values follow DoE briefing (55 day / 48 night).
/// Silent and Academic are provisional stricter limits — update from DoE rules.
class ZoneThresholdService {
  const ZoneThresholdService();

  static const Map<ZoneType, ({double day, double night})> _limits = {
    ZoneType.residential: (day: 55.0, night: 48.0),
    ZoneType.silent: (day: 50.0, night: 45.0),
    ZoneType.academic: (day: 52.0, night: 46.0),
  };

  /// Returns the applicable dB(A) limit for [zone] during day or night.
  double limitFor(ZoneType zone, {required bool isNight}) {
    final entry = _limits[zone] ?? _limits[ZoneType.residential]!;
    return isNight ? entry.night : entry.day;
  }
}
