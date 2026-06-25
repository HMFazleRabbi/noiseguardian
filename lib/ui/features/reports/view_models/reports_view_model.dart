import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:noise_guardian/data/models/saved_report.dart';
import 'package:noise_guardian/data/repositories/report_repository.dart';
import 'package:noise_guardian/data/services/pdf_export_service.dart';

class ReportsViewModel extends ChangeNotifier {
  ReportsViewModel({
    required ReportRepository reports,
    PdfExportService? pdfExport,
  })  : _reports = reports,
        _pdfExport = pdfExport ?? const PdfExportService();

  final ReportRepository _reports;
  final PdfExportService _pdfExport;

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

  Future<Uint8List?> exportPdf(SavedReport report) async {
    return _pdfExport.exportEvidencePdf(report.packet);
  }
}
