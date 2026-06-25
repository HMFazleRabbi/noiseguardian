import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/data/services/heatmap_aggregation_service.dart';
import '../fixtures/evidence_packet_fixtures.dart';

void main() {
  const service = HeatmapAggregationService();

  group('HeatmapAggregationService', () {
    test('cells use obfuscated coordinates only', () {
      final cells = service.aggregate([
        sampleEvidencePacket(lat: 23.810331, lon: 90.412521, latObf: 23.81, lonObf: 90.41),
        sampleEvidencePacket(laeqDb: 60, lat: 23.819999, lon: 90.419999, latObf: 23.81, lonObf: 90.41),
      ]);

      expect(cells, hasLength(1));
      expect(cells.single.latObfuscated, 23.81);
      expect(cells.single.lonObfuscated, 90.41);
      expect(cells.single.count, 2);
      expect(cells.single.avgLaeqDb, 59.0);
      expect(cells.single.maxLaeqDb, 60.0);
    });

    test('separate cells for different obfuscated locations', () {
      final cells = service.aggregate([
        sampleEvidencePacket(latObf: 23.81, lonObf: 90.41),
        sampleEvidencePacket(latObf: 23.82, lonObf: 90.42),
      ]);
      expect(cells, hasLength(2));
    });

    test('counts violations', () {
      final cells = service.aggregate([
        sampleEvidencePacket(isViolation: true),
        sampleEvidencePacket(isViolation: false),
      ]);
      expect(cells.single.violationCount, 1);
    });
  });
}
