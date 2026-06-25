import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/data/repositories/report_repository.dart';

import '../fixtures/sample_evidence_packet.dart';

void main() {
  group('InMemoryReportRepository', () {
    late InMemoryReportRepository repo;

    setUp(() {
      repo = InMemoryReportRepository();
    });

    test('save get list round-trip', () async {
      await repo.init();
      final packet = sampleEvidencePacket();
      final id = await repo.save(packet);

      final loaded = await repo.getById(id);
      expect(loaded, isNotNull);
      expect(loaded!.packet.metrics.laeqDb, packet.metrics.laeqDb);

      final all = await repo.list();
      expect(all, hasLength(1));
      expect(all.single.id, id);
    });
  });

  group('FileReportRepository', () {
    late Directory tempDir;
    late FileReportRepository repo;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('ng_reports_test_');
      repo = FileReportRepository(baseDirectory: tempDir);
      await repo.init();
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('save get list round-trip', () async {
      final packet = sampleEvidencePacket(laeqDb: 61.0);
      final id = await repo.save(packet);

      final loaded = await repo.getById(id);
      expect(loaded, isNotNull);
      expect(loaded!.packet.metrics.laeqDb, 61.0);

      final all = await repo.list();
      expect(all, hasLength(1));
      expect(all.single.id, id);
    });
  });
}
