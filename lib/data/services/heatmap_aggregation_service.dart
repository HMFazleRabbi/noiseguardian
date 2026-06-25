import 'package:noise_guardian/domain/models/evidence_packet.dart';
import 'package:noise_guardian/domain/models/heatmap_cell.dart';

/// Aggregates local synced packets into anonymized grid cells (§9.7).
class HeatmapAggregationService {
  const HeatmapAggregationService();

  List<HeatmapCell> aggregate(List<EvidencePacket> packets) {
    final buckets = <String, _Bucket>{};

    for (final packet in packets) {
      final lat = packet.metadata.latObfuscated;
      final lon = packet.metadata.lonObfuscated;
      assert(
        lat != packet.metadata.lat || lon != packet.metadata.lon,
        'Heatmap must use obfuscated coordinates only',
      );

      final key = '${lat.toStringAsFixed(5)},${lon.toStringAsFixed(5)}';
      final bucket = buckets.putIfAbsent(key, () => _Bucket(lat, lon));
      bucket.add(packet.metrics.laeqDb, packet.metrics.isViolation);
    }

    return buckets.values
        .map(
          (b) => HeatmapCell(
            latObfuscated: b.lat,
            lonObfuscated: b.lon,
            count: b.count,
            avgLaeqDb: b.totalLaeq / b.count,
            maxLaeqDb: b.maxLaeq,
            violationCount: b.violations,
          ),
        )
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));
  }
}

class _Bucket {
  _Bucket(this.lat, this.lon);

  final double lat;
  final double lon;
  int count = 0;
  double totalLaeq = 0;
  double maxLaeq = double.negativeInfinity;
  int violations = 0;

  void add(double laeq, bool isViolation) {
    count++;
    totalLaeq += laeq;
    if (laeq > maxLaeq) {
      maxLaeq = laeq;
    }
    if (isViolation) {
      violations++;
    }
  }
}
