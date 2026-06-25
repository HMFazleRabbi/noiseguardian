import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:noise_guardian/data/models/queued_evidence.dart';
import 'package:noise_guardian/data/repositories/app_settings_repository.dart';
import 'package:noise_guardian/data/repositories/consent_repository.dart';
import 'package:noise_guardian/data/repositories/evidence_queue_repository.dart';
import 'package:noise_guardian/data/services/pdf_export_service.dart';
import 'package:noise_guardian/domain/models/queue_status.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({
    required AppSettingsRepository settings,
    required ConsentRepository consent,
    required EvidenceQueueRepository queue,
    PdfExportService? pdfExport,
  })  : _settings = settings,
        _consent = consent,
        _queue = queue,
        _pdfExport = pdfExport ?? const PdfExportService();

  final AppSettingsRepository _settings;
  final ConsentRepository _consent;
  final EvidenceQueueRepository _queue;
  final PdfExportService _pdfExport;

  bool _useMockDoe = true;
  bool _loading = true;
  String? _errorMessage;
  QueuedEvidence? _lastSynced;

  bool get useMockDoe => _useMockDoe;
  bool get loading => _loading;
  String? get errorMessage => _errorMessage;
  QueuedEvidence? get lastSynced => _lastSynced;

  Future<void> load() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _useMockDoe = _settings.useMockDoe;
      await _loadLastSynced();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _loadLastSynced() async {
    final all = await _queue.all();
    final synced = all.where((e) => e.status == QueueStatus.synced).toList();
    if (synced.isEmpty) {
      _lastSynced = null;
      return;
    }
    synced.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    _lastSynced = synced.first;
  }

  Future<Uint8List?> exportLastSyncedPdf() async {
    if (_lastSynced == null) {
      return null;
    }
    return _pdfExport.exportEvidencePdf(_lastSynced!);
  }

  Future<void> revokeConsent() async {
    await _consent.setConsented(value: false);
    notifyListeners();
  }
}
