import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/data/models/queued_evidence.dart';
import 'package:noise_guardian/data/repositories/evidence_queue_repository.dart';
import 'package:noise_guardian/domain/models/evidence_packet.dart';
import 'package:noise_guardian/domain/models/heatmap_cell.dart';
import 'package:noise_guardian/domain/models/sync_receipt.dart';
import 'package:noise_guardian/l10n/app_localizations.dart';
import 'package:noise_guardian/ui/features/heatmap/view_models/heatmap_view_model.dart';
import 'package:noise_guardian/ui/features/heatmap/views/heatmap_view.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('HeatmapView renders aggregated cells', (tester) async {
    final vm = _StubHeatmapViewModel([
      const HeatmapCell(
        latObfuscated: 23.81,
        lonObfuscated: 90.41,
        count: 2,
        avgLaeqDb: 62.5,
        maxLaeqDb: 70.0,
        violationCount: 1,
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ChangeNotifierProvider<HeatmapViewModel>.value(
          value: vm,
          child: const HeatmapView(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('heatmap_view')), findsOneWidget);
    expect(find.byKey(const ValueKey('heatmap_map_view')), findsOneWidget);
    expect(find.byKey(const ValueKey('heatmap_cell_23.81,90.41')), findsOneWidget);
    expect(find.text('n=2'), findsOneWidget);
    expect(find.textContaining('23.81'), findsOneWidget);
  });
}

class _StubHeatmapViewModel extends HeatmapViewModel {
  _StubHeatmapViewModel(this._cells) : super(queue: _NoopQueue());

  final List<HeatmapCell> _cells;

  @override
  Future<void> load() async {}

  @override
  List<HeatmapCell> get cells => _cells;

  @override
  bool get loading => false;
}

class _NoopQueue implements EvidenceQueueRepository {
  @override
  Future<void> init() async {}
  @override
  Future<int> enqueue(EvidencePacket packet) => throw UnimplementedError();
  @override
  Future<List<QueuedEvidence>> pending() => throw UnimplementedError();
  @override
  Future<List<QueuedEvidence>> all() => throw UnimplementedError();
  @override
  Future<QueuedEvidence?> getById(int id) => throw UnimplementedError();
  @override
  Future<void> markSyncing(int id) => throw UnimplementedError();
  @override
  Future<void> markSynced(int id, SyncReceipt receipt) => throw UnimplementedError();
  @override
  Future<void> markFailed(int id) => throw UnimplementedError();
  @override
  Future<void> incrementAttempts(int id) => throw UnimplementedError();
  @override
  Future<List<EvidencePacket>> syncedPackets() => throw UnimplementedError();
}
