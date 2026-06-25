import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:noise_guardian/data/models/queued_evidence.dart';
import 'package:noise_guardian/data/repositories/evidence_queue_repository.dart';
import 'package:noise_guardian/data/services/pdf_export_service.dart';
import 'package:noise_guardian/domain/models/queue_status.dart';
import 'package:noise_guardian/domain/models/sync_summary.dart';
import 'package:noise_guardian/domain/use_cases/sync_evidence_use_case.dart';
import 'package:noise_guardian/l10n/app_localizations.dart';

class HistoryViewModel extends ChangeNotifier {
  HistoryViewModel({
    required EvidenceQueueRepository queue,
    required SyncEvidenceUseCase syncEvidence,
    PdfExportService? pdfExport,
  })  : _queue = queue,
        _syncEvidence = syncEvidence,
        _pdfExport = pdfExport ?? const PdfExportService();

  final EvidenceQueueRepository _queue;
  final SyncEvidenceUseCase _syncEvidence;
  final PdfExportService _pdfExport;

  List<QueuedEvidence> _items = [];
  bool _loading = false;
  bool _syncing = false;
  SyncSummary? _lastSyncSummary;
  String? _errorMessage;

  List<QueuedEvidence> get items => List.unmodifiable(_items);
  bool get loading => _loading;
  bool get syncing => _syncing;
  SyncSummary? get lastSyncSummary => _lastSyncSummary;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _items = await _queue.all();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> sync() async {
    if (_syncing) {
      return;
    }
    _syncing = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _lastSyncSummary = await _syncEvidence.execute();
      _items = await _queue.all();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _syncing = false;
      notifyListeners();
    }
  }

  Future<Uint8List?> exportPdf(QueuedEvidence item) async {
    if (item.status != QueueStatus.synced) {
      return null;
    }
    return _pdfExport.exportEvidencePdf(item);
  }

  static String statusLabel(QueueStatus status, AppLocalizations l10n) {
    switch (status) {
      case QueueStatus.pending:
        return l10n.statusPending;
      case QueueStatus.syncing:
        return l10n.statusSyncing;
      case QueueStatus.synced:
        return l10n.statusSynced;
      case QueueStatus.failed:
        return l10n.statusFailed;
    }
  }
}
