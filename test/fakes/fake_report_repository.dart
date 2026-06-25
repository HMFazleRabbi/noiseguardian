import 'package:noise_guardian/data/models/saved_report.dart';
import 'package:noise_guardian/data/repositories/report_repository.dart';
import 'package:noise_guardian/domain/models/evidence_packet.dart';

class FakeReportRepository implements ReportRepository {
  final List<SavedReport> reports = [];
  int _counter = 1;

  @override
  Future<void> init() async {}

  @override
  Future<String> save(EvidencePacket packet) async {
    final id = 'fake-report-${_counter++}';
    reports.add(
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
      return reports.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<SavedReport>> list() async {
    final copy = List<SavedReport>.of(reports);
    copy.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return copy;
  }
}
