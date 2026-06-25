import 'dart:convert';
import 'dart:io';

import 'package:noise_guardian/data/models/saved_report.dart';
import 'package:noise_guardian/domain/models/evidence_packet.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Local persistence for finished evidence packets (plain JSON, no sync).
abstract class ReportRepository {
  Future<void> init();
  Future<String> save(EvidencePacket packet);
  Future<SavedReport?> getById(String id);
  Future<List<SavedReport>> list();
}

class InMemoryReportRepository implements ReportRepository {
  final List<SavedReport> _reports = [];
  int _counter = 1;

  @override
  Future<void> init() async {}

  @override
  Future<String> save(EvidencePacket packet) async {
    final id = 'report-${_counter++}';
    _reports.add(
      SavedReport(
        id: id,
        savedAt: DateTime.now(),
        packet: packet,
      ),
    );
    return id;
  }

  @override
  Future<SavedReport?> getById(String id) async {
    try {
      return _reports.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<SavedReport>> list() async {
    final copy = List<SavedReport>.of(_reports);
    copy.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return copy;
  }
}

class FileReportRepository implements ReportRepository {
  FileReportRepository({Directory? baseDirectory}) : _baseDirectory = baseDirectory;

  Directory? _baseDirectory;
  late Directory _reportsDir;

  @override
  Future<void> init() async {
    _baseDirectory ??= await getApplicationDocumentsDirectory();
    _reportsDir = Directory(p.join(_baseDirectory!.path, 'reports'));
    if (!_reportsDir.existsSync()) {
      await _reportsDir.create(recursive: true);
    }
  }

  @override
  Future<String> save(EvidencePacket packet) async {
    final savedAt = DateTime.now();
    final id = 'report-${savedAt.microsecondsSinceEpoch}';
    final file = File(p.join(_reportsDir.path, '$id.json'));
    final envelope = {
      'id': id,
      'saved_at': savedAt.toIso8601String(),
      'packet': packet.toJson(),
    };
    await file.writeAsString(jsonEncode(envelope));
    return id;
  }

  @override
  Future<SavedReport?> getById(String id) async {
    final file = File(p.join(_reportsDir.path, '$id.json'));
    if (!file.existsSync()) {
      return null;
    }
    return _parseEnvelope(jsonDecode(await file.readAsString()) as Map<String, dynamic>);
  }

  @override
  Future<List<SavedReport>> list() async {
    if (!_reportsDir.existsSync()) {
      return [];
    }
    final reports = <SavedReport>[];
    for (final entity in _reportsDir.listSync()) {
      if (entity is! File || !entity.path.endsWith('.json')) {
        continue;
      }
      try {
        final map = jsonDecode(await entity.readAsString()) as Map<String, dynamic>;
        reports.add(_parseEnvelope(map));
      } catch (_) {
        // Skip corrupt files.
      }
    }
    reports.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return reports;
  }

  SavedReport _parseEnvelope(Map<String, dynamic> json) {
    return SavedReport(
      id: json['id'] as String,
      savedAt: DateTime.parse(json['saved_at'] as String),
      packet: EvidencePacket.fromJson(
        Map<String, dynamic>.from(json['packet'] as Map),
      ),
    );
  }
}
