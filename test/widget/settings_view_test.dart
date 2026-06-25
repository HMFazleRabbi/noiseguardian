import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/ui/core/strings.dart';
import 'package:noise_guardian/ui/features/settings/view_models/settings_view_model.dart';
import 'package:noise_guardian/ui/features/settings/views/settings_view.dart';
import 'package:provider/provider.dart';
import '../fakes/fake_consent_repository.dart';
import '../fakes/fake_report_repository.dart';
import '../fixtures/sample_evidence_packet.dart';

void main() {
  testWidgets('SettingsView shows export last report button', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    addTearDown(tester.view.resetPhysicalSize);

    final reports = FakeReportRepository();
    await reports.save(sampleEvidencePacket());
    final consent = FakeConsentRepository();

    final vm = SettingsViewModel(
      consent: consent,
      reports: reports,
    );
    await vm.load();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider.value(
            value: vm,
            child: const SettingsView(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('settings_view')), findsOneWidget);
    expect(find.byKey(const ValueKey('settings_export_pdf_button')), findsOneWidget);
    expect(find.text(AppStrings.settingsTitle), findsOneWidget);
  });
}
