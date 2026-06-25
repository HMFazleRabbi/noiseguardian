import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/domain/models/sync_receipt.dart';
import 'package:noise_guardian/domain/use_cases/sync_evidence_use_case.dart';
import 'package:noise_guardian/l10n/app_localizations.dart';
import 'package:noise_guardian/ui/features/history/view_models/history_view_model.dart';
import 'package:noise_guardian/ui/features/history/views/history_view.dart';
import 'package:provider/provider.dart';

import '../fakes/fake_evidence_queue_repository.dart';
import '../fakes/fake_sync_service.dart';
import '../fixtures/evidence_packet_fixtures.dart';

void main() {
  testWidgets('HistoryView renders status chips, receipt, and sync button', (tester) async {
    final queue = FakeEvidenceQueueRepository();
    final id = await queue.enqueue(sampleEvidencePacket());
    await queue.markSynced(
      id,
      const SyncReceipt(
        receiptId: 'DOE-DHK-2026-001',
        serverSignatureEcdsa: 'sig',
      ),
    );
    await queue.enqueue(sampleEvidencePacket());

    final vm = HistoryViewModel(
      queue: queue,
      syncEvidence: SyncEvidenceUseCase(syncService: FakeSyncService()),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ChangeNotifierProvider.value(
          value: vm,
          child: const HistoryView(),
        ),
      ),
    );
    await vm.load();
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('history_view')), findsOneWidget);
    expect(find.byKey(const ValueKey('history_sync_button')), findsOneWidget);
    expect(find.text('DOE-DHK-2026-001'), findsOneWidget);
    expect(find.byKey(const ValueKey('status_chip_synced')), findsOneWidget);
    expect(find.byKey(const ValueKey('status_chip_pending')), findsOneWidget);
  });
}
