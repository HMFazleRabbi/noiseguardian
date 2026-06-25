import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/ui/core/strings.dart';
import 'package:noise_guardian/ui/features/reports/view_models/reports_view_model.dart';
import 'package:noise_guardian/ui/features/reports/views/reports_view.dart';
import 'package:provider/provider.dart';

import '../fakes/fake_report_repository.dart';
import '../fixtures/sample_evidence_packet.dart';

void main() {
  testWidgets('ReportsView lists saved reports with export actions', (tester) async {
    final reports = FakeReportRepository();
    await reports.save(sampleEvidencePacket());

    final vm = ReportsViewModel(reports: reports);
    await vm.load();

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider.value(
          value: vm,
          child: const ReportsView(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('reports_view')), findsOneWidget);
    expect(find.text('construction'), findsOneWidget);
    expect(find.text(AppStrings.reportsShareJson), findsOneWidget);
    expect(find.text(AppStrings.reportsSharePdf), findsOneWidget);
  });
}
