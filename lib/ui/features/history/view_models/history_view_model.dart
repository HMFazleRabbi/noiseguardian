import 'package:flutter/foundation.dart';
import 'package:noise_guardian/data/models/queued_evidence.dart';
import 'package:noise_guardian/data/repositories/evidence_queue_repository.dart';
import 'package:noise_guardian/domain/models/queue_status.dart';
import 'package:noise_guardian/domain/models/sync_summary.dart';
import 'package:noise_guardian/domain/use_cases/sync_evidence_use_case.dart';

class HistoryViewModel extends ChangeNotifier {
  HistoryViewModel({
    required EvidenceQueueRepository queue,
    required SyncEvidenceUseCase syncEvidence,
  })  : _queue = queue,
        _syncEvidence = syncEvidence;

  final EvidenceQueueRepository _queue;
  final SyncEvidenceUseCase _syncEvidence;

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

  static String statusLabel(QueueStatus status) {
    switch (status) {
      case QueueStatus.pending:
        return 'Pending';
      case QueueStatus.syncing:
        return 'Syncing';
      case QueueStatus.synced:
        return 'Synced';
      case QueueStatus.failed:
        return 'Failed';
    }
  }
}
