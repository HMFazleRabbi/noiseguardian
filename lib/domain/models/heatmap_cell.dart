/// Anonymized neighborhood aggregation cell (design doc §9.7).
///
/// Contains only obfuscated coordinates — never exact lat/lon.
class HeatmapCell {
  const HeatmapCell({
    required this.latObfuscated,
    required this.lonObfuscated,
    required this.count,
    required this.avgLaeqDb,
    required this.maxLaeqDb,
    required this.violationCount,
  });

  final double latObfuscated;
  final double lonObfuscated;
  final int count;
  final double avgLaeqDb;
  final double maxLaeqDb;
  final int violationCount;

  String get cellKey => '$latObfuscated,$lonObfuscated';
}
