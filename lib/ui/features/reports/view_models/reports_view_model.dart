import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:noise_guardian/data/models/saved_report.dart';
import 'package:noise_guardian/data/repositories/report_repository.dart';
import 'package:noise_guardian/data/services/json_export_service.dart';
import 'package:noise_guardian/data/services/pdf_export_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ReportsViewModel extends ChangeNotifier {
  ReportsViewModel({
    required ReportRepository reports,
    PdfExportService? pdfExport,
    JsonExportService? jsonExport,
  })  : _reports = reports,
        _pdfExport = pdfExport ?? const PdfExportService(),
        _jsonExport = jsonExport ?? const JsonExportService();

  final ReportRepository _reports;
  final PdfExportService _pdfExport;
  final JsonExportService _jsonExport;

  List<SavedReport> _items = [];
  bool _loading = false;
  String? _errorMessage;

  List<SavedReport> get items => List.unmodifiable(_items);
  bool get loading => _loading;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _items = await _reports.list();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  String exportJson(SavedReport report) {
    return _jsonExport.exportEvidenceJson(report.packet);
  }

  Future<Uint8List> exportPdfBytes(SavedReport report) async {
    return _pdfExport.exportEvidencePdf(report.packet);
  }

  Future<void> shareJson(SavedReport report) async {
    await Share.share(
      exportJson(report),
      subject: 'NoiseGuardian evidence report',
    );
  }

  Future<void> sharePdf(SavedReport report) async {
    final bytes = await exportPdfBytes(report);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/noise_guardian_${report.id}.pdf');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'NoiseGuardian evidence PDF',
    );
  }
}
