import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:noise_guardian/core/locale/app_locale_notifier.dart';
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
    AppLocaleNotifier? localeNotifier,
    PdfExportService? pdfExport,
  })  : _settings = settings,
        _consent = consent,
        _queue = queue,
        _localeNotifier = localeNotifier,
        _pdfExport = pdfExport ?? const PdfExportService();

  final AppSettingsRepository _settings;
  final ConsentRepository _consent;
  final EvidenceQueueRepository _queue;
  final AppLocaleNotifier? _localeNotifier;
  final PdfExportService _pdfExport;

  bool _lowDataMode = false;
  bool _useMockDoe = true;
  String? _localeCode;
  bool _loading = true;
  String? _errorMessage;
  QueuedEvidence? _lastSynced;

  bool get lowDataMode => _lowDataMode;
  bool get useMockDoe => _useMockDoe;
  String? get localeCode => _localeCode;
  bool get loading => _loading;
  String? get errorMessage => _errorMessage;
  QueuedEvidence? get lastSynced => _lastSynced;

  Future<void> load() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _lowDataMode = _settings.lowDataMode;
      _useMockDoe = _settings.useMockDoe;
      _localeCode = _settings.localeCode;
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

  Future<void> setLowDataMode(bool value) async {
    _lowDataMode = value;
    await _settings.setLowDataMode(value);
    notifyListeners();
  }

  Future<void> setLocaleCode(String code) async {
    _localeCode = code;
    await _settings.setLocaleCode(code);
    _localeNotifier?.setLocale(Locale(code));
    notifyListeners();
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
