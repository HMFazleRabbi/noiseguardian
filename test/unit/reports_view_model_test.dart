import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/ui/features/reports/view_models/reports_view_model.dart';

import '../fakes/fake_report_repository.dart';
import '../fixtures/sample_evidence_packet.dart';

void main() {
  group('ReportsViewModel', () {
    test('load exposes saved reports', () async {
      final reports = FakeReportRepository();
      await reports.save(sampleEvidencePacket());

      final vm = ReportsViewModel(reports: reports);
      await vm.load();

      expect(vm.items, hasLength(1));
      expect(vm.items.single.packet.metrics.noiseClass, 'construction');
    });
  });
}
