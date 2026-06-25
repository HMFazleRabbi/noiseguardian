import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/domain/models/sync_receipt.dart';
import 'package:noise_guardian/ui/core/strings.dart';
import 'package:noise_guardian/ui/features/settings/view_models/settings_view_model.dart';
import 'package:noise_guardian/ui/features/settings/views/settings_view.dart';
import 'package:provider/provider.dart';
import '../fakes/fake_app_settings_repository.dart';
import '../fakes/fake_consent_repository.dart';
import '../fakes/fake_evidence_queue_repository.dart';
import '../fixtures/sample_evidence_packet.dart';

void main() {
  testWidgets('SettingsView shows mock DoE indicator and export button', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    addTearDown(tester.view.resetPhysicalSize);

    final settings = FakeAppSettingsRepository();
    final consent = FakeConsentRepository();
    final queue = FakeEvidenceQueueRepository();
    await queue.init();
    final id = await queue.enqueue(sampleEvidencePacket());
    await queue.markSynced(
      id,
      const SyncReceipt(
        receiptId: 'DOE-DHK-2026-0001',
        serverSignatureEcdsa: 'sig',
      ),
    );

    final vm = SettingsViewModel(
      settings: settings,
      consent: consent,
      queue: queue,
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
    expect(find.byKey(const ValueKey('settings_mock_doe_indicator')), findsOneWidget);
    expect(find.byKey(const ValueKey('settings_export_pdf_button')), findsOneWidget);
    expect(find.text(AppStrings.settingsTitle), findsOneWidget);
  });
}
